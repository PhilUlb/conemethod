clear all
load('Exp1_data.mat')


%% Data preparation

trial_data.poc_cone_cp_diff = trial_data.poc3D_vel - trial_data.poc_cp_orig;


trial_data2_1 = grpstats(trial_data,{'subject_index','adjustment_angle_actual_bin_fixedEdge'},'mean','DataVars','poc3D_vel_rel2invia');

trial_data2_3 = grpstats(trial_data,{'subject_index','adjustment_angle_nominal'},'mean','DataVars',...
    {'poc_cp_orig_rel2invia','poc3D_vel_rel2invia','poc_cone_cp_diff'});

trial_data2_2 = stack(trial_data2_3,{'mean_poc_cp_orig_rel2invia','mean_poc3D_vel_rel2invia'},'IndexVariableName',...
    'dec_p_type','NewDataVariableName','dec_p');

trial_data2_2.dec_p_type = cellstr(trial_data2_2.dec_p_type);
trial_data2_2.dec_p_type(strcmp(trial_data2_2.dec_p_type,'mean_poc_cp_orig_rel2invia')) = {'POC CP'};
trial_data2_2.dec_p_type(strcmp(trial_data2_2.dec_p_type,'mean_poc3D_vel_rel2invia'))   = {'POC cone'};


%% Figure 4 DEF

clear g
figure('Units','centimeters','Position',[0 0 28 10])

for i = 1:3
    if i==1
        x = trial_data2_1.adjustment_angle_actual_bin_fixedEdge;
        y = trial_data2_1.mean_poc3D_vel_rel2invia;
        c = [];
        xl = 'Actual adjustment angle bin [°]';
        yl = 'Distance from via-sphere entry [mm]';
        tl = 'POC cone rel. to via-sphere entry';
        lp = [0 0 0 0];
    elseif i==2
        x = trial_data2_2.adjustment_angle_nominal;
        y = trial_data2_2.dec_p;
        c = trial_data2_2.dec_p_type;
        xl = 'Nominal adjustment angle [°]';
        yl = 'Distance from via-sphere entry [mm]';
        tl = 'POC CP & cone rel. to via-sphere entry';
        lp = [0.415 0.1 0.2 0.375];
    else
        x = trial_data2_3.adjustment_angle_nominal;
        y = trial_data2_3.mean_poc_cone_cp_diff;
        c = [];
        xl = 'Nominal adjustment angle [°]';
        yl = 'Distance from POC CP [mm]';
        tl = 'POC cone rel. to POC CP';
        lp = [0 0 0 0];
    end
    
       
    g(1,i) = gramm('x',x,'y',y,'color',c);
    g(1,i).set_layout_options('legend_position',lp);
    g(1,i).stat_summary('type','bootci','geom',{'line','point','errorbar'},'width',1);
    g(1,i).geom_hline('yintercept',0);
    g(1,i).axe_property('YLim',[-20 40],'XTick',unique(x));
    g(1,i).set_names('x',xl,'y',yl,'color','');
    g(1,i).set_title(tl);
end

g.set_color_options('map',[0 0 0;49,130,189]./255);
g.set_stat_options('nboot',2000);
g.set_order_options('color',-1);
g.set_line_options('base_size',2);
g.set_point_options('base_size',8);
g.set_text_options('base_size',12,'title_scaling',1.1667,'label_scaling',1.1667);
g.draw();
g.export('file_name','Figure_4DEF.pdf','file_type','pdf');



%% GLME1-2 (Figure 4D)

trial_data3 = trial_data2_1(trial_data2_1.adjustment_angle_actual_bin_fixedEdge>0 ...
    & trial_data2_1.adjustment_angle_actual_bin_fixedEdge<80,:);

model1_2 = fitglme(trial_data3,'mean_poc3D_vel_rel2invia ~adjustment_angle_actual_bin_fixedEdge + (adjustment_angle_actual_bin_fixedEdge|subject_index)');


%% GLME1-3 (Figure 4E)

model1_3_cone = fitglme(trial_data2_3,'mean_poc3D_vel_rel2invia   ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');
model1_3_cp   = fitglme(trial_data2_3,'mean_poc_cp_orig_rel2invia ~ adjustment_angle_nominal + (adjustment_angle_nominal|subject_index)');


%% T-tests (Figure 4F) 

ttests = table();
ttests.adjustment_angle_nominal = unique(trial_data2_3.adjustment_angle_nominal);
[ttests.t,ttests.df,ttests.p] = deal(nan(height(ttests),1));

for i = 1:height(ttests)
    [h,p,ci,stats] = ttest(trial_data2_3.mean_poc_cone_cp_diff(trial_data2_3.adjustment_angle_nominal==ttests.adjustment_angle_nominal(i)));
    
    ttests.t(i)  = stats.tstat;
    ttests.df(i) = stats.df;
    ttests.p(i)   = p;
end
