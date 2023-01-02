%% Where needed, we reformat variables for use with the cone method's wrapper function
% See also "Exp1_apply_cone_method.m"

% The unchosen target is the opposite target of the chosen target and vice versa
overshoot_target_ind = repmat([2 1],height(trial_data),1);

target_pos_cone = [num2cell(trial_data.chosen_target_pos,2) num2cell(trial_data.unchosen_target_pos,2)];

target_radius_cone = repmat(trial_data.target_diameter,1,2)./2;

hpos_cone = cellfun(@(x,y) [x;y]',hand_data.hpos(:,1),hand_data.hpos(:,2),'Uni',0);

hspeed_cone = cellfun(@(x) x',hand_data.hspeed,'uni',0);

%% POC estimation

cone_data = table();

[~,~,~,~,~,cone_data.dirdiff2D_ovs,cone_data.poc2D_ind_vel] = cone_wrapper(...
    trial_data.start_pos,...
    target_pos_cone,...
    target_radius_cone,...
    hpos_cone,...
    'start_cutoff',10,...
    'tolerance',3,...
    'overshoot_target_ind',overshoot_target_ind,...
    'hspeed',hspeed_cone);


%% POC/TOC extraction

cone_data.poc2D_ind_vel = cellfun(@(x) x(end),cone_data.poc2D_ind_vel(:,1),'uni',0);
cone_data.poc2D_vel     = cellfun(@(h,p) h(p),hand_data.hpos(:,2),cone_data.poc2D_ind_vel);
cone_data.toc2D_vel     = cellfun(@(t,p) t(p),hand_data.time,cone_data.poc2D_ind_vel);

trial_data.poc2D_vel = cone_data.poc2D_vel;
trial_data.toc2D_vel = cone_data.toc2D_vel;

trial_data.toc2D_vel_rel2gocue = trial_data.toc2D_vel + trial_data.reaction_time;
trial_data.toc2D_vel_rel2soa   = trial_data.toc2D_vel_rel2gocue - trial_data.soa_plus_screendelay;

% If POC directly at first datapoint considered by the cone method then TOC at
% movement start and thus putative decision before movement start
s_cutoff_ind = cellfun(@(x) find(~isnan(x),1),cone_data.dirdiff2D_ovs(:,1));
trial_data.toc2D_vel_pre_mvt = cell2mat(cone_data.poc2D_ind_vel)==s_cutoff_ind;

% TOC before value cue onset+50ms
trial_data.toc2D_vel_pre_soa = trial_data.toc2D_vel_rel2soa<50;

%% Store the data

cone_data = cone_data(:,sort(cone_data.Properties.VariableNames));
save([data_dir 'Exp2_cone_data.mat'],'cone_data');

trial_data = trial_data(:,sort(trial_data.Properties.VariableNames));
save([data_dir 'Exp2_data.mat'],'-append','trial_data');