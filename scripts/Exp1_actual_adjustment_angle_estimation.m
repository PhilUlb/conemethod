clear all
load('Exp1_data.mat')


clr_map_dir = [166,206,227
                31,120,180
               178,223,138
                51,160, 44]./255;
            
clr_map_dir2 = [mean(clr_map_dir(1:2,:));mean(clr_map_dir(3:4,:))];


%% Estimate the actual adjustment angle

% pre_adj_tang_i:   hpos index of the point the pre-adjustment tangent line is fitted to
% post_adj_tang_i:  hpos index of the point the post-adjustment tangent line is fitted to
% pre_adj_tang:     pre-adjustment tangent line
% post_adj_tang:    post-adjustment tangent line


% 1st derivative of rotated trajectory
hpos_y_2D_3_drv = cellfun(@(x,y) diff([nan; y'])./diff([nan; x']),...
    hand_data.hpos_xy_2D_3(:,1),hand_data.hpos_xy_2D_3(:,2),'uni',0);

% 2nd derivative, magnified 10x for better visibility
hpos_y_2D_3_drv2 = cellfun(@(y) diff([nan; y]).*10,...
    hpos_y_2D_3_drv,'uni',0);


trial_data.adjustment_angle_actual = nan(height(trial_data),1);
pre_adj_tang_i  = nan(height(trial_data),1);
post_adj_tang_i = nan(height(trial_data),1);



for i = 1:height(trial_data)
    % Hand data selection
    px   = hand_data.hpos_xy_2D_3{i,1};
    py   = hand_data.hpos_xy_2D_3{i,2};
    py_d = hpos_y_2D_3_drv{i};
    py_d2 = hpos_y_2D_3_drv2{i};

    % Closest trajectory peak to via-sphere center
    [~,tmp_pks] = findpeaks(py);
    [~,tmp_i]   = min(abs(tmp_pks-trial_data.via_center_i(i)));
    curve_peak  = tmp_pks(tmp_i);
    
    % Local min/max pointing at zero in 2nd derivative
    [~,tmp_pks_max] = findpeaks(py_d2);
    tmp_pks_max(py_d2(tmp_pks_max)>0) = []; % Only keep local maxima below zero
    [~,tmp_pks_min] = findpeaks(-py_d2);
    tmp_pks_min(py_d2(tmp_pks_min)<0) = []; % Only keep local minima above zero
    py_dv2_pks = sort([tmp_pks_max;tmp_pks_min]);
    
    
    % Closest inflection point on positive slope (1st derivative maximum) left of trajectory peak -> pre-adjustment tangent
    [~,tmp_pks]        = findpeaks(py_d);
    pre_adj_tang_i_tmp = tmp_pks(find(tmp_pks<curve_peak,1,'last'));
    
    if ~isempty(pre_adj_tang_i_tmp) % If present --> place tangent point and be done
        pre_adj_tang_i(i) = pre_adj_tang_i_tmp;
        
    else % If no inflection point, pick point left of trajectory peak where 2nd derivative closest to zero (first available datapoint not considered because placing the tangent points at the very start/end of the trajectory usually overestimates the actual adjustment angle
        pre_adj_tang_i_tmp = py_dv2_pks(py_dv2_pks<curve_peak);
        if ~isempty(pre_adj_tang_i_tmp)
            pre_adj_tang_i(i) = find(abs(py_d2)==min(abs(py_d2(pre_adj_tang_i_tmp))));
        else % If the point where 2nd derivative is closest to zero is the first datapoint, place tangent point halfway between start and trajectory peak (reason for this: prev. comment)
            pre_adj_tang_i(i) = round(curve_peak/2);
        end
    end
        
    
    % % Closest inflection point on negative slope (1st derivative minimum) right of trajectory peak -> post-adjustment tangent
    [~,tmp_pks]         = findpeaks(-py_d);
    post_adj_tang_i_tmp = tmp_pks(find(tmp_pks>curve_peak,1,'first'));
    
    if ~isempty(post_adj_tang_i_tmp) % If present --> place tangent point and be done
        post_adj_tang_i(i) = post_adj_tang_i_tmp;
        
    else % If no inflection point, pick point right of trajectory peak where 2nd derivative closest to zero
        post_adj_tang_i_tmp = py_dv2_pks(py_dv2_pks>curve_peak);
        if ~isempty(post_adj_tang_i_tmp)
            post_adj_tang_i(i) = find(abs(py_d2)==min(abs(py_d2(post_adj_tang_i_tmp))));
        else % If the point where 2nd derivative is closest to zero is the last datapoint, place tangent point halfway between trajectory peak and last datapoint
            post_adj_tang_i(i) = curve_peak + round((length(px)-curve_peak)/2);
        end
    end
    
    % Compute the tangents to determine the AAA
    dy = [nan diff(py)./diff(px)]; % redundant to py_d, but in old version we computed this separately as well (making py_d, but not dy wrong)
    pre_adj_tang = (px-px(pre_adj_tang_i(i)))*dy(pre_adj_tang_i(i))+py(pre_adj_tang_i(i));
    
    % Rotate trajectory such that pre-adjustment tangent lies on x axis
    theta = -atan2d(pre_adj_tang(end)-pre_adj_tang(1),px(end)-px(1));
    p_r  = my_axe_rotation([px' py' zeros(length(px),1)],theta,'z');
    px_r = p_r(:,1);
    py_r = p_r(:,2);
    
    % Post-adjustment tangent recalculated after trajectory rotation
    dy = [nan; diff(py_r)./diff(px_r)];
    post_adj_tang = (px_r-px_r(post_adj_tang_i(i)))*dy(post_adj_tang_i(i))+py_r(post_adj_tang_i(i));
    
    % Actual adjustment angle = angle between post-adjustment tangent (fitted to rotated trajectory) and x axis
    trial_data.adjustment_angle_actual(i) = 180-atan2d(post_adj_tang(1)-post_adj_tang(end),px_r(1)-px_r(end));
    if trial_data.adjustment_angle_actual(i)>180
        trial_data.adjustment_angle_actual(i) = trial_data.adjustment_angle_actual(i)-180;
    end
end


%% Actual adjustment angle binning

% Binning: fixed edges, variable N 
edges = 0:10:120;
trial_data.adjustment_angle_actual_bin_fixedEdge = discretize(trial_data.adjustment_angle_actual,edges);

for i = 1:height(trial_data)
    trial_data.adjustment_angle_actual_bin_fixedEdge(i) = edges(trial_data.adjustment_angle_actual_bin_fixedEdge(i));
end


%% Supplementary Figure 3-1 ABC

sel_ind = [2412 8320];


for i = 1:length(sel_ind)
    sel = trial_data.index==sel_ind(i);
    
    clear g
    figure('Units','centimeters','Position',[0 1 28 18])
    
    g(1) = gramm('x',hand_data.hpos_xy_2D_1(:,1),'y',hand_data.hpos_xy_2D_1(:,2),'subset',sel);
    g(1).set_layout_options('position',[0 0 0.5 1]);
    g(1).geom_line();
    g(1).axe_property('DataAspectRatio',[1 1 1],'XLim',[-80 40],'YLim',[-20 180],'XTick',-100:20:100,'YTick',-20:20:200);
    g(1).set_names('x','Lateral deviation [mm]','y','Distance-from-start [mm]');
    g(1).set_line_options('base_size',4);
    g(1).set_color_options('map',[0 0 0]);
    
    g(2) = gramm('x',hand_data.hpos_xy_2D_3(:,1),'y',hand_data.hpos_xy_2D_3(:,2),'subset',sel);
    g(2).set_layout_options('position',[0.5 0.5 0.5 0.5]);
    g(2).geom_line();
    g(2).axe_property('DataAspectRatio',[1 1 1],'XLim',[-20 180],'YLim',[-30 80],'XTick',-20:20:200,'YTick',-40:20:100);
    g(2).set_names('x','Rotated position [mm]','y','Rotated position [mm]');
    g(2).set_line_options('base_size',4);
    g(2).set_color_options('map',[0 0 0]);
    
    g(3) = gramm('x',hand_data.hpos_xy_2D_3(:,1),'y',hpos_y_2D_3_drv,'subset',sel);
    g(3).set_layout_options('position',[0.5 0 0.5 0.5]);
    g(3).geom_line();
    g(3).axe_property('XLim',[-20 180],'XTick',-20:20:200,'YTick',-1:0.2:1);
    g(3).set_names('x','Rotated position [mm]','y','Rotated position derivative');
    g(3).set_line_options('base_size',2);
    g(3).set_color_options('map',[0.5 0.5 0.5]);
    
    % Target polygons
    for j = 1:2
        if j==1
            fix_center_x   = 0;
            fix_center_y   = 0;
            via_center_x = 0;
            via_center_y = trial_data.start_via_dist(sel);
            tgt_center_x   = trial_data.target_xy_pos_2D_1(sel,1);
            tgt_center_y   = trial_data.target_xy_pos_2D_1(sel,2); % mirrored?
        else
            fix_center_x   = trial_data.start_pos_2D_3(sel,1);
            fix_center_y   = trial_data.start_pos_2D_3(sel,2);
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
    g.draw();
    
    % 2nd derivative
    g(3).update('x',hand_data.hpos_xy_2D_3(:,1),'y',hpos_y_2D_3_drv2,'subset',sel);
    g(3).set_layout_options('position',[0.5 0 0.5 0.5]);
    g(3).geom_line();
    g(3).geom_hline('yintercept',0);
    g(3).set_color_options('map',[0 0 0]);
    g(3).draw();

    
    % Tangent lines
    for j = 1:3
        switch j
            case 1
                px = hand_data.hpos_xy_2D_1{sel,1};
                py = hand_data.hpos_xy_2D_1{sel,2};
            case 2
                px = hand_data.hpos_xy_2D_3{sel,1};
                py = hand_data.hpos_xy_2D_3{sel,2};
            case 3
                px    = hand_data.hpos_xy_2D_3{sel,1};
                py    = hpos_y_2D_3_drv{sel};
                py_d2 = hpos_y_2D_3_drv2{sel}; % only used if 2nd derivative criterion used
        end
        
        if j<3
            dy = [nan diff(py)./diff(px)];
            
            t1 = ((-200:200)-px(pre_adj_tang_i(sel))) *dy(pre_adj_tang_i(sel)) +py(pre_adj_tang_i(sel));
            t2 = ((-200:200)-px(post_adj_tang_i(sel)))*dy(post_adj_tang_i(sel))+py(post_adj_tang_i(sel));
            
            g(j).update('x',[{-200:200} {-200:200}],'y',[{t1} {t2}]);
            g(j).geom_line();
            g(j).set_color_options('map',[222,45,38]./255);
            g(j).set_line_options('base_size',2);
            g(j).draw();
        end
        
        % Tangent points
        g(j).update('x',[px(pre_adj_tang_i(sel)) px(post_adj_tang_i(sel))],'y',[py(pre_adj_tang_i(sel)) py(post_adj_tang_i(sel))]);
        g(j).geom_point();
        g(j).set_color_options('map',[222,45,38]./255);
        if j==3
            g(j).set_point_options('base_size',8);
        else
            g(j).set_point_options('base_size',10);
        end
        g(j).draw();
        
        % Tangent points on 2nd derivative
        if j==3
            g(j).update('x',[px(pre_adj_tang_i(sel)) px(post_adj_tang_i(sel))],'y',[py_d2(pre_adj_tang_i(sel)) py_d2(post_adj_tang_i(sel))]);
            g(j).geom_point();
            g(j).set_color_options('map',[222,45,38]./255);
            g(j).set_point_options('base_size',8);
            g(j).draw();
        end
    end
    
    g.export('file_name',['FigS3-1_idx' num2str(sel_ind(i)) '.pdf'],'file_type','pdf');
end


%% Supplementary Figure 3-2 A

clear g
figure('Units','centimeters','Position',[0 0 28 16])
g = gramm('x',trial_data.adjustment_angle_nominal,'y',trial_data.adjustment_angle_actual,...
    'color',trial_data.target_direction);
g.set_layout_options('legend_position',[0.15 0.65 0.2 0.3]);
g.stat_boxplot();
g.geom_abline('intercept',0,'slope',1);
g.axe_property('XTick',unique(trial_data.adjustment_angle_nominal),'YLim',[0 120],'XLim',[14 58]);
g.set_color_options('map',clr_map_dir);
g.set_names('x','Nominal adjustment angle [°]','y','Actual adjustment angle [°]','color','Target direction [°]');
g.set_text_options('base_size',14);
g.draw();

g.export('file_name','Figure_S3-2A.pdf','file_type','pdf');


%% Supplementary Figure 3-2 BC

is_lower_tgt = trial_data.target_direction>180;
trial_data.target_directionUD = cell(height(trial_data),1);
trial_data.target_directionUD(~is_lower_tgt) = {' 45° & 135° (upper)'};
trial_data.target_directionUD( is_lower_tgt) = {'225° & 315° (lower)'};

fig_data = stack(trial_data,{'adjustment_angle_nominal','adjustment_angle_actual_bin_fixedEdge'},...
    'IndexVariableName','adjustment_angle_type','NewDataVariableName','adjustment_angle');
fig_data = grpstats(fig_data,{'subject_index','adjustment_angle_type','adjustment_angle','target_directionUD'},...
    'mean','DataVars','poc3D_vel_tooearly');
fig_data.adjustment_angle_type = cellstr(fig_data.adjustment_angle_type);


%%

clear g
figure('Units','centimeters','Position',[0 0 28 22])

for j = 1:2
    if j==1
        sel = strcmp(fig_data.adjustment_angle_type,'adjustment_angle_nominal');
        lpos = [0.7 0.7 0.3 0.3];
        width = 0.8;
        xlbl = 'Nominal adjustment angle [°]';
    else
        sel = strcmp(fig_data.adjustment_angle_type,'adjustment_angle_actual_bin_fixedEdge')...
            & fig_data.adjustment_angle<70 ...
            & ~(fig_data.adjustment_angle==0 & strcmp(fig_data.target_directionUD,' 45° & 135° (upper)'));
        lpos = [-1 -1 0.2 0.2];
        width = 0.8*0.382; % 0.382 = error bar end caps scaling factor: (smallest_subplot_1_width/2) / (subplot_2_width/2)
        xlbl = 'Actual adjustment angle [°]';
    end
    
    g(j,1) = gramm('x',fig_data.adjustment_angle,'y',fig_data.mean_poc3D_vel_tooearly,'color',fig_data.target_directionUD,...
        'subset',sel);
    g(j,1).set_layout_options('legend_position',lpos);
    g(j,1).stat_summary('type','bootci','geom',{'bar','black_errorbar'},'width',width,'dodge',width);
    g(j,1).axe_property('YLim',[0 0.6],'XLim',[-3 62],'XTick',unique(fig_data.adjustment_angle(sel)));
    g(j,1).set_names('x',xlbl,'y','P(too-early-POC)','color','Target direction');
    
end

g.set_text_options('base_size',14);
g.set_stat_options('nboot',2000);
g.set_color_options('map',clr_map_dir2);
g.draw();
g.export('file_name','FigS3-2BC.pdf','file_type','pdf');


%% Store the actual adjustment angle + bin

trial_data = trial_data(:,sort(trial_data.Properties.VariableNames));
save('Exp1_data.mat','-append','trial_data');

