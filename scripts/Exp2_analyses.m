clear all
load('Exp2_data.mat')


%% Data preparation


trial_data.toc2D_vel_allearly = trial_data.toc2D_vel_pre_soa | trial_data.toc2D_vel_pre_mvt;

trial_data.toc_class_lbl = cell(height(trial_data),1);

trial_data.toc_class_lbl(trial_data.toc2D_vel_pre_mvt==1) = {'TOC at mvt. onset'};
trial_data.toc_class_lbl(trial_data.toc2D_vel_pre_mvt==0) = {'TOC after mvt. onset'};


trial_data2 = grpstats(trial_data,{'subject_index','soa_plus_screendelay'},'mean','DataVars',...
    {'toc2D_vel_pre_mvt','toc2D_vel_pre_soa','toc2D_vel_allearly'});

trial_data2 = stack(trial_data2,{'mean_toc2D_vel_pre_mvt','mean_toc2D_vel_pre_soa','mean_toc2D_vel_allearly'},...
    'IndexVariableName','early_poc_type','NewDataVariableName','early_poc_p');
trial_data2.early_poc_type = cellstr(trial_data2.early_poc_type);

trial_data2.early_poc_type(strcmp(trial_data2.early_poc_type,'mean_toc2D_vel_pre_mvt'))...
    = {'TOC at mvt. onset'};
trial_data2.early_poc_type(strcmp(trial_data2.early_poc_type,'mean_toc2D_vel_pre_soa'))...
    = {'TOC pre value cue onset'};
trial_data2.early_poc_type(strcmp(trial_data2.early_poc_type,'mean_toc2D_vel_allearly'))...
    = {'All early TOC'};


trial_data3 = grpstats(trial_data(trial_data.optimal_choice==1,:),{'subject_index','soa_plus_screendelay','nonzero_outcome'},...
    'mean','DataVars',{'toc2D_vel_rel2gocue','toc_cp_orig_rel2gocue','reaction_time'});


%% GLME2-1

model_premov = fitglme(trial_data,...
    'toc2D_vel_pre_mvt ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)','distribution','Binomial');

model_preSOA = fitglme(trial_data,...
    'toc2D_vel_pre_soa ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)','distribution','Binomial');

model_preAll = fitglme(trial_data,...
    'toc2D_vel_allearly ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)','distribution','Binomial');

% Model predictions for plotting
for i = 1:3
    tmp_tbl = table();
    tmp_tbl.soa_plus_screendelay = unique(trial_data.soa_plus_screendelay);
    tmp_tbl.subject_index = ones(height(tmp_tbl),1); % Dummy variable since only the marginal effects are fitted
    
    if i==1
        tmp_tbl.TOCtype = repmat({'TOC at mvt. onset'},height(tmp_tbl),1);
        tmp_tbl.TOCfit = predict(model_premov,tmp_tbl,'Conditional',0);
        mdl_2_1_pred = tmp_tbl;
    elseif i==2
        tmp_tbl.TOCtype = repmat({'TOC pre value cue onset'},height(tmp_tbl),1);
        tmp_tbl.TOCfit = predict(model_preSOA,tmp_tbl,'Conditional',0);
        mdl_2_1_pred = vertcat(mdl_2_1_pred,tmp_tbl);
    else
        tmp_tbl.TOCtype = repmat({'All early TOC'},height(tmp_tbl),1);
        tmp_tbl.TOCfit = predict(model_preAll,tmp_tbl,'Conditional',0);
        mdl_2_1_pred = vertcat(mdl_2_1_pred,tmp_tbl);
    end
end

%% GLME2-2

% Categorical nonzero outcome variable
trial_data.frame = cell(height(trial_data),1);
trial_data.frame(trial_data.nonzero_outcome<0) = {'loss'};
trial_data.frame(trial_data.nonzero_outcome>0) = {'gain'};


% TOC cone
model_TOC_cone_ME = fitglme(trial_data,...
    'toc2D_vel_rel2gocue ~ frame+soa_plus_screendelay + (frame+soa_plus_screendelay|subject_index)');
model_TOC_cone_IA = fitglme(trial_data,...
    'toc2D_vel_rel2gocue ~ frame*soa_plus_screendelay + (frame*soa_plus_screendelay|subject_index)');


% Aggregate data for TOC CP model (as there is only one actual datapoint per subject x frame x soa)
trial_data5 = grpstats(trial_data(trial_data.optimal_choice==1,:),{'subject_index','soa_plus_screendelay','frame'},...
    'mean','DataVars','toc_cp_orig_rel2gocue');

% TOC CP
model_TOC_CP_ME = fitglme(trial_data5,...
    'mean_toc_cp_orig_rel2gocue ~ frame+soa_plus_screendelay + (frame+soa_plus_screendelay|subject_index)');
model_TOC_CP_IA = fitglme(trial_data5,...
    'mean_toc_cp_orig_rel2gocue ~ frame*soa_plus_screendelay + (frame*soa_plus_screendelay|subject_index)');


%%
% Model predictions for plotting
for i = 1:2
    tmp_tbl = table();
    tmp_tbl.soa_plus_screendelay = sort(repmat(unique(trial_data.soa_plus_screendelay),2,1));
    tmp_tbl.frame = repmat({'gain';'loss'},height(tmp_tbl)/2,1);
    tmp_tbl.subject_index = ones(height(tmp_tbl),1); % Dummy variable since only the marginal effects are fitted
    
    if i==1
        tmp_tbl.TOCtype = repmat({'TOC cone'},height(tmp_tbl),1);
        tmp_tbl.TOCfit = predict(model_TOC_cone_IA,tmp_tbl,'Conditional',0);
        mdl_2_2_pred = tmp_tbl;
    else
        tmp_tbl.TOCtype = repmat({'TOC CP'},height(tmp_tbl),1);
        tmp_tbl.TOCfit = predict(model_TOC_CP_ME,tmp_tbl,'Conditional',0);
        mdl_2_2_pred = vertcat(mdl_2_2_pred,tmp_tbl);
    end
end


%% Figure 5

% Figure 5A
clear g
figure('Units','centimeters','Position',[0 0 28 11])
g = gramm('x',hand_data.hpos(:,1),'y',hand_data.hpos(:,2),'color',trial_data.chosen_direction,...
   'subset',trial_data.subject_index==4);
g.geom_line();
g.facet_grid(trial_data.toc_class_lbl,trial_data.soa_plus_screendelay);
g.axe_property('DataAspectRatio',[1 1 1]);
g.set_line_options('base_size',1);
g.set_names('x','Lateral deviation [mm]','y','Distance-from-start [mm]','row','','column','');
g.set_color_options('map',[82,82,82;49,130,189]./255);
g.no_legend();
g.set_text_options('base_size',14,'facet_scaling',1,'legend_scaling',0.9,'legend_title_scaling',0.9);
g.draw();
g.export('file_name','Figure_5A.pdf','file_type','pdf');


% Figure 5 BCD
cmap1 = [217, 72,  1
           0,  0,  0
           8, 81,156]./255;
cmap2 = [253,141, 60
         128,128,128
          66,146,198]./255;
   
clear g
figure('Units','centimeters','Position',[0 0 28 13.2])

g(1) = gramm('x',mdl_2_1_pred.soa_plus_screendelay,'y',mdl_2_1_pred.TOCfit,'color',mdl_2_1_pred.TOCtype);
g(1).set_layout_options('position',[0 0 1/3 1],'legend_position',[0.07 0.8 0.255 0.25]);
g(1).geom_line('dodge',0.2);
g(1).axe_property('XLim',[18 428],'XTick',[43:60:403],'YLim',[0 0.8],'YTick',[0:0.2:0.8]);
g(1).set_names('x','Value cue SOA [ms]','y','Proportion of trials','color','');
g(1).set_color_options('map',cmap2);
g(1).no_legend();

g(2) = gramm('x',mdl_2_2_pred.soa_plus_screendelay,'y',mdl_2_2_pred.TOCfit,'color',mdl_2_2_pred.frame,...
    'subset',strcmp(mdl_2_2_pred.TOCtype,'TOC cone'));
g(2).set_layout_options('position',[1/3 0 1/3 1],'legend_position',[1/3+0.08 0.8 0.2 0.2]);
g(2).geom_line('dodge',0.2);
g(2).axe_property('DataAspectRatio',[1 1 1],'XTick',[43:60:403],'YLim',[150 800]);
g(2).set_names('x','Value cue SOA [ms]','y','TOC cone rel. to go cue [ms]','color','Nonzero outcome [€ ct]');
g(2).set_color_options('map',[116,196,118;128,128,128]./255);
g(2).no_legend();

g(3) = gramm('x',mdl_2_2_pred.soa_plus_screendelay,'y',mdl_2_2_pred.TOCfit,'color',mdl_2_2_pred.frame,...
    'subset',strcmp(mdl_2_2_pred.TOCtype,'TOC CP'));
g(3).set_layout_options('position',[2/3 0 1/3 1]);
g(3).geom_line('dodge',0.2);
g(3).axe_property('DataAspectRatio',[1 1 1],'XTick',[43:60:403],'YLim',[150 800]);
g(3).set_names('x','Value cue SOA [ms]','y','TOC CP rel. to go cue [ms]','color','Nonzero outcome [€ ct]');
g(3).set_color_options('map',[116,196,118;128,128,128]./255);
g(3).no_legend();

g.set_line_options('base_size',3,'styles',{'--'});
g.set_point_options('base_size',8);
g.set_stat_options('nboot',2000);
g.set_text_options('base_size',14,'facet_scaling',1,'legend_scaling',0.9,'legend_title_scaling',0.9);
g.draw();

% Update run 1: data
g(1).update('x',trial_data2.soa_plus_screendelay,'y',trial_data2.early_poc_p,'color',trial_data2.early_poc_type);
g(1).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
g(1).set_line_options('base_size',2,'styles',{'-'});
g(1).set_color_options('map',cmap1);
g(1).draw();

g(2).update('x',trial_data3.soa_plus_screendelay,'y',trial_data3.mean_toc2D_vel_rel2gocue,'color',trial_data3.nonzero_outcome);
g(2).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
g(2).set_color_options('map',[0,0,0;35,139,69]./255);
g(2).set_line_options('base_size',2,'styles',{'-'});
g(2).draw();

g(3).update('x',trial_data3.soa_plus_screendelay,'y',trial_data3.mean_toc_cp_orig_rel2gocue,'color',trial_data3.nonzero_outcome);
g(3).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
g(3).set_color_options('map',[0,0,0;35,139,69]./255);
g(3).set_line_options('base_size',2,'styles',{'-'});
g(3).draw();


% Reaction times
for i = 2:3
    g(i).update('x',trial_data3.soa_plus_screendelay,'y',trial_data3.mean_reaction_time,'color',trial_data3.nonzero_outcome);
    g(i).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
    g(i).no_legend();
    g(i).set_color_options('map',[0,0,0;35,139,69]./255);
    g(i).set_line_options('base_size',1,'styles',{'--'});
    g(i).set_point_options('base_size',6);
    g(i).draw();
end
g.export('file_name','Figure_5BCD.pdf','file_type','pdf');

