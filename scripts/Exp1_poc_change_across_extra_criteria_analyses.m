clear all
load('Exp1_data.mat')


%% Data preparation

% Identify for which trials the POC estimates differ between cone method additions/versions ("affected trials")
trial_data.aff_raw_tol = trial_data.poc3D_raw~=trial_data.poc3D_tol;
trial_data.aff_tol_ovs  = trial_data.poc3D_tol~=trial_data.poc3D_ovs;
trial_data.aff_ovs_vel  = trial_data.poc3D_ovs~=trial_data.poc3D_vel;
trial_data.aff_vel_2D   = trial_data.poc3D_vel~=trial_data.poc2D_vel;

% Size of POC difference between cone method additions/versions
trial_data.POCdiff_raw_tol = trial_data.poc3D_tol-trial_data.poc3D_raw;
trial_data.POCdiff_tol_ovs  = trial_data.poc3D_ovs-trial_data.poc3D_tol;
trial_data.POCdiff_ovs_vel  = trial_data.poc3D_vel-trial_data.poc3D_ovs;
trial_data.POCdiff_vel_2D   = trial_data.poc2D_vel-trial_data.poc3D_vel;

trial_data2 = stack(trial_data,{'aff_raw_tol','aff_tol_ovs','aff_ovs_vel','aff_vel_2D'},...
    'IndexVariableName','cone_comp','NewDataVariableName','affected');

trial_data2_1 = stack(trial_data,{'POCdiff_raw_tol','POCdiff_tol_ovs','POCdiff_ovs_vel','POCdiff_vel_2D'},...
    'IndexVariableName','cone_comp','NewDataVariableName','diff_POC');

trial_data2.diff_POC = trial_data2_1.diff_POC;

% Size of POC difference for affected trials only
trial_data2.diff_POC_affOnly = trial_data2.diff_POC;
trial_data2.diff_POC_affOnly(trial_data2.affected==0) = nan;

clear trial_data2_1


% Sum of affected trials per adjustment angle bin
trial_data3 = grpstats(trial_data2,{'subject_index','adjustment_angle_actual_bin_fixedEdge','cone_comp'},...
    'sum','DataVars','affected');
trial_data3.Properties.VariableNames{'sum_affected'} = 'sum_affected_SA';
trial_data3.cone_comp = cellstr(trial_data3.cone_comp);


% Mean POC difference per adjustment angle bin
trial_data3_1 = grpstats(trial_data2,{'subject_index','adjustment_angle_actual_bin_fixedEdge','cone_comp'},...
    'mean','DataVars',{'diff_POC','diff_POC_affOnly'});
trial_data3.mean_diff_POC_SA         = trial_data3_1.mean_diff_POC;
trial_data3.mean_diff_POC_affOnly_SA = trial_data3_1.mean_diff_POC_affOnly;


% Total sum of affected trials
trial_data3_1 = grpstats(trial_data2,{'subject_index','cone_comp'},'sum','DataVars','affected');
trial_data3_1.Properties.VariableNames{'sum_affected'} = 'sum_affected_S';
trial_data3_1.cone_comp = cellstr(trial_data3_1.cone_comp);


% Mean POC difference across all bins
% averaging from trial_data2 creates grand (i.e. weighted) per subject average, i.e. bins with fewer trials are weighted proportionally less
trial_data3_2 = grpstats(trial_data2,{'subject_index','cone_comp'},'mean','DataVars',{'diff_POC','diff_POC_affOnly'});
trial_data3_1.mean_diff_POC_S         = trial_data3_2.mean_diff_POC;
trial_data3_1.mean_diff_POC_affOnly_S = trial_data3_2.mean_diff_POC_affOnly;


% Add everything to trial_data3
[trial_data3.sum_affected_S,trial_data3.mean_diff_POC_S,trial_data3.mean_diff_POC_affOnly_S] = deal(nan(height(trial_data3),1));
for i = 1:height(trial_data3_1)
    sel = trial_data3.subject_index==trial_data3_1.subject_index(i)...
        & strcmp(trial_data3.cone_comp,trial_data3_1.cone_comp(i));
    trial_data3.sum_affected_S(sel)          = trial_data3_1.sum_affected_S(i);
    trial_data3.mean_diff_POC_S(sel)         = trial_data3_1.mean_diff_POC_S(i);
    trial_data3.mean_diff_POC_affOnly_S(sel) = trial_data3_1.mean_diff_POC_affOnly_S(i);
end

trial_data3.cone_comp(strcmp(trial_data3.cone_comp,'aff_raw_tol'))  =         {'raw -> w/tolerance'};
trial_data3.cone_comp(strcmp(trial_data3.cone_comp,'aff_tol_ovs'))  = {'w/tolerance -> w/overshoot'};
trial_data3.cone_comp(strcmp(trial_data3.cone_comp,'aff_ovs_vel'))  = {'w/overshoot -> w/speed'};
trial_data3.cone_comp(strcmp(trial_data3.cone_comp,'aff_vel_2D'))   =     {'w/speed -> 2D'};


% Sums --> proportions (cf. "Exp1_poc_proportion_inbound_analyses.m"); used for Supplementary Figure 1-2 A
trial_data3.sum_all_S  = 240*ones(height(trial_data3),1);
trial_data3.sum_all_SA = trial_data3.GroupCount;

trial_data3.p_affected_SA = trial_data3.sum_affected_SA ./ trial_data3.sum_all_SA;
trial_data3.p_affected_S  = trial_data3.sum_affected_SA ./ trial_data3.sum_all_S;

trial_data3.p_all_S = trial_data3.sum_all_SA ./ trial_data3.sum_all_S;


% Overall proportions of affected trials; used for Supplementary Figure 1-2 B
trial_data4 = grpstats(trial_data3,{'subject_index','cone_comp','sum_all_S'},'sum','DataVars','sum_affected_SA');
trial_data4.p_affected = trial_data4.sum_sum_affected_SA ./ trial_data4.sum_all_S;


% POC difference between cone method additions/versions, per bin; used for Supplementary Figure 1-2 C
trial_data5 = stack(trial_data3,{'mean_diff_POC_SA','mean_diff_POC_affOnly_SA'},'IndexVariableName','diff_POC_type',...
    'NewDataVariableName','diff_POC_value');
trial_data5.diff_POC_type = cellstr(trial_data5.diff_POC_type);
trial_data5.diff_POC_type(strcmp(trial_data5.diff_POC_type,'mean_diff_POC_SA'))         = {'All trials'};
trial_data5.diff_POC_type(strcmp(trial_data5.diff_POC_type,'mean_diff_POC_affOnly_SA')) = {'Affected trials only'};


% Unsigned POC difference across bins; used for Supplementary Figure 1-2 D
trial_data6 = trial_data2;

trial_data6.diff_POC         = abs(trial_data6.diff_POC);
trial_data6.diff_POC_affOnly = abs(trial_data6.diff_POC_affOnly);

trial_data6 = stack(trial_data6,{'diff_POC','diff_POC_affOnly'},'IndexVariableName','diff_POC_type',...
    'NewDataVariableName','diff_POC_value');
trial_data6.diff_POC_type = cellstr(trial_data6.diff_POC_type);
trial_data6.diff_POC_type(strcmp(trial_data6.diff_POC_type,'diff_POC'))         = {'All trials'};
trial_data6.diff_POC_type(strcmp(trial_data6.diff_POC_type,'diff_POC_affOnly')) = {'Affected trials only'};

trial_data6 = grpstats(trial_data6,{'subject_index','cone_comp','diff_POC_type'},'mean','DataVars','diff_POC_value');
trial_data6.cone_comp = cellstr(trial_data6.cone_comp);

trial_data6.cone_comp(strcmp(trial_data6.cone_comp,'aff_raw_tol'))  =         {'raw -> w/tolerance'};
trial_data6.cone_comp(strcmp(trial_data6.cone_comp,'aff_tol_ovs'))  = {'w/tolerance -> w/overshoot'};
trial_data6.cone_comp(strcmp(trial_data6.cone_comp,'aff_ovs_vel'))  = {'w/overshoot -> w/speed'};
trial_data6.cone_comp(strcmp(trial_data6.cone_comp,'aff_vel_2D'))   =     {'w/speed -> 2D'};


%% Supplementary Figure 1-2

cmap_outofbounds = [ 77 175  74
                    152  78 163
                    255 127   0]./255;

clear g
figure('Units','centimeters','Position',[0 0 28 18])

% 1-2 A, gray bars (proportion trials per bin)
g(1) = gramm('x',trial_data3.adjustment_angle_actual_bin_fixedEdge,'y',trial_data3.p_all_S*4);
g(1).set_layout_options('position',[0 0.5 0.725 0.5]);
g(1).stat_summary('type','sem','geom','bar','width',0.7);
g(1).axe_property('XTick',0:10:90,'XTickLabelRotation',45,'YLim',[0 1],'YTick',[0 0.5 1]);
g(1).facet_grid([],trial_data3.cone_comp);
g(1).set_names('x','Actual adjustment angle bin [°]','y','Proportion of trials','column','','row','','color','');
g(1).set_color_options('map',[0.7 0.7 0.7]);
g(1).set_order_options('column',[1 4 2 3]);

% 1-2 B
g(2) = gramm('x',trial_data4.cone_comp,'y',trial_data4.p_affected);
g(2).set_layout_options('position',[0.725 0.5 0.275 0.5]);
g(2).stat_summary('type','bootci','geom',{'bar','black_errorbar'});
g(2).axe_property('YLim',[0 1],'YTick',[0 0.5 1],'XLim',[0.7 4.3],'XTickLabelRotation',45);
g(2).set_names('x','','y','Proportion of trials');
g(2).set_color_options('map',[49,130,189]./255);
g(2).set_order_options('x',[1 4 2 3]);

% 1-2 C
g(3) = gramm('x',trial_data5.adjustment_angle_actual_bin_fixedEdge,'y',trial_data5.diff_POC_value,...
    'color',trial_data5.diff_POC_type);
g(3).set_layout_options('position',[0 0 0.725 0.5],'legend_position',[0.575 0.1 0.15 0.15]);
g(3).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1,'setylim',1);
g(3).geom_hline('yintercept',0);
g(3).axe_property('XTick',0:10:90,'XTickLabelRotation',45);
g(3).facet_grid([],trial_data5.cone_comp);
g(3).set_names('x','Actual adjustment angle bin [°]','y','POC change [mm]','color','','column','');
g(3).set_color_options('map',[230,85,13;49,130,189]./255);
g(3).set_order_options('column',[1 4 2 3],'color',-1);

% 1-2 D
g(4) = gramm('x',trial_data6.cone_comp,'y',trial_data6.mean_diff_POC_value,'color',trial_data6.diff_POC_type);
g(4).set_layout_options('position',[0.725 0 0.275 0.5],'legend_position',[0.85 0.425 0.15 0.15]);
g(4).stat_summary('type','bootci','geom',{'bar','black_errorbar'},'setylim',1);
g(4).axe_property('YLim',[0 50],'XLim',[0.7 4.3],'XTickLabelRotation',45);
g(4).set_names('x','','y','Absolute POC change [mm]','color','');
g(4).set_color_options('map',[230,85,13;49,130,189]./255);
g(4).set_order_options('x',[1 4 2 3],'color',-1);

g.set_text_options('base_size',10,'label_scaling',1.4,'facet_scaling',1.4,'legend_scaling',1,'title_scaling',1);
g.set_line_options('base_size',2);
g.set_stat_options('nboot',2000);
g.draw();

% 1-2 A, black bars (proportion affected trials per bin relative to total n trials)
g(1).update('x',trial_data3.adjustment_angle_actual_bin_fixedEdge,'y',trial_data3.p_affected_S*4);
g(1).stat_summary('type','sem','geom','bar','width',0.7);
g(1).set_color_options('map',[0 0 0]);
g(1).draw();

% 1-2 A, line plot (proportion affected trials per bin relative to per-bin n trials)
g(1).update('x',trial_data3.adjustment_angle_actual_bin_fixedEdge,'y',trial_data3.p_affected_SA);
g(1).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1);
g(1).set_color_options('map',[49,130,189]./255);
g(1).draw();

g.export('file_name','Figure_S1-2.pdf','file_type','pdf');



