%% Determination of Experiment 1's "opposite" target for overshoot control


% All possible target locations
all_tgt_pos = grpstats(trial_data,{'target_direction','adjustment_angle_nominal'},'unique',...
    'DataVars',{'target_xyz_pos','target_xy_pos_2D_1'});

% We swap the actual target direction for the opposite target direction...
all_tgt_pos.target_direction = mod(all_tgt_pos.target_direction+180,360);

% ...to use this variable as key that assigns the respective opposite target location to each trial
trial_data = innerjoin(trial_data,all_tgt_pos);

trial_data.GroupCount = [];
try % try statement in case this script is rerun on data where variables have already been renamed
    trial_data.Properties.VariableNames('unique_target_xyz_pos')     = {'target_opposite_xyz_pos'};
    trial_data.Properties.VariableNames('unique_target_xy_pos_2D_1') = {'target_opposite_xy_pos_2D_1'};
end

trial_data = sortrows(trial_data,'index');


overshoot_target_ind = repmat([2 1],height(trial_data),1);

%% Where needed, we reformat variables for use with the cone method's wrapper function

%n trials x [chosen_target opposite_target] cell array w/either 3D or 2D target coordinates
target_pos_cone3D = [num2cell(trial_data.target_xyz_pos,2) num2cell(trial_data.target_opposite_xyz_pos,2)];
target_pos_cone2D = [num2cell(trial_data.target_xy_pos_2D_1,2) num2cell(trial_data.target_opposite_xy_pos_2D_1,2)];

% n trials x n targets numerical array
target_radius_cone = repmat(trial_data.target_diameter,1,2)./2;

hpos_cone3D = cellfun(@(x,y,z) [x;y;z]',hand_data.hpos_xyz(:,1),hand_data.hpos_xyz(:,2),hand_data.hpos_xyz(:,3),'Uni',0);
hpos_cone2D = cellfun(@(x,y) [x;y]',hand_data.hpos_xy_2D_1(:,1),hand_data.hpos_xy_2D_1(:,2),'Uni',0);


start_pos_cone2D = trial_data.start_xyz_pos(:,1:2);

%% POC estimation

cone_data = table();

[cone_data.poc3D_ind_raw,cone_data.dirdiff3D_raw,...
    cone_data.poc3D_ind_tol,cone_data.dirdiff3D_tol,...
    cone_data.poc3D_ind_ovs,cone_data.dirdiff3D_ovs,...
    cone_data.poc3D_ind_vel] = cone_wrapper(...
    trial_data.start_xyz_pos,...
    target_pos_cone3D,...
    target_radius_cone,...
    hpos_cone3D,...
    'start_cutoff',10,...                           % here, the cone method is only computed for trajectory elements exceeding 10mm distance from the starting point (i.e. everything that's outside the starting sphere)
    'tolerance',3,...                               % "tolerance" criterion in degree
    'overshoot_target_ind',overshoot_target_ind,... % column index of the opposite target for the "overshoot" criterion
    'hspeed',hand_data.hspeed);


[cone_data.poc2D_ind_raw,cone_data.dirdiff2D_raw,...
    cone_data.poc2D_ind_tol,cone_data.dirdiff2D_tol,...
    cone_data.poc2D_ind_ovs,cone_data.dirdiff2D_ovs,...
    cone_data.poc2D_ind_vel] = cone_wrapper(...
    start_pos_cone2D,...
    target_pos_cone2D,...
    target_radius_cone,...
    hpos_cone2D,...
    'start_cutoff',10,...
    'tolerance',3,...
    'overshoot_target_ind',overshoot_target_ind,...
    'hspeed',hand_data.hspeed);


%% POC extraction

% The cone method also estimates preliminary POCs (i.e. belonging to
% transient in-cone periods that are not covered by any of the extra
% criteria) towards every target included (e.g. the target defined as
% "opposite" for the overshoot criterion). Here, we only keep the POC that
% belongs to the final in-cone period.

cone_data.poc3D_ind_raw = cellfun(@(x) x(end),cone_data.poc3D_ind_raw(:,1),'uni',0);
cone_data.poc3D_ind_tol = cellfun(@(x) x(end),cone_data.poc3D_ind_tol(:,1),'uni',0);
cone_data.poc3D_ind_ovs = cellfun(@(x) x(end),cone_data.poc3D_ind_ovs(:,1),'uni',0);
cone_data.poc3D_ind_vel = cellfun(@(x) x(end),cone_data.poc3D_ind_vel(:,1),'uni',0);

cone_data.poc2D_ind_raw = cellfun(@(x) x(end),cone_data.poc2D_ind_raw(:,1),'uni',0);
cone_data.poc2D_ind_tol = cellfun(@(x) x(end),cone_data.poc2D_ind_tol(:,1),'uni',0);
cone_data.poc2D_ind_ovs = cellfun(@(x) x(end),cone_data.poc2D_ind_ovs(:,1),'uni',0);
cone_data.poc2D_ind_vel = cellfun(@(x) x(end),cone_data.poc2D_ind_vel(:,1),'uni',0);


cone_data.dirdiff3D_raw(:,2) = [];
cone_data.dirdiff3D_tol(:,2) = [];
cone_data.dirdiff3D_ovs(:,2) = [];

cone_data.dirdiff2D_raw(:,2) = [];
cone_data.dirdiff2D_tol(:,2) = [];
cone_data.dirdiff2D_ovs(:,2) = [];


%% POC index --> POC extraction

cone_data.poc3D_raw = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc3D_ind_raw);
cone_data.poc3D_tol = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc3D_ind_tol);
cone_data.poc3D_ovs = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc3D_ind_ovs);
cone_data.poc3D_vel = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc3D_ind_vel);

cone_data.poc2D_raw = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc2D_ind_raw);
cone_data.poc2D_tol = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc2D_ind_tol);
cone_data.poc2D_ovs = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc2D_ind_ovs);
cone_data.poc2D_vel = cellfun(@(h,p) h(p),hand_data.hpos_xy_2D_1(:,2),cone_data.poc2D_ind_vel);


%% POC relative to via-sphere entry and exit (along distance-from-start axis)

cone_data.poc3D_raw_rel2invia  = cone_data.poc3D_raw - trial_data.in_via_p;
cone_data.poc3D_raw_rel2outvia = cone_data.poc3D_raw - trial_data.out_via_p;
cone_data.poc3D_tol_rel2invia  = cone_data.poc3D_tol - trial_data.in_via_p;
cone_data.poc3D_tol_rel2outvia = cone_data.poc3D_tol - trial_data.out_via_p;
cone_data.poc3D_ovs_rel2invia  = cone_data.poc3D_ovs - trial_data.in_via_p;
cone_data.poc3D_ovs_rel2outvia = cone_data.poc3D_ovs - trial_data.out_via_p;
cone_data.poc3D_vel_rel2invia  = cone_data.poc3D_vel - trial_data.in_via_p;
cone_data.poc3D_vel_rel2outvia = cone_data.poc3D_vel - trial_data.out_via_p;

cone_data.poc2D_raw_rel2invia  = cone_data.poc2D_raw - trial_data.in_via_p;
cone_data.poc2D_raw_rel2outvia = cone_data.poc2D_raw - trial_data.out_via_p;
cone_data.poc2D_tol_rel2invia  = cone_data.poc2D_tol - trial_data.in_via_p;
cone_data.poc2D_tol_rel2outvia = cone_data.poc2D_tol - trial_data.out_via_p;
cone_data.poc2D_ovs_rel2invia  = cone_data.poc2D_ovs - trial_data.in_via_p;
cone_data.poc2D_ovs_rel2outvia = cone_data.poc2D_ovs - trial_data.out_via_p;
cone_data.poc2D_vel_rel2invia  = cone_data.poc2D_vel - trial_data.in_via_p;
cone_data.poc2D_vel_rel2outvia = cone_data.poc2D_vel - trial_data.out_via_p;


%% POC classification (in-bounds/too-early/too-late)

cone_data.poc3D_raw_inbounds = cone_data.poc3D_raw_rel2invia>=0 & cone_data.poc3D_raw_rel2outvia<=0;
cone_data.poc3D_raw_tooearly = cone_data.poc3D_raw_rel2invia<0;
cone_data.poc3D_raw_toolate  = cone_data.poc3D_raw_rel2outvia>0;
cone_data.poc3D_tol_inbounds = cone_data.poc3D_tol_rel2invia>=0 & cone_data.poc3D_tol_rel2outvia<=0;
cone_data.poc3D_tol_tooearly = cone_data.poc3D_tol_rel2invia<0;
cone_data.poc3D_tol_toolate  = cone_data.poc3D_tol_rel2outvia>0;
cone_data.poc3D_ovs_inbounds = cone_data.poc3D_ovs_rel2invia>=0 & cone_data.poc3D_ovs_rel2outvia<=0;
cone_data.poc3D_ovs_tooearly = cone_data.poc3D_ovs_rel2invia<0;
cone_data.poc3D_ovs_toolate  = cone_data.poc3D_ovs_rel2outvia>0;
cone_data.poc3D_vel_inbounds = cone_data.poc3D_vel_rel2invia>=0 & cone_data.poc3D_vel_rel2outvia<=0;
cone_data.poc3D_vel_tooearly = cone_data.poc3D_vel_rel2invia<0;
cone_data.poc3D_vel_toolate  = cone_data.poc3D_vel_rel2outvia>0;

cone_data.poc2D_raw_inbounds = cone_data.poc2D_raw_rel2invia>=0 & cone_data.poc2D_raw_rel2outvia<=0;
cone_data.poc2D_raw_tooearly = cone_data.poc2D_raw_rel2invia<0;
cone_data.poc2D_raw_toolate  = cone_data.poc2D_raw_rel2outvia>0;
cone_data.poc2D_tol_inbounds = cone_data.poc2D_tol_rel2invia>=0 & cone_data.poc2D_tol_rel2outvia<=0;
cone_data.poc2D_tol_tooearly = cone_data.poc2D_tol_rel2invia<0;
cone_data.poc2D_tol_toolate  = cone_data.poc2D_tol_rel2outvia>0;
cone_data.poc2D_ovs_inbounds = cone_data.poc2D_ovs_rel2invia>=0 & cone_data.poc2D_ovs_rel2outvia<=0;
cone_data.poc2D_ovs_tooearly = cone_data.poc2D_ovs_rel2invia<0;
cone_data.poc2D_ovs_toolate  = cone_data.poc2D_ovs_rel2outvia>0;
cone_data.poc2D_vel_inbounds = cone_data.poc2D_vel_rel2invia>=0 & cone_data.poc2D_vel_rel2outvia<=0;
cone_data.poc2D_vel_tooearly = cone_data.poc2D_vel_rel2invia<0;
cone_data.poc2D_vel_toolate  = cone_data.poc2D_vel_rel2outvia>0;


%% Add everything that is used for figures and analyses to trial_data

trial_data.poc3D_raw = cone_data.poc3D_raw;
trial_data.poc3D_tol = cone_data.poc3D_tol;
trial_data.poc3D_ovs = cone_data.poc3D_ovs;
trial_data.poc3D_vel = cone_data.poc3D_vel;

trial_data.poc2D_vel =cone_data.poc2D_vel;


trial_data.poc3D_raw_rel2invia  = cone_data.poc3D_raw_rel2invia;
trial_data.poc3D_raw_rel2outvia = cone_data.poc3D_raw_rel2outvia;
trial_data.poc3D_tol_rel2invia  = cone_data.poc3D_tol_rel2invia;
trial_data.poc3D_tol_rel2outvia = cone_data.poc3D_tol_rel2outvia;
trial_data.poc3D_ovs_rel2invia  = cone_data.poc3D_ovs_rel2invia;
trial_data.poc3D_ovs_rel2outvia = cone_data.poc3D_ovs_rel2outvia;
trial_data.poc3D_vel_rel2invia  = cone_data.poc3D_vel_rel2invia;
trial_data.poc3D_vel_rel2outvia = cone_data.poc3D_vel_rel2outvia;

trial_data.poc2D_vel_rel2invia  = cone_data.poc2D_vel_rel2invia;
trial_data.poc2D_vel_rel2outvia = cone_data.poc2D_vel_rel2outvia;


trial_data.poc3D_raw_inbounds = cone_data.poc3D_raw_inbounds;
trial_data.poc3D_raw_tooearly = cone_data.poc3D_raw_tooearly;
trial_data.poc3D_raw_toolate  = cone_data.poc3D_raw_toolate;
trial_data.poc3D_tol_inbounds = cone_data.poc3D_tol_inbounds;
trial_data.poc3D_tol_tooearly = cone_data.poc3D_tol_tooearly;
trial_data.poc3D_tol_toolate  = cone_data.poc3D_tol_toolate;
trial_data.poc3D_ovs_inbounds = cone_data.poc3D_ovs_inbounds;
trial_data.poc3D_ovs_tooearly = cone_data.poc3D_ovs_tooearly;
trial_data.poc3D_ovs_toolate  = cone_data.poc3D_ovs_toolate;
trial_data.poc3D_vel_inbounds = cone_data.poc3D_vel_inbounds;
trial_data.poc3D_vel_tooearly = cone_data.poc3D_vel_tooearly;
trial_data.poc3D_vel_toolate  = cone_data.poc3D_vel_toolate;

trial_data.poc2D_vel_inbounds = cone_data.poc2D_vel_inbounds;
trial_data.poc2D_vel_tooearly = cone_data.poc2D_vel_tooearly;
trial_data.poc2D_vel_toolate  = cone_data.poc2D_vel_toolate;


%% Store the data

cone_data = cone_data(:,sort(cone_data.Properties.VariableNames));
save([data_dir 'Exp1_cone_data.mat'],'cone_data');

trial_data = trial_data(:,sort(trial_data.Properties.VariableNames));
save([data_dir 'Exp1_data_full.mat'],'-append','trial_data');