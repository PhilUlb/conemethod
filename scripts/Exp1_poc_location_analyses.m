%% Data preparation

trial_data.poc_cone_cp_diff = trial_data.poc3D_vel - trial_data.poc_cp_orig;


trial_data2_1 = grpstats(trial_data,{'subject_index','adjustment_angle_actual_bin_fixedEdge'},'mean','DataVars','poc3D_vel_rel2invia');

trial_data2_3 = grpstats(trial_data,{'subject_index','adjustment_angle_nominal'},'mean','DataVars',...
    {'poc_cp_orig','poc_cp_orig_rel2invia','poc3D_vel_rel2invia','poc_cone_cp_diff'});

trial_data2_2 = stack(trial_data2_3,{'mean_poc_cp_orig_rel2invia','mean_poc3D_vel_rel2invia'},'IndexVariableName',...
    'dec_p_type','NewDataVariableName','dec_p');

trial_data2_2.dec_p_type = cellstr(trial_data2_2.dec_p_type);
trial_data2_2.dec_p_type(strcmp(trial_data2_2.dec_p_type,'mean_poc_cp_orig_rel2invia')) = {'POC CP'};
trial_data2_2.dec_p_type(strcmp(trial_data2_2.dec_p_type,'mean_poc3D_vel_rel2invia'))   = {'POC cone'};


%% POC cone outlier analysis

outlr_data = trial_data2_3;
outlr_data.Properties.VariableNames('mean_poc_cp_orig') = {'poc_cp'};
outlr_data = grpstats(outlr_data,{'adjustment_angle_nominal'},{'mean','std','min','max'},'DataVars','poc_cp');

outlr_data.cutoff_min = outlr_data.mean_poc_cp-3*outlr_data.std_poc_cp;
outlr_data.cutoff_max = outlr_data.mean_poc_cp+3*outlr_data.std_poc_cp;

outlr_data.has_outlier_max = outlr_data.max_poc_cp>outlr_data.cutoff_max;
outlr_data.has_outlier_min = outlr_data.min_poc_cp<outlr_data.cutoff_min;

% Based on outlr_data, we manually flag the outliers.
trial_data2_3.isoutlier = zeros(height(trial_data2_3),1);
trial_data2_3.isoutlier(trial_data2_3.adjustment_angle_nominal==19.71...
    & trial_data2_3.mean_poc_cp_orig<outlr_data.cutoff_min(2)) = 1;
trial_data2_3.isoutlier(trial_data2_3.adjustment_angle_nominal==25.76...
    & trial_data2_3.mean_poc_cp_orig<outlr_data.cutoff_min(3)) = 1;

trial_data2_2.isoutlier = zeros(height(trial_data2_2),1);
trial_data2_2.isoutlier(trial_data2_2.adjustment_angle_nominal==19.71 & trial_data2_2.subject_index==11) = 1;
trial_data2_2.isoutlier(trial_data2_2.adjustment_angle_nominal==25.76 & trial_data2_2.subject_index==3)  = 1;

%% GLME1-2 (Figure 4D)

model1_2 = fitglme(trial_data,'poc3D_vel_rel2invia ~adjustment_angle_actual + (adjustment_angle_actual|subject_index)');

% Prediction for figure
mdl_1_2_pred = table();
mdl_1_2_pred.adjustment_angle_actual...
    = linspace(min(trial_data.adjustment_angle_actual),max(trial_data.adjustment_angle_actual),100)';
mdl_1_2_pred.subject_index = ones(height(mdl_1_2_pred),1); % Dummy variable since only the marginal effects are fitted

mdl_1_2_pred.POCfit = predict(model1_2,mdl_1_2_pred,'Conditional',0);

mdl_1_2_pred(mdl_1_2_pred.adjustment_angle_actual>80,:) = []; % We only display data for the bins up to 80    


%% GLME1-3 (Figure 4E)

% Aggregated data
%model1_3_cone = fitglme(trial_data2_3,'mean_poc3D_vel_rel2invia   ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');
model1_3_cp = fitglme(trial_data2_3(~trial_data2_3.isoutlier,:),... % Excluding the two cases in which POC CP = too early
    'mean_poc_cp_orig_rel2invia ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');
model1_3_cp_w_outlier = fitglme(trial_data2_3,... % Model with outliers
    'mean_poc_cp_orig_rel2invia ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');


% Per-trial data (POC-cone only, used in manuscript)
model1_3_cone = fitglme(trial_data,'poc3D_vel_rel2invia ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');


% Prediction for figure
for i = 1:2
    tmp_tbl = table();
    tmp_tbl.adjustment_angle_nominal = unique(trial_data.adjustment_angle_nominal);
    tmp_tbl.subject_index = ones(height(tmp_tbl),1); % Dummy variable since only the marginal effects are fitted
    
    if i==1
        tmp_tbl.POCtype = repmat({'POC cone'},height(tmp_tbl),1);
        tmp_tbl.POCfit = predict(model1_3_cone,tmp_tbl,'Conditional',0);
        mdl_1_3_pred = tmp_tbl;
    else
        tmp_tbl.POCtype = repmat({'POC CP'},height(tmp_tbl),1);
        tmp_tbl.POCfit = predict(model1_3_cp_w_outlier,tmp_tbl,'Conditional',0);
        mdl_1_3_pred = vertcat(mdl_1_3_pred,tmp_tbl);
    end
end



%% Redoing the GLMEs per subsample and storing them for the cross-validation analysis

trial_data.subsample = cell(height(trial_data),1);
trial_data.subsample(trial_data.subject_index<9) = {'1-8'};
trial_data.subsample(trial_data.subject_index>8) = {'9-16'};

mdl1_2_s1_8  = fitglme(trial_data(trial_data.subject_index<9,:),...
    'poc3D_vel_rel2invia ~adjustment_angle_actual + (adjustment_angle_actual|subject_index)');
mdl1_2_s9_16 = fitglme(trial_data(trial_data.subject_index>8,:),...
    'poc3D_vel_rel2invia ~adjustment_angle_actual + (adjustment_angle_actual|subject_index)');


%% Figure 4 DEF

clear g
figure('Units','centimeters','Position',[0 0 28 10])

% POC cone rel. to via-sphere entry
g(1,1) = gramm('x',mdl_1_2_pred.adjustment_angle_actual,'y',mdl_1_2_pred.POCfit);
g(1,1).geom_line;
g(1,1).geom_hline('yintercept',0);
g(1,1).axe_property('YLim',[-20 40],'XTick',0:10:80);
g(1,1).set_names('x','Actual adjustment angle bin [°]','y','Distance from via-sphere entry [mm]');
g(1,1).set_title('POC cone rel. to via-sphere entry');
g(1,1).set_color_options('map',[0.5 0.5 0.5]);
g(1,1).set_line_options('base_size',3,'styles',{'--'});

% POC CP & cone rel. to via-sphere entry
g(1,2) = gramm('x',mdl_1_3_pred.adjustment_angle_nominal,'y',mdl_1_3_pred.POCfit,'color',mdl_1_3_pred.POCtype);
g(1,2).set_layout_options('legend_position',[0.415 0.1 0.2 0.375]);
g(1,2).geom_line;
g(1,2).geom_hline('yintercept',0);
g(1,2).axe_property('YLim',[-20 40],'XTick',unique(mdl_1_3_pred.adjustment_angle_nominal));
g(1,2).set_names('x','Nominal adjustment angle [°]','y','Distance from via-sphere entry [mm]','color','');
g(1,2).set_title('POC CP & cone rel. to via-sphere entry');
g(1,2).set_color_options('map',[100,167,215;128 128 128]./255);
g(1,2).set_line_options('base_size',3,'styles',{'--'});
g(1,2).no_legend();

% POC cone rel. to POC CP
g(1,3) = gramm('x',trial_data2_3.adjustment_angle_nominal,'y',trial_data2_3.mean_poc_cone_cp_diff);
g(1,3).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1.7);
g(1,3).geom_hline('yintercept',0);
g(1,3).axe_property('YLim',[-20 40],'XTick',unique(trial_data2_3.adjustment_angle_nominal));
g(1,3).set_names('x','Nominal adjustment angle [°]','y','Distance from POC CP [mm]');
g(1,3).set_title('POC cone rel. to POC CP');
g(1,3).set_color_options('map',[0 0 0]);
g(1,3).set_line_options('base_size',2,'styles',{'-'});

g.set_stat_options('nboot',2000);
g.set_point_options('base_size',8);
g.set_text_options('base_size',12,'title_scaling',1.1667,'label_scaling',1.1667);
g.draw();


% Update runs to overlay the empirical data

% POC cone rel. to via-sphere entry
g(1,1).update('x',trial_data2_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data2_1.mean_poc3D_vel_rel2invia,...
    'subset',trial_data2_1.adjustment_angle_actual_bin_fixedEdge<90);
g(1,1).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1.45);
g(1,1).set_color_options('map',[0 0 0]);
g(1,1).set_line_options('base_size',2,'styles',{'-'});
g(1,1).draw();

% POC CP & cone rel. to via-sphere entry
g(1,2).update('x',trial_data2_2.adjustment_angle_nominal,'y',trial_data2_2.dec_p,'color',trial_data2_2.dec_p_type);
g(1,2).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1.7);
g(1,2).set_color_options('map',[49,131,189;0 0 0]./255);
g(1,2).set_line_options('base_size',2,'styles',{'-'});
g(1,2).draw();

g.export('export_path',fig_dir,'file_name','Figure_4DEF.pdf','file_type','pdf');


%% T-tests (Figure 4F) 

% With outlier
ttests = table();
ttests.adjustment_angle_nominal = unique(trial_data2_3.adjustment_angle_nominal);
[ttests.t,ttests.df,ttests.p] = deal(nan(height(ttests),1));

for i = 1:height(ttests)
    [h,p,ci,stats] = ttest(trial_data2_3.mean_poc_cone_cp_diff(...
        trial_data2_3.adjustment_angle_nominal==ttests.adjustment_angle_nominal(i)));
    
    ttests.t(i)  = stats.tstat;
    ttests.df(i) = stats.df;
    ttests.p(i)   = p;
end


% Without outlier
ttests2 = table();
ttests2.adjustment_angle_nominal = unique(trial_data2_3.adjustment_angle_nominal);
[ttests2.t,ttests2.df,ttests2.p] = deal(nan(height(ttests2),1));

for i = 1:height(ttests2)
    [h,p,ci,stats] = ttest(trial_data2_3.mean_poc_cone_cp_diff(...
        trial_data2_3.adjustment_angle_nominal==ttests.adjustment_angle_nominal(i)...
        & ~ trial_data2_3.isoutlier));
    
    ttests2.t(i)  = stats.tstat;
    ttests2.df(i) = stats.df;
    ttests2.p(i)   = p;
end

%% Supplementary Figure 5-2

trial_data2_1.subsample = cell(height(trial_data2_1),1);
trial_data2_1.subsample(trial_data2_1.subject_index<9) = {'1 - 8'};
trial_data2_1.subsample(trial_data2_1.subject_index>8) = {'9 - 16'};

cmap = [128 128 128
          0   0   0]./255;


clear g
figure('Units','centimeters','Position',[0 0 28/3 10])

% POC cone rel. to via-sphere entry
g = gramm('x',trial_data2_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data2_1.mean_poc3D_vel_rel2invia,...
    'color',trial_data2_1.subsample,'linestyle',trial_data2_1.subsample,...
    'subset',trial_data2_1.adjustment_angle_actual_bin_fixedEdge<90);
g.set_layout_options('legend_position',[0.7 0.1 0.2 0.4]);
g.stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1.5);
g.geom_hline('yintercept',0);
g.axe_property('YLim',[-20 40],'XTick',unique(trial_data2_1.adjustment_angle_actual_bin_fixedEdge));
g.set_names('x','Actual adjustment angle bin [°]','y','Distance from via-sphere entry [mm]','color','Subject');
g.set_title('POC cone rel. to via-sphere entry');
g.set_color_options('map',cmap);
g.set_line_options('base_size',2);

g.set_stat_options('nboot',2000);
g.set_point_options('base_size',8);
g.set_text_options('base_size',12,'title_scaling',1.1667,'label_scaling',1.1667);
g.draw();

g.export('export_path',fig_dir,'file_name','Figure_S5-2.pdf','file_type','pdf');
