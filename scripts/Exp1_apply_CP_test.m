clear all
load('Exp1_data.mat')


%% Trajectory interpolation

% To apply the CP test, the distance-from-start values of all trajectories
% need to be aligned. Therefore, we interpolate the lateral deviation values per trajectory
% at fixed distance-from-start query points equal for all trajectories.

% Query points between 10mm distance-from-start and highest possible target distance
xq_min = unique(trial_data.start_diameter)/2;
xq_max = floor(max(trial_data.target_xy_pos_2D_2(:,1)));
xq = linspace(xq_min,xq_max,1000); % Upsampling to avoid interpolation-caused distortion of the curves

hpos_xy_2D_2_interp = cell(height(hand_data),2);
hpos_xy_2D_2_interp(:,1) = {xq};

hpos_xy_2D_2_interp(:,2) = cellfun(@(x,v,xq) interp1(x,v,xq,'linear',NaN),...
    hand_data.hpos_xy_2D_2(:,1),hand_data.hpos_xy_2D_2(:,2),hpos_xy_2D_2_interp(:,1),'Uni',0);


cutoff_inds = cellfun(@(x) find(~isnan(x),1,'last'),hpos_xy_2D_2_interp(:,2));


%% CP test application

trial_data.poc_cp_interp = nan(height(trial_data),1);

CP_data = table();

unique_si = unique(trial_data.subject_index);
unique_aan = unique(trial_data.adjustment_angle_nominal);

CP_data.subject_index            = sort(repmat(unique_si,numel(unique_aan),1));
CP_data.adjustment_angle_nominal = repmat(unique_aan,numel(unique_si),1);
CP_data.is_sig                   = cell(height(CP_data),1);
CP_data.pval                     = cell(height(CP_data),1);
CP_data.sig_onset                = nan(height(CP_data),1);
CP_data.poc_cp_interp            = nan(height(CP_data),1);

for i = 1:height(CP_data)
    sel = trial_data.subject_index==CP_data.subject_index(i)...
        & trial_data.adjustment_angle_nominal==CP_data.adjustment_angle_nominal(i);
    
    % Within each CP test we truncate all trajectories to the length of the shortest trajectory
    min_cutoff_ind = min(cutoff_inds(sel));
    hpos(:,1) = cellfun(@(x) x(1:min_cutoff_ind),hpos_xy_2D_2_interp(sel,1),'Uni',0);
    hpos(:,2) = cellfun(@(x) x(1:min_cutoff_ind),hpos_xy_2D_2_interp(sel,2),'Uni',0);
    
    % We compare trajectories towards upward targets (45° & 135° pooled) vs downward targets (225° & 315° pooled)
    sel2 = trial_data.target_direction(sel)==45 | trial_data.target_direction(sel)==135;
    sample1 = cell2mat(hpos(sel2,2));
    sample2 = cell2mat(hpos(~sel2,2));
    
    % We inteded to perform a one-tailed CP test at alpha = 0.05 (since we are only
    % interested in statistical differences due to trajectories towards upward targets moving upward and vice versa).
    % Since the CP test function below only allows for two-tailed testing, we set alpha to 0.1
    % and discard any significant clusters due to effects opposite to our effect of interest)
    [CP_data.is_sig{i},CP_data.pval{i}] = ClusterPermtTest(sample1,sample2,1000,0.1); % sample 1, sample 2, n permutations, alpha level
    wrongside = mean(sample1,1) < mean(sample2,1);
    CP_data.is_sig{i}(wrongside) = 0;
    CP_data.pval{i}(wrongside) = 1;
    
    % Onset of the last significant cluster
    aux = find(diff(CP_data.is_sig{i})==1,1,'last')+1;
    if ~isempty(aux)
        CP_data.sig_onset(i) = aux;
    end
    
    % When the lateral deviation is significant from the first datapoint
    % onward, the code above erroneously determines no significance onset
    % at all
    aux = mean(CP_data.is_sig{i}==1)==1;
    if aux
        CP_data.sig_onset(i) = 1;
    end
    
    % Translate the CP test significance onset into the POC CP
    CP_data.poc_cp_interp(i)      = xq(CP_data.sig_onset(i));
    trial_data.poc_cp_interp(sel) = CP_data.poc_cp_interp(i);
end


% Find the the hand position in the original (i.e. non-interpolated) trajectories closest to the POC CP
[~,aux_i] = cellfun(@(x,p) min(abs(x-p)),hand_data.hpos_xy_2D_2(:,1),num2cell(trial_data.poc_cp_interp),'uni',0);
trial_data.poc_cp_orig = cellfun(@(x,i) x(i),hand_data.hpos_xy_2D_2(:,1),aux_i);


%% POC CP relative to via-sphere entry
trial_data.poc_cp_interp_rel2invia = trial_data.poc_cp_interp-trial_data.in_via_p;
trial_data.poc_cp_orig_rel2invia   = trial_data.poc_cp_orig-trial_data.in_via_p;

%% Store the results

trial_data = trial_data(:,sort(trial_data.Properties.VariableNames));

save('Exp1_CP_data.mat','CP_data');
save('Exp1_data.mat','-append','trial_data');
