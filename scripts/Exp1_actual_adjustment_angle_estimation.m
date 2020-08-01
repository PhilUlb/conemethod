clear all
load('Exp1_data.mat')


%% Estimate the actual adjustment angle

% pre_adj_tang_i:   hpos index of the point the pre-adjustment tangent line is fitted to
% post_adj_tang_i:  hpos index of the point the post-adjustment tangent line is fitted to
% pre_adj_tang:     pre-adjustment tangent line
% post_adj_tang:    post-adjustment tangent line

hpos_y_2D_3_drv = cellfun(@(x) diff([nan; x']),hand_data.hpos_xy_2D_3(:,2),'uni',0);

trial_data.adjustment_angle_actual = nan(height(trial_data),1);
pre_adj_tang_i  = nan(height(trial_data),1);
post_adj_tang_i = nan(height(trial_data),1);


for i = 1:height(trial_data)
    
    px   = hand_data.hpos_xy_2D_3{i,1};
    py   = hand_data.hpos_xy_2D_3{i,2};
    py_d = hpos_y_2D_3_drv{i};
    
    % Closest trajectory peak to via-sphere center
    [~,tmp_pks] = findpeaks(py);
    [~,tmp_i]   = min(abs(tmp_pks-trial_data.via_center_i(i)));
    curve_peak  = tmp_pks(tmp_i);
    
    % Closest derivative maximum left of trajectory peak -> pre-adjustment tangent
    [~,tmp_pks]        = findpeaks(py_d);
    pre_adj_tang_i_tmp = tmp_pks(find(tmp_pks<curve_peak,1,'last'));
    if ~isempty(pre_adj_tang_i_tmp)
        pre_adj_tang_i(i) = pre_adj_tang_i_tmp;
    else
        pre_adj_tang_i(i) = 1; % If no derivative peak present, pre-adjustment tangent fitted to first sampling point
    end
    
    dy = diff(py)./diff(px);
    pre_adj_tang = (px-px(pre_adj_tang_i(i)))*dy(pre_adj_tang_i(i))+py(pre_adj_tang_i(i));
    
    
    % Closest derivative minimum right of trajectory peak -> post-adjustment tangent
    [~,tmp_pks]         = findpeaks(-py_d);
    post_adj_tang_i_tmp = tmp_pks(find(tmp_pks>curve_peak,1,'first'));
    if ~isempty(post_adj_tang_i_tmp)
        post_adj_tang_i(i) = post_adj_tang_i_tmp;
    else
        post_adj_tang_i(i) = length(px)-1; % If no derivative peak present, post-adjustment tangent fitted to last sampling point -1 (-1 because we don't have the tangent slope dy for the last sampling point)
    end
    
    %post_adj_tang = (px-px(post_adj_tang_i(i)))*dy(post_adj_tang_i(i))+py(post_adj_tang_i(i));
    
    
    % Rotate trajectory such that pre-adjustment tangent lies on x axis
    theta = -atan2d(pre_adj_tang(end)-pre_adj_tang(1),px(end)-px(1));
    p_r  = my_axe_rotation([px' py' zeros(length(px),1)],theta,'z');
    px_r = p_r(:,1);
    py_r = p_r(:,2);
    
    % Post-adjustment tangent recalculated after trajectory rotation
    dy = diff(py_r)./diff(px_r);
    post_adj_tang = (px_r-px_r(post_adj_tang_i(i)))*dy(post_adj_tang_i(i))+py_r(post_adj_tang_i(i));
    
    % Actual adjustment angle = angle between post-adjustment tangent (fitted to rotated trajectory) and x axis
    trial_data.adjustment_angle_actual(i) = 180-atan2d(post_adj_tang(1)-post_adj_tang(end),px_r(1)-px_r(end));
    if trial_data.adjustment_angle_actual(i)>180
        trial_data.adjustment_angle_actual(i) = trial_data.adjustment_angle_actual(i)-180;
    end
end


%% Actual adjustment angle binning

% Binning: fixed edges, variable N 
edges = 0:10:100;
trial_data.adjustment_angle_actual_bin_fixedEdge = discretize(trial_data.adjustment_angle_actual,edges);

for i = 1:height(trial_data)
    trial_data.adjustment_angle_actual_bin_fixedEdge(i) = edges(trial_data.adjustment_angle_actual_bin_fixedEdge(i));
end


%% Supplementary Figure 3-1 ABC

sel = trial_data.index==2412;

clear g
figure('Units','centimeters','Position',[0 1 28 16])

g(1) = gramm('x',hand_data.hpos_xy_2D_1(:,1),'y',hand_data.hpos_xy_2D_1(:,2),'subset',sel);
g(1).set_layout_options('position',[0 0 0.5 1]);
g(1).geom_line();
g(1).axe_property('DataAspectRatio',[1 1 1],'XLim',[-80 80],'YLim',[-15 175],'XTick',-100:20:100,'YTick',-20:20:200);
g(1).set_names('x','Lateral deviation [mm]','y','Distance-from-start [mm]');

g(2) = gramm('x',hand_data.hpos_xy_2D_3(:,1),'y',hand_data.hpos_xy_2D_3(:,2),'subset',sel);
g(2).set_layout_options('position',[0.5 0.5 0.5 0.5]);
g(2).geom_line();
g(2).axe_property('DataAspectRatio',[1 1 1],'XLim',[-10 180],'YLim',[-30 55],'XTick',-20:20:200,'YTick',-40:20:100);
g(2).set_names('x','Rotated position [mm]','y','Rotated position [mm]');

g(3) = gramm('x',hand_data.hpos_xy_2D_3(:,1),'y',hpos_y_2D_3_drv,'subset',sel);
g(3).set_layout_options('position',[0.5 0 0.5 0.5]);
g(3).geom_line();
g(3).axe_property('XLim',[-10 180],'XTick',-20:20:200,'YTick',-1:0.2:1);
g(3).set_names('x','Rotated position [mm]','y','Rotated position derivative');

% Target polygons
for j = 1:2
    if j==1
        fix_center_x   = 0;
        fix_center_y   = 0;
        via_center_x = 0;
        via_center_y = trial_data.start_via_dist(sel);
        tgt_center_x   = trial_data.target_xy_pos_2D_2(sel,1);
        tgt_center_y   = trial_data.target_xy_pos_2D_2(sel,2); % mirrored?
    else
        fix_center_x   = 0; % MUST BE REPLACED W/ trial_data.fixpoint_pos_rot3
        fix_center_y   = 0;
        via_center_x = trial_data.via_xy_pos_2D_3(sel,1);
        via_center_y = trial_data.via_xy_pos_2D_3(sel,2);
        tgt_center_x   = trial_data.target_xy_pos_2D_3(sel,1);
        tgt_center_y   = trial_data.target_xy_pos_2D_3(sel,2);
    end
    
    % Polygon fixpoint
    fix_x = {fix_center_x + trial_data.start_diameter(sel)/2 * cos(linspace(0,2*pi,50))};
    fix_y = {fix_center_y + trial_data.start_diameter(sel)/2 * sin(linspace(0,2*pi,50))};
    g(j).geom_polygon('x',fix_x,'y',fix_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    
    % Polygon intermediate target
    inter_tgt_x = {via_center_x + trial_data.via_diameter(sel)/2 * cos(linspace(0,2*pi,50))};
    inter_tgt_y = {via_center_y + trial_data.via_diameter(sel)/2 * sin(linspace(0,2*pi,50))};
    g(j).geom_polygon('x',inter_tgt_x,'y',inter_tgt_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    
    % Polygon reference target
    ref_tgt_x = {tgt_center_x + trial_data.target_diameter(sel)/2 * cos(linspace(0,2*pi,50))};
    ref_tgt_y = {tgt_center_y + trial_data.target_diameter(sel)/2 * sin(linspace(0,2*pi,50))};
    g(j).geom_polygon('x',ref_tgt_x,'y',ref_tgt_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
end


g.set_text_options('base_size',14);
g.set_line_options('base_size',4);
g.set_color_options('map',[0 0 0]);
g.draw();


% Tangent lines
for i = 1:3
    switch i
        case 1
            px = hand_data.hpos_xy_2D_1{sel,1};
            py = hand_data.hpos_xy_2D_1{sel,2};
        case 2
            px = hand_data.hpos_xy_2D_3{sel,1};
            py = hand_data.hpos_xy_2D_3{sel,2};
        case 3
            px = hand_data.hpos_xy_2D_3{sel,1};
            py = hpos_y_2D_3_drv{sel};
    end
    
    if i<3
        dy = diff(py)./diff(px);
        
        t1 = ((-200:200)-px(pre_adj_tang_i(sel))) *dy(pre_adj_tang_i(sel)) +py(pre_adj_tang_i(sel));
        t2 = ((-200:200)-px(post_adj_tang_i(sel)))*dy(post_adj_tang_i(sel))+py(post_adj_tang_i(sel));
        
        g(i).update('x',[{-200:200} {-200:200}],'y',[{t1} {t2}]);
        g(i).geom_line();
        g(i).set_color_options('map',[222,45,38]./255);
        g(i).set_line_options('base_size',2);
        g(i).draw();
    end
    
    g(i).update('x',[px(pre_adj_tang_i(sel)) px(post_adj_tang_i(sel))],'y',[py(pre_adj_tang_i(sel)) py(post_adj_tang_i(sel))]);
    g(i).geom_point();
    g(i).set_color_options('map',[222,45,38]./255);
    g(i).set_point_options('base_size',10);
    g(i).draw();
end

g.export('file_name','Figure_S3-1ABC.pdf','file_type','pdf');


%% Supplementary Figure 3-1 D

clr_map_dir = [166,206,227
                31,120,180
               178,223,138
                51,160, 44]./255;

clear g
figure('Units','centimeters','Position',[0 0 28 14])
g = gramm('x',trial_data.adjustment_angle_nominal,'y',trial_data.adjustment_angle_actual,...
    'color',trial_data.target_direction);
g.set_layout_options('legend_position',[0.8 0.125 0.2 0.3]);
g.stat_boxplot();
g.geom_abline('intercept',0,'slope',1);
g.axe_property('XTick',unique(trial_data.adjustment_angle_nominal),'YLim',[0 100],'XLim',[14 58]);
g.set_color_options('map',clr_map_dir);
g.set_names('x','Nominal adjustment angle [°]','y','Actual adjustment angle [°]','color','Target direction [°]');
g.set_text_options('base_size',14);
g.draw();

g.export('file_name','Figure_S3-1D.pdf','file_type','pdf');



%% Supplementary Figure 3-2

load ('Exp1_cone_data.mat');

fig_data = trial_data;

fig_data.poc3D_vel_tooearly = cone_data.poc3D_vel_tooearly;

is_lower_tgt = trial_data.target_direction>180;
fig_data.target_directionUD = cell(height(fig_data),1);
fig_data.target_directionUD(~is_lower_tgt) = {' 45° & 135° (upper)'};
fig_data.target_directionUD( is_lower_tgt) = {'225° & 315° (lower)'};

fig_data = stack(fig_data,{'adjustment_angle_nominal','adjustment_angle_actual_bin_fixedEdge'},...
    'IndexVariableName','adjustment_angle_type','NewDataVariableName','adjustment_angle');

fig_data = grpstats(fig_data,{'subject_index','adjustment_angle_type','adjustment_angle','target_directionUD'},...
    'mean','DataVars','poc3D_vel_tooearly');

fig_data.adjustment_angle_type = cellstr(fig_data.adjustment_angle_type);





clr_map_dir2 = [mean(clr_map_dir(1:2,:));mean(clr_map_dir(3:4,:))];


clear g
figure('Units','centimeters','Position',[0 0 28 20])

for i = 1:2
    if i==1
        sel = strcmp(fig_data.adjustment_angle_type,'adjustment_angle_nominal');
        lpos = [0.7 0.7 0.3 0.3];
        width = 0.8;
        xlbl = 'Nominal adjustment angle [°]';
    else
        sel = strcmp(fig_data.adjustment_angle_type,'adjustment_angle_actual_bin_fixedEdge') & fig_data.adjustment_angle<60;
        lpos = [-1 -1 0.2 0.2];
        width = 0.8*0.382; % 0.382 = error bar end caps scaling factor: (smallest_subplot_1_width/2) / (subplot_2_width/2)
        xlbl = 'Actual adjustment angle [°]';
    end
    
    g(i,1) = gramm('x',fig_data.adjustment_angle,'y',fig_data.mean_poc3D_vel_tooearly,'color',fig_data.target_directionUD,...
        'subset',sel);
    g(i,1).set_layout_options('legend_position',lpos);
    g(i,1).stat_summary('type','bootci','geom',{'bar','black_errorbar'},'width',width,'dodge',width);
    g(i,1).axe_property('YLim',[0 0.35],'XLim',[7 58],'XTick',unique(fig_data.adjustment_angle(sel)));
    g(i,1).set_names('x',xlbl,'y','P(too-early-POC)','color','Target direction');

end

g.set_text_options('base_size',14);
g.set_stat_options('nboot',2000);
g.set_color_options('map',clr_map_dir2);
g.draw();


g.export('file_name','Figure_S3-2.pdf','file_type','pdf');


%% Store the actual adjustment angle + bin

trial_data = trial_data(:,sort(trial_data.Properties.VariableNames));

save('Exp1_data.mat','-append','trial_data');

