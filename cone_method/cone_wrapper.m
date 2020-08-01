function [...
    poc_raw,...     % POC without additional adjustments
    dirdiff_raw,... % Difference between momentary direction and cone surface without additional adjustments
    poc_tol,...     % POC with "tolerance" adjustment
    dirdiff_tol,... % Difference between momentary direction and [...] with "tolerance" adjustment
    poc_ovs,...     % POC with "overshoot" adjustment
    dirdiff_ovs,... % Difference between momentary direction and [...] with "overshoot" adjustment
    poc_vel]...     % POC with "speed" (_vel_ocity) adjustment
    ...
    = cone_wrapper(...  % N = number of trials
    start_pos,...       % N x 2 (2D) or 3 (3D) numeric array (same starting position stimulus position for all trajectories)
    target_pos,...      % N x number of potential targets cell array, containing 1x2 or 1x3 coordinates
    target_radius,...   % N x number of potential targets numeric array
    hpos,...            % N x 2 (2D) or 3 (3D) cell array containing continuous hand position data vectors
    varargin)

% The cone method is automatically applied in 2D or 3D depending on the number of
% dimensions of the input data (starting point & target positions, hand position).

% To apply the tolerance criterion, provide the name-value-pair 'tolerance'
% To apply the overshoot criterion, provide the name-value-pair 'overshoot_target_ind'
% To apply the speed criterion, provide the name-value-pair 'hspeed'
% Omit either of the above if the respective criterion should not be
% applied

p = inputParser;

default_start_cutoff         = 0;
default_tolerance            = 0;
default_overshoot_target_ind = false;
default_hspeed               = false;

check_input1 = @(x) isnumeric(x) && isscalar(x) && (x>0);

addParameter(p,'start_cutoff',default_start_cutoff,check_input1);       % hand position cutoff relative to starting stimulus position
addParameter(p,'tolerance',default_tolerance,check_input1);             % out-of-cone-slip tolerance window (0 = criterion not applied)
addParameter(p,'overshoot_target_ind',default_overshoot_target_ind);    % If false, no overshoot criterion applied, otherwise Nx2 numerical with the index of the opposite target for each respective target (column of "target_pos"; e.g. for two targets, this would be [2 1] if target 2 is opposite of target 1)
addParameter(p,'hspeed',default_hspeed);                                % If false, no speed criterion applied, otherwise Nx1 cell array containing continuous speed data

parse(p,varargin{:});

start_cutoff         = p.Results.start_cutoff;
tolerance            = p.Results.tolerance;
overshoot_target_ind = p.Results.overshoot_target_ind;
hspeed               = p.Results.hspeed;


n_target = size(target_pos,2);


% Check if data is 2D or 3D
if size(start_pos,2)==unique(cellfun(@(x) size(x,2),target_pos)) && size(start_pos,2)==unique(cellfun(@(x) size(x,2),hpos))
    is3D = size(start_pos,2)==3;
else
    error('Number of dimensions in starting/target/hand position not congruent!')
end


% If a start cutoff is defined, we delete all hpos data below the cutoff to
% only perform the cone method on the remaining data (NaNs will be added at
% the very end to harmonize the cone - current direction - difference
% (dirdiff) vector lengths with hpos)

if start_cutoff>0
    % Distance from start
    if is3D
        dist2start = cellfun(@(x0,y0,z0,h) sqrt((h(:,1)-x0).^2+(h(:,2)-y0).^2+(h(:,3)-z0).^2),...
            num2cell(start_pos(:,1)),num2cell(start_pos(:,2)),num2cell(start_pos(:,3)),hpos,'Uni',0);
    else
        dist2start = cellfun(@(x0,y0,h) sqrt((h(:,1)-x0).^2+(h(:,2)-y0).^2),...
            num2cell(start_pos(:,1)),num2cell(start_pos(:,2)),hpos,'Uni',0);
    end
    
    start_ind = cellfun(@(x) find(x>=start_cutoff,1,'first'),dist2start,'Uni',0); % 'uni',0 to keep as cell array for following cellfun
    
else
    start_ind = num2cell(ones(size(start_pos,1),1));
end

hpos   = cellfun(@(x,sind) x(sind:end,:),hpos,start_ind,'uni',0);
if iscell(hspeed)
    hspeed = cellfun(@(x,sind) x(sind:end,:),hspeed,start_ind,'uni',0);
end

% Reformat hpos to run cone method functions for all targets via cellfun
hpos   = repmat(hpos,1,n_target);
if iscell(hspeed)
    hspeed = repmat(hspeed,1,n_target);
end


% 1. Raw cone method
dirdiff = cellfun(@(hpos,tpos,trad) dirdiff_fun(hpos,tpos,trad),hpos,target_pos,num2cell(target_radius),'uni',0);

% In dirdiff_raw, epochs where the current direction is in-cone are defined
% as 0. Below we extract the start and end indices of these epochs.
incone_start = cellfun(@(x) find_incone(x,0,1),dirdiff,'Uni',0);
incone_stop  = cellfun(@(x) find_incone(x,0,-1),dirdiff,'Uni',0);

poc = cellfun(@(x,a,b) find_POC(x,a,b),dirdiff,incone_start,incone_stop,'Uni',0);

dirdiff_raw = dirdiff;
poc_raw     = poc;


% 2. Applying the tolerance correction
if tolerance>0
    dirdiff = cellfun(@(x,a) tolerance_criterion(x,a,tolerance),dirdiff,incone_start,'uni',0);
    
    % Same as above but with tolerance-corrected dirdiff
    incone_start = cellfun(@(x) find_incone(x,0,1),dirdiff,'Uni',0);
    incone_stop  = cellfun(@(x) find_incone(x,0,-1),dirdiff,'Uni',0);
    poc         = cellfun(@(x,a,b) find_POC(x,a,b),dirdiff,incone_start,incone_stop,'Uni',0);
    
    dirdiff_tol = dirdiff;
    poc_tol     = poc;
else
    dirdiff_tol = num2cell(nan(size(poc_raw)));
    poc_tol     = num2cell(nan(size(poc_raw)));
end


% 3. Applying the overshoot correction
if overshoot_target_ind
    for i = 1:size(dirdiff,1)
        dirdiff(i,:) = overshoot_criterion(dirdiff(i,:),incone_start(i,:),incone_stop(i,:),overshoot_target_ind(i,:));
    end

    incone_start = cellfun(@(x) find_incone(x,0,1),dirdiff,'Uni',0);
    incone_stop  = cellfun(@(x) find_incone(x,0,-1),dirdiff,'Uni',0);
    poc         = cellfun(@(x,a,b) find_POC(x,a,b),dirdiff,incone_start,incone_stop,'Uni',0);
    
    dirdiff_ovs = dirdiff;
    poc_ovs     = poc;
else
    dirdiff_ovs = num2cell(nan(size(poc_raw)));
    poc_ovs = num2cell(nan(size(poc_raw)));
end


% 4. Applying the speed criterion
if iscell(hspeed)
    poc_vel = cellfun(@(h,i,p) speed_criterion(h,i,p),hspeed,incone_start,poc,'uni',0);
else
    poc_vel = num2cell(nan(size(poc_raw)));
end

% Vector length harmonization of dirdiff to hand data (NaNs where dirdiff
% was not estimated due to the start cutoff + single tailing NaN where
% dirdiff could not be estimated) & corresponding POC index shift
if start_cutoff>0
    dirdiff_raw = cellfun(@(x,sind) [nan(sind-1,1);x;nan],dirdiff_raw,repmat(start_ind,1,n_target),'uni',0);
    dirdiff_tol = cellfun(@(x,sind) [nan(sind-1,1);x;nan],dirdiff_tol,repmat(start_ind,1,n_target),'uni',0);
    dirdiff_ovs = cellfun(@(x,sind) [nan(sind-1,1);x;nan],dirdiff_ovs,repmat(start_ind,1,n_target),'uni',0);
    
    poc_raw = cellfun(@(x,sind) x+sind-1,poc_raw,repmat(start_ind,1,n_target),'uni',0);
    poc_tol = cellfun(@(x,sind) x+sind-1,poc_tol,repmat(start_ind,1,n_target),'uni',0);
    poc_ovs = cellfun(@(x,sind) x+sind-1,poc_ovs,repmat(start_ind,1,n_target),'uni',0);
    poc_vel = cellfun(@(x,sind) x+sind-1,poc_vel,repmat(start_ind,1,n_target),'uni',0);
end
