clear all
load('Exp1_data.mat')


%% Data preparation

trial_data2 = stack(trial_data,...
    {'poc3D_raw_inbounds','poc3D_tol_inbounds','poc3D_ovs_inbounds','poc3D_vel_inbounds','poc2D_vel_inbounds'},...
    'IndexVariableName','cone_type','NewDataVariableName','POC_inbounds');
trial_data2.cone_type = cellstr(trial_data2.cone_type);

trial_data2_1 = stack(trial_data,...
    {'poc3D_raw_tooearly','poc3D_tol_tooearly','poc3D_ovs_tooearly','poc3D_vel_tooearly','poc2D_vel_tooearly'},...
    'IndexVariableName','cone_type','NewDataVariableName','POC_early');

trial_data2_2 = stack(trial_data,...
    {'poc3D_raw_toolate','poc3D_tol_toolate','poc3D_ovs_toolate','poc3D_vel_toolate','poc2D_vel_toolate'},...
    'IndexVariableName','cone_type','NewDataVariableName','POC_late');

trial_data2.POC_early = trial_data2_1.POC_early;
trial_data2.POC_late  = trial_data2_2.POC_late;

clear trial_data2_1
clear trial_data2_2

trial_data2.cone_type(strcmp(trial_data2.cone_type,'poc3D_raw_inbounds')) = {'Cone raw'};
trial_data2.cone_type(strcmp(trial_data2.cone_type,'poc3D_tol_inbounds')) = {'Cone w/tolerance'};
trial_data2.cone_type(strcmp(trial_data2.cone_type,'poc3D_ovs_inbounds')) = {'Cone w/overshoot'};
trial_data2.cone_type(strcmp(trial_data2.cone_type,'poc3D_vel_inbounds')) = {'Cone w/speed'};
trial_data2.cone_type(strcmp(trial_data2.cone_type,'poc2D_vel_inbounds')) = {'Cone 2D'};


% sum_[...]_SA = sum of trials w/POC in-bounds/too early/too late per subject and actual adjustment angle bin
trial_data3 = grpstats(trial_data2,{'subject_index','adjustment_angle_actual_bin_fixedEdge','cone_type'},'sum',...
    'DataVars',{'POC_inbounds','POC_early','POC_late'});
trial_data3.Properties.VariableNames{'sum_POC_inbounds'} = 'sum_inbounds_SA';
trial_data3.Properties.VariableNames{'sum_POC_early'}    = 'sum_early_SA';
trial_data3.Properties.VariableNames{'sum_POC_late'}     = 'sum_late_SA';


% sum_[...]_S = sum as above, but aggregated across actual adjustment angle bins
trial_data3_1 = grpstats(trial_data2,{'subject_index','cone_type'},'sum',...
    'DataVars',{'POC_inbounds','POC_early','POC_late'});
trial_data3_1.Properties.VariableNames{'sum_POC_inbounds'} = 'sum_inbounds_S';
trial_data3_1.Properties.VariableNames{'sum_POC_early'}    = 'sum_early_S';
trial_data3_1.Properties.VariableNames{'sum_POC_late'}     = 'sum_late_S';


[trial_data3.sum_inbounds_S,trial_data3.sum_early_S,trial_data3.sum_late_S] = deal(nan(height(trial_data3),1));
for i = 1:height(trial_data3_1)
    sel = trial_data3.subject_index==trial_data3_1.subject_index(i) & strcmp(trial_data3.cone_type,trial_data3_1.cone_type(i));
    trial_data3.sum_inbounds_S(sel) = trial_data3_1.sum_inbounds_S(i);
    trial_data3.sum_early_S(sel)    = trial_data3_1.sum_early_S(i);
    trial_data3.sum_late_S(sel)     = trial_data3_1.sum_late_S(i);
end

trial_data3.sum_all_S  = trial_data3.sum_early_S  + trial_data3.sum_late_S  + trial_data3.sum_inbounds_S;  % trials per subject
trial_data3.sum_all_SA = trial_data3.sum_early_SA + trial_data3.sum_late_SA + trial_data3.sum_inbounds_SA; % trials per subject and actual adjustment angle bin

% Proportion of in-bounds/early/late POCs per bin relative to n trials in the respective bin
trial_data3.p_early_SA    = trial_data3.sum_early_SA    ./ trial_data3.sum_all_SA;
trial_data3.p_late_SA     = trial_data3.sum_late_SA     ./ trial_data3.sum_all_SA;
trial_data3.p_inbounds_SA = trial_data3.sum_inbounds_SA ./ trial_data3.sum_all_SA;

% Proportion of in-bounds/early/late POCs per bin relative to total n trials
trial_data3.p_early_S    = trial_data3.sum_early_SA    ./ trial_data3.sum_all_S;
trial_data3.p_late_S     = trial_data3.sum_late_SA     ./ trial_data3.sum_all_S;
trial_data3.p_inbounds_S = trial_data3.sum_inbounds_SA ./ trial_data3.sum_all_S;

% Proportion of trials per bin relative to total n trials
trial_data3.p_all_S = trial_data3.sum_all_SA ./ trial_data3.sum_all_S;


trial_data4_1 = stack(trial_data3,{'p_early_S','p_late_S','p_inbounds_S'},'IndexVariableName','poc_class','NewDataVariableName','pPOC_rel2all');
trial_data4_1.poc_class = cellstr(trial_data4_1.poc_class);
trial_data4_1.poc_class(strcmp(trial_data4_1.poc_class,'p_early_S'))    = {'POC too early'};
trial_data4_1.poc_class(strcmp(trial_data4_1.poc_class,'p_late_S'))     = {'POC too late'};
trial_data4_1.poc_class(strcmp(trial_data4_1.poc_class,'p_inbounds_S')) = {'POC in bounds'};

trial_data4_2 = stack(trial_data3,{'p_early_SA','p_late_SA','p_inbounds_SA'},'IndexVariableName','poc_class','NewDataVariableName','pPOC_rel2bin');
trial_data4_2.poc_class = cellstr(trial_data4_2.poc_class);
trial_data4_2.poc_class(strcmp(trial_data4_2.poc_class,'p_early_SA'))    = {'POC too early'};
trial_data4_2.poc_class(strcmp(trial_data4_2.poc_class,'p_late_SA'))     = {'POC too late'};
trial_data4_2.poc_class(strcmp(trial_data4_2.poc_class,'p_inbounds_SA')) = {'POC in bounds'};


% Overall (i.e. across bins) proportion of in-bounds/too early/too late POCs
trial_data3_1.p_inbounds = trial_data3_1.sum_inbounds_S./trial_data3_1.GroupCount;
trial_data3_1.p_early    = trial_data3_1.sum_early_S./trial_data3_1.GroupCount;
trial_data3_1.p_late     = trial_data3_1.sum_late_S./trial_data3_1.GroupCount;

trial_data4_3 = stack(trial_data3_1,{'p_inbounds','p_early','p_late'},'IndexVariableName','poc_class','NewDataVariableName','pPOC_overall');
trial_data4_3.poc_class = cellstr(trial_data4_3.poc_class);

trial_data4_3.poc_class(strcmp(trial_data4_3.poc_class,'p_inbounds')) = {'POC in bounds'};
trial_data4_3.poc_class(strcmp(trial_data4_3.poc_class,'p_early'))    = {'POC too early'};
trial_data4_3.poc_class(strcmp(trial_data4_3.poc_class,'p_late'))     = {'POC too late'};


%% GLME 1-1

models = table();
models.cone_type          = sort(repmat(unique(trial_data2.cone_type),3,1));
models.outofbound_type    = repmat({'inbounds';'early';'late'},height(models)/3,1);
models.model              = cell(height(models),1);
models.intercept_beta     = nan(height(models),1);
models.intercept_lb       = nan(height(models),1);
models.intercept_ub       = nan(height(models),1);
models.intercept_p        = nan(height(models),1);
models.intercept_rand_std = nan(height(models),1);
models.poc_beta           = nan(height(models),1);
models.poc_lb             = nan(height(models),1);
models.poc_ub             = nan(height(models),1);
models.poc_p              = nan(height(models),1);
models.poc_rand_std       = nan(height(models),1);

models_cv = models; % Table for cross-validation (see below)

% All data
for i = 1:height(models)
    if strcmp(models.outofbound_type(i),'inbounds')
        trial_data2.outcome_var = trial_data2.POC_inbounds;
    elseif strcmp(models.outofbound_type(i),'early')
        trial_data2.outcome_var = trial_data2.POC_early;
    else
        trial_data2.outcome_var = trial_data2.POC_late;
    end
    
    sel = strcmp(trial_data2.cone_type,models.cone_type(i));
    
    models.model{i} = fitglme(trial_data2(sel,:),...
        'outcome_var ~adjustment_angle_actual + (adjustment_angle_actual|subject_index)','distribution','Binomial');
    
    % Extract the fixed effects
    models.intercept_beta(i) = models.model{i}.Coefficients{1,2};
    models.intercept_lb(i)   = models.model{i}.Coefficients{1,7};
    models.intercept_ub(i)   = models.model{i}.Coefficients{1,8};
    models.intercept_p(i)    = models.model{i}.Coefficients{1,6};
    models.poc_beta(i)       = models.model{i}.Coefficients{2,2};
    models.poc_lb(i)         = models.model{i}.Coefficients{2,7};
    models.poc_ub(i)         = models.model{i}.Coefficients{2,8};
    models.poc_p(i)          = models.model{i}.Coefficients{2,6};
    
    % Extract the random effects
    [~,~,stats] = covarianceParameters(models.model{i});
    models.intercept_rand_std(i)...
        = stats{1}.Estimate(strcmp(stats{1}.Name1,'(Intercept)') & strcmp(stats{1}.Type,'std'));
    models.poc_rand_std(i)...
        = stats{1}.Estimate(strcmp(stats{1}.Name1,'adjustment_angle_actual') & strcmp(stats{1}.Type,'std'));
end


%% Separate models for subjects 1-8 and 9-16

models_cv = vertcat(models_cv,models_cv);
h = height(models_cv);
models_cv.subjects              = repmat([1  8],h,1);
models_cv.subjects(h/2+1:end,:) = repmat([9 16],h/2,1);

for i = 1:height(models_cv)
    if strcmp(models_cv.outofbound_type(i),'inbounds')
        trial_data2.outcome_var = trial_data2.POC_inbounds;
    elseif strcmp(models_cv.outofbound_type(i),'early')
        trial_data2.outcome_var = trial_data2.POC_early;
    else
        trial_data2.outcome_var = trial_data2.POC_late;
    end
    
    sel = strcmp(trial_data2.cone_type,models_cv.cone_type(i))...
        & trial_data2.subject_index>=models_cv.subjects(i,1)...
        & trial_data2.subject_index<=models_cv.subjects(i,2);
    
    models_cv.model{i} = fitglme(trial_data2(sel,:),...
        'outcome_var ~adjustment_angle_actual + (adjustment_angle_actual|subject_index)','distribution','Binomial');
    
    % Extract the fixed effects
    models_cv.intercept_beta(i) = models_cv.model{i}.Coefficients{1,2};
    models_cv.intercept_lb(i)   = models_cv.model{i}.Coefficients{1,7};
    models_cv.intercept_ub(i)   = models_cv.model{i}.Coefficients{1,8};
    models_cv.intercept_p(i)    = models_cv.model{i}.Coefficients{1,6};
    models_cv.poc_beta(i)       = models_cv.model{i}.Coefficients{2,2};
    models_cv.poc_lb(i)         = models_cv.model{i}.Coefficients{2,7};
    models_cv.poc_ub(i)         = models_cv.model{i}.Coefficients{2,8};
    models_cv.poc_p(i)          = models_cv.model{i}.Coefficients{2,6};
    
    % Extract the random effects
    [~,~,stats] = covarianceParameters(models_cv.model{i});
    models_cv.intercept_rand_std(i)...
        = stats{1}.Estimate(strcmp(stats{1}.Name1,'(Intercept)') & strcmp(stats{1}.Type,'std'));
    models_cv.poc_rand_std(i)...
        = stats{1}.Estimate(strcmp(stats{1}.Name1,'adjustment_angle_actual') & strcmp(stats{1}.Type,'std'));
end



%% GLME 1-1 predictions for Figure 4 ABC

unique_outofbound_type = unique(models.outofbound_type,'stable');
for i = 1:length(unique_outofbound_type)
    tmp_tbl = table();
    tmp_tbl.adjustment_angle_actual...
        = linspace(min(trial_data.adjustment_angle_actual),max(trial_data.adjustment_angle_actual),100)';
    tmp_tbl.subject_index = ones(height(tmp_tbl),1); % Dummy variable since only the marginal effects are fitted
    tmp_tbl.outofbound_type = repmat(unique_outofbound_type(i),height(tmp_tbl),1);
    
    tmp_tbl.pPOCfit...
        = predict(models.model{strcmp(models.cone_type,'Cone w/speed') & strcmp(models.outofbound_type,unique_outofbound_type(i))},...
        tmp_tbl,'Conditional',0);
    
    if i==1
        model_predict = tmp_tbl;
    else
        model_predict = vertcat(model_predict,tmp_tbl);
    end
end

model_predict(model_predict.adjustment_angle_actual>80,:) = []; % We only display data for the bins up to 80


%% Figure 4 ABC
% Note: Y-axis labels only valid for line plot (proportion of in-bounds/too
% early/too late trials relative to n trials per bin). Appropriate Y-axis
% labels for the bar plot are plotted Y-axis labels/4 and were added during
% post-processing outside of Matlab.

% Figure 4D in "Exp1_poc_location_analyses.m"

cmap_outofbounds  = [ 77 175  74
                     152  78 163
                     255 127   0]./255;
cmap_outofbounds2 = [128 200 125
                     184 125 193
                     255 165  46]./255;

clear g
figure('Units','centimeters','Position',[0 0 28 10])

% Gray bar plot (mean proportion of trials per bin)
g = gramm('x',trial_data4_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_1.p_all_S*4,... % *4 for scaling
    'subset',strcmp(trial_data4_1.cone_type,'Cone w/speed') & trial_data4_1.adjustment_angle_actual_bin_fixedEdge<90);
g.set_layout_options('legend_position',[0.815 0.6 0.2 0.4]);
g.stat_summary('type','sem','geom','bar','width',0.7);
g.axe_property('XTick',0:10:80,'XTickLabelRotation',45,'YLim',[0 1],'YTick',[0 0.5 1]);
g.facet_grid([],trial_data4_1.poc_class);
g.set_names('x','Actual adjustment angle bin [�]','y','Proportion of trials','column','','row','','color','');
g.set_color_options('map',[0.7 0.7 0.7]);
g.set_text_options('base_size',14,'label_scaling',1,'facet_scaling',1,'legend_scaling',1);
g.draw();

% Black bar plot (mean n in-bounds/too early/too late trials per bin, relative to total n trials)
g.update('x',trial_data4_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_1.pPOC_rel2all*4,... % *4 for scaling
    'subset',strcmp(trial_data4_1.cone_type,'Cone w/speed') & trial_data4_1.adjustment_angle_actual_bin_fixedEdge<90);
g.stat_summary('type','sem','geom','bar','width',0.7);
g.set_color_options('map',[0 0 0]);
g.set_line_options('base_size',2);
g.set_point_options('base_size',8);
g.draw();

% GLME fits
g.update('x',model_predict.adjustment_angle_actual,'y',model_predict.pPOCfit,'color',model_predict.outofbound_type);
g.geom_line();
g.facet_grid([],model_predict.outofbound_type);
g.set_order_options('column',[2 1 3],'color',[2 1 3]);
g.set_color_options('map',cmap_outofbounds2);
g.set_line_options('base_size',3,'styles',{'--'});
g.no_legend();
g.draw();

% Colored line plot (proportion of in-bounds/too early/too late trials relative to n trials per bin)
g.update('x',trial_data4_2.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_2.pPOC_rel2bin,...
    'color',trial_data4_2.poc_class,'subset',strcmp(trial_data4_1.cone_type,'Cone w/speed') & trial_data4_2.adjustment_angle_actual_bin_fixedEdge<90);
g.stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1.2);
g.facet_grid([],trial_data4_1.poc_class);
g.set_order_options('column',1,'color',1);
g.set_color_options('map',cmap_outofbounds);
g.set_line_options('base_size',2,'styles',{'-'});
g.set_stat_options('nboot',2000);
g.draw();

g.export('file_name','Figure_4ABC.pdf','file_type','pdf');


%% Supplementary Figure 1-1 A
% Figure 4 ABC note regarding Y-axis labels also applies here.

clear g
figure('Units','centimeters','Position',[0 0 28 18])

% Gray bar plot (mean proportion of trials per bin)
g = gramm('x',trial_data4_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_1.p_all_S*4,...
    'subset',trial_data4_1.adjustment_angle_actual_bin_fixedEdge<90);
g.set_layout_options('legend_position',[0.785 0.185 0.2 0.2]);
g.stat_summary('type','sem','geom','bar','width',0.7);
g.axe_property('XTick',0:10:100,'XTickLabelRotation',45,'YLim',[0 1],'YTick',[0 0.5 1]);
g.facet_grid(trial_data4_1.poc_class,trial_data4_1.cone_type);
g.set_names('x','Actual adjustment angle bin [�]','y','Proportion of trials','column','','row','','color','');
g.set_color_options('map',[0.7 0.7 0.7]);
g.set_order_options('column',[2 5 3 4 1]);
g.set_text_options('base_size',10,'label_scaling',1.4,'facet_scaling',1.4,'legend_scaling',1);
g.draw();

% Black bar plot (mean n in-bounds/too early/too late trials per bin, relative to total n trials)
g.update('x',trial_data4_1.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_1.pPOC_rel2all*4,...  % *4 for scaling
    'subset',trial_data4_1.adjustment_angle_actual_bin_fixedEdge<90);
g.stat_summary('type','sem','geom','bar','width',0.7);
g.set_color_options('map',[0 0 0]);
g.draw();

% Colored line plot (proportion of in-bounds/too early/too late trials relative to n trials per bin)
g.update('x',trial_data4_2.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_2.pPOC_rel2bin,...
    'color',trial_data4_2.poc_class,'subset',trial_data4_2.adjustment_angle_actual_bin_fixedEdge<90);
g.stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',2);
g.set_color_options('map',cmap_outofbounds);
g.set_line_options('base_size',2);
g.set_stat_options('nboot',2000);
g.draw();
g.export('file_name','Figure_S1-1A.pdf','file_type','pdf');





%% Supplementary Figure 1-1 B
% Note: Significance markers added in post-processing outside of Matlab

clear g
figure('Units','centimeters','Position',[0 0 28 10])
for i = 1:3
    switch i
        case 1
            sel = strcmp(trial_data4_3.poc_class,'POC in bounds');
            yl = [0.7 1];
        case 2
            sel = strcmp(trial_data4_3.poc_class,'POC too early');
            yl = [0 0.15];
        case 3
            sel = strcmp(trial_data4_3.poc_class,'POC too late');
            yl = [0 0.15];
    end
    
    g(1,i) = gramm('x',trial_data4_3.cone_type,'y',trial_data4_3.pPOC_overall,'subset',sel);
    g(1,i).stat_summary('type','bootci','geom','bar');
    g(1,i).stat_summary('type','bootci','geom','black_errorbar','width',1.1);
    g(1,i).axe_property('YLim',yl,'XTickLabelRotation',45);
    g(1,i).set_color_options('map',cmap_outofbounds(i,:));
    g(1,i).set_title(unique(trial_data4_3.poc_class(sel)));
    
end

g.set_names('x','','y','Proportion of trials');
g.set_text_options('base_size',14,'title_scaling',1);
g.set_line_options('base_size',2);
g.set_stat_options('nboot',2000);
g.set_order_options('x',[2 5 3 4 1]);
g.draw();
g.export('file_name','Figure_S1-1B.pdf','file_type','pdf');


%% Wilcoxon signed rank tests for Supplementary Figure 1-1 B

wsr_results = table();
wsr_results.smpl1 = {'Cone raw'         'Cone w/tolerance' 'Cone w/overshoot' 'Cone w/speed'}';
wsr_results.smpl2 = {'Cone w/tolerance' 'Cone w/overshoot' 'Cone w/speed'     'Cone 2D'}';
[wsr_results.pval_inbounds,wsr_results.pval_early,wsr_results.pval_late] = deal(nan(height(wsr_results),1));

for i = 1:height(wsr_results)
    smpl1_sel = strcmp(trial_data3_1.cone_type,wsr_results.smpl1(i));
    smpl2_sel = strcmp(trial_data3_1.cone_type,wsr_results.smpl2(i));
    
    for j = 1:3
        switch j
            case 1
                smpl1 = trial_data3_1.p_inbounds(smpl1_sel);
                smpl2 = trial_data3_1.p_inbounds(smpl2_sel);
                wsr_results.pval_inbounds(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
            case 2
                smpl1 = trial_data3_1.p_early(smpl1_sel);
                smpl2 = trial_data3_1.p_early(smpl2_sel);
                wsr_results.pval_early(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
            case 3
                smpl1 = trial_data3_1.p_late(smpl1_sel);
                smpl2 = trial_data3_1.p_late(smpl2_sel);
                wsr_results.pval_late(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
        end
    end
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%
% Cross validation figures %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Supplementary Figure 5-1 A
% Figure 4 ABC note regarding Y-axis labels also applies here.

cmap_outofbounds3  = [128 200 125
                       77 175  74
                      184 125 193
                      152  78 163
                      255 165  46
                      255 127   0]./255;


trial_data4_2.subsample = cell(height(trial_data4_2),1);
trial_data4_2.subsample(trial_data4_2.subject_index<9) = {'1 - 8'};
trial_data4_2.subsample(trial_data4_2.subject_index>8) = {'9 - 16'};

clear g
figure('Units','centimeters','Position',[0 0 28 18])
g = gramm('x',trial_data4_2.adjustment_angle_actual_bin_fixedEdge,'y',trial_data4_2.pPOC_rel2bin,...
    'color',trial_data4_2.poc_class,'lightness',trial_data4_2.subsample,'linestyle',trial_data4_2.subsample,...
    'subset',trial_data4_2.adjustment_angle_actual_bin_fixedEdge<90);
g.set_layout_options('legend_position',[0.785 0.185 0.2 0.2]);
g.stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',12,'dodge',1);
g.axe_property('XTick',0:10:100,'XTickLabelRotation',45,'YLim',[0 1],'YTick',[0 0.5 1]);
g.facet_grid(trial_data4_2.poc_class,trial_data4_2.cone_type);
g.set_names('x','Actual adjustment angle bin [�]','y','Proportion of trials','column','','row','',...
    'color','');
g.set_color_options('map',cmap_outofbounds3,'n_color',3,'n_lightness',2,'legend','expand');
g.set_order_options('column',[2 5 3 4 1]);
g.set_line_options('base_size',2);
g.set_text_options('base_size',10,'label_scaling',1.4,'facet_scaling',1.4,'legend_scaling',1);
g.set_stat_options('nboot',2000);
g.draw();
g.export('file_name','Figure_S5-1A.pdf','file_type','pdf');


%% Supplementary Figure 5-1 B

trial_data4_3.subsample = cell(height(trial_data4_3),1);
trial_data4_3.subsample(trial_data4_3.subject_index<9) = {'1 - 8'};
trial_data4_3.subsample(trial_data4_3.subject_index>8) = {'9 - 16'};

clear g
figure('Units','centimeters','Position',[0 0 28 10])
for i = 1:3
    switch i
        case 1
            sel = strcmp(trial_data4_3.poc_class,'POC in bounds');
            yl = [0.7 1];
            cmap = cmap_outofbounds3(1:2,:);
        case 2
            sel = strcmp(trial_data4_3.poc_class,'POC too early');
            yl = [0 0.2];
            cmap = cmap_outofbounds3(3:4,:);
        case 3
            sel = strcmp(trial_data4_3.poc_class,'POC too late');
            yl = [0 0.2];
            cmap = cmap_outofbounds3(5:6,:);
    end
    
    g(1,i) = gramm('x',trial_data4_3.cone_type,'y',trial_data4_3.pPOC_overall,'color',trial_data4_3.subsample,...
        'subset',sel);
    g(1,i).stat_summary('type','bootci','geom','bar','dodge',0.8);
    g(1,i).stat_summary('type','bootci','geom','black_errorbar','dodge',0.8,'width',1.15);
    g(1,i).axe_property('YLim',yl,'XTickLabelRotation',45);
    g(1,i).set_color_options('map',cmap);
    g(1,i).set_title(unique(trial_data4_3.poc_class(sel)));
    g(1,i).no_legend();
    
end

g.set_names('x','','y','Proportion of trials','color','Subject');
g.set_text_options('base_size',14,'title_scaling',1);
g.set_line_options('base_size',2);
g.set_stat_options('nboot',2000);
g.set_order_options('x',[2 5 3 4 1]);
g.draw();

g.export('file_name','Figure_S5-1B.pdf','file_type','pdf');


%% Wilcoxon signed rank tests for Supplementary Figure 5-1 B

wsr_results_cv = table();
wsr_results_cv.smpl1 = {'Cone raw'         'Cone w/tolerance' 'Cone w/overshoot' 'Cone w/speed'}';
wsr_results_cv.smpl2 = {'Cone w/tolerance' 'Cone w/overshoot' 'Cone w/speed'     'Cone 2D'}';
[wsr_results_cv.pval_inbounds,wsr_results_cv.pval_early,wsr_results_cv.pval_late] = deal(nan(height(wsr_results_cv),1));

wsr_results_cv = vertcat(wsr_results_cv,wsr_results_cv);
wsr_results_cv.subsample = sort(repmat([1 8;9 16],4,1));


for i = 1:height(wsr_results_cv)
    subsample_sel = trial_data3_1.subject_index>=wsr_results_cv.subsample(i,1)...
                  & trial_data3_1.subject_index<=wsr_results_cv.subsample(i,2);
    smpl1_sel = subsample_sel & strcmp(trial_data3_1.cone_type,wsr_results_cv.smpl1(i));
    smpl2_sel = subsample_sel & strcmp(trial_data3_1.cone_type,wsr_results_cv.smpl2(i));
    
    for j = 1:3
        switch j
            case 1
                smpl1 = trial_data3_1.p_inbounds(smpl1_sel);
                smpl2 = trial_data3_1.p_inbounds(smpl2_sel);
                wsr_results_cv.pval_inbounds(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
            case 2
                smpl1 = trial_data3_1.p_early(smpl1_sel);
                smpl2 = trial_data3_1.p_early(smpl2_sel);
                wsr_results_cv.pval_early(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
            case 3
                smpl1 = trial_data3_1.p_late(smpl1_sel);
                smpl2 = trial_data3_1.p_late(smpl2_sel);
                wsr_results_cv.pval_late(i) = signrank(smpl1,smpl2,'alpha',0.025,'method','exact');
        end
    end
end