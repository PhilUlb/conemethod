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
cmap = [241,105,19
        82,82,82
       150,150,150]./255;
   
clear g
figure('Units','centimeters','Position',[0 0 28 13.2])

g(1) = gramm('x',trial_data2.soa_plus_screendelay,'y',trial_data2.early_poc_p,'color',trial_data2.early_poc_type);
g(1).set_layout_options('position',[0 0 1/3 1],'legend_position',[0.07 0.8 0.255 0.25]);
g(1).stat_summary('type','bootci','geom',{'bar'},'dodge',0.7,'width',0.7);
g(1).stat_summary('type','bootci','geom',{'black_errorbar'},'dodge',0.7,'width',2);
g(1).axe_property('XLim',[18 428],'XTick',[43:60:403],'YLim',[0 0.8],'YTick',[0:0.2:0.8]);
g(1).set_names('x','Value cue SOA [ms]','y','Proportion of trials','color','');
g(1).set_color_options('map',cmap);

% POC cone & CP
for i = 2:3
    if i==2
        y  = trial_data3.mean_toc2D_vel_rel2gocue;
        p  = [1/3 0 1/3 1];
        pl = [1/3+0.08 0.8 0.2 0.2];
        yl = 'TOC cone rel. to go cue [ms]';
    else
        y  = trial_data3.mean_toc_cp_orig_rel2gocue;
        p  = [2/3 0 1/3 1];
        yl = 'TOC CP rel. to go cue [ms]';
    end
    
    g(i) = gramm('x',trial_data3.soa_plus_screendelay,'y',y,'color',trial_data3.nonzero_outcome);
    if i==2
        g(i).set_layout_options('position',p,'legend_position',pl);
    else
        g(i).set_layout_options('position',p);
        g(i).no_legend();
    end
    
    g(i).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
    g(i).axe_property('DataAspectRatio',[1 1 1],'XTick',[43:60:403],'YLim',[150 800]);
    g(i).set_names('x','Value cue SOA [ms]','y',yl,'color','Nonzero outcome [€ ct]');
    g(i).set_color_options('map',[77,175,74;82,82,82]./255);
    g(i).set_order_options('color',-1);
    g(i).set_line_options('base_size',2);
    g(i).set_point_options('base_size',8);
end

g.set_stat_options('nboot',2000);
g.set_text_options('base_size',14,'facet_scaling',1,'legend_scaling',0.9,'legend_title_scaling',0.9);
g.draw();

% Reaction times
for i = 2:3
    g(i).update('x',trial_data3.soa_plus_screendelay,'y',trial_data3.mean_reaction_time,'color',trial_data3.nonzero_outcome);
    g(i).stat_summary('type','bootci','geom',{'line','point','errorbar'},'dodge',0.2,'width',2);
    g(i).no_legend();
    g(i).set_color_options('map',([77,175,74;82,82,82]./255));
    g(i).set_order_options('color',-1);
    g(i).set_line_options('base_size',1,'styles',{'--'});
    g(i).set_point_options('base_size',6);
    g(i).draw();
end
g.export('file_name','Figure_5BCD.pdf','file_type','pdf');


%% GLME2-1

% Early POC proportions
trial_data4 = grpstats(trial_data,{'subject_index','soa_plus_screendelay'},'sum','DataVars',...
    {'toc2D_vel_pre_mvt','toc2D_vel_pre_soa','toc2D_vel_allearly'});


model_premov = fitglme(trial_data4,...
    'sum_toc2D_vel_pre_mvt ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)',...
    'BinomialSize',trial_data4.GroupCount,'distribution','Binomial');

model_preSOA = fitglme(trial_data4,...
    'sum_toc2D_vel_pre_soa ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)',...
    'BinomialSize',trial_data4.GroupCount,'distribution','Binomial');

model_preAll = fitglme(trial_data4,...
    'sum_toc2D_vel_allearly ~ soa_plus_screendelay + (soa_plus_screendelay|subject_index)',...
    'BinomialSize',trial_data4.GroupCount,'distribution','Binomial');


%% GLME2-2

trial_data5 = grpstats(trial_data(trial_data.optimal_choice==1,:),{'subject_index','soa_plus_screendelay','nonzero_outcome'},...
    'mean','DataVars',{'toc2D_vel_rel2gocue','toc_cp_orig_rel2gocue'});

% Categorical nonzero outcome variable
trial_data5.frame = cell(height(trial_data5),1);
trial_data5.frame(trial_data5.nonzero_outcome<0) = {'loss'};
trial_data5.frame(trial_data5.nonzero_outcome>0) = {'gain'};


% TOC cone
model_TOC_cone_ME = fitglme(trial_data5,...
    'mean_toc2D_vel_rel2gocue ~ frame+soa_plus_screendelay + (frame+soa_plus_screendelay|subject_index)');
model_TOC_cone_IA = fitglme(trial_data5,...
    'mean_toc2D_vel_rel2gocue ~ frame*soa_plus_screendelay + (frame*soa_plus_screendelay|subject_index)');

% TOC CP
model_TOC_CP_ME = fitglme(trial_data5,...
    'mean_toc_cp_orig_rel2gocue ~ frame+soa_plus_screendelay + (frame+soa_plus_screendelay|subject_index)');
model_TOC_CP_IA = fitglme(trial_data5,...
    'mean_toc_cp_orig_rel2gocue ~ frame*soa_plus_screendelay + (frame*soa_plus_screendelay|subject_index)');
