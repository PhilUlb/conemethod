clear all
load('Exp1_data.mat')
load('Exp1_cone_data.mat')


%% Figure 3A

cmap_outofbounds = [ 77 175  74
                    152  78 163
                    255 127   0]./255;
                

poc3D_vel_inbounds_lbl = cell(height(trial_data),1);
poc3D_vel_inbounds_lbl(trial_data.poc3D_vel_inbounds) = {'POC in bounds'};
poc3D_vel_inbounds_lbl(trial_data.poc3D_vel_tooearly) = {'POC too early'};
poc3D_vel_inbounds_lbl(trial_data.poc3D_vel_toolate)  = {'POC too late'};


% Plot the POCs in an actual adjustment angle range from 0 to 100°
max_act_adj_angle = 100;


% Add 100/200 to all adjustment angles in the 80mm/100mm via-sphere distance
% condition to plot all three via-sphere distance conditions in one plot
trial_data.adjustment_angle_actual2 = nan(height(trial_data),1);

sv_dist = unique(trial_data.start_via_dist);

for i = 1:length(sv_dist)
    sel = trial_data.start_via_dist==sv_dist(i);
    trial_data.adjustment_angle_actual2(sel) = trial_data.adjustment_angle_actual(sel) + (i-1)*max_act_adj_angle;
end


% Coordinates of the dashed lines marking the center of the via-spheres
via_center_x1 = {[0 max_act_adj_angle] [max_act_adj_angle 2*max_act_adj_angle] [2*max_act_adj_angle 3*max_act_adj_angle]};
via_center_y1 = {[sv_dist(1) sv_dist(1)] [sv_dist(2) sv_dist(2)] [sv_dist(3) sv_dist(3)]};

via_center_x2 = {[50 70] [70 90] [90 110]};
via_center_y2 = {[sv_dist(1) sv_dist(1)] [sv_dist(2) sv_dist(2)] [sv_dist(3) sv_dist(3)]};


% Coordinates of the grey boxes marking the expansion of the via-spheres
% along the distance-from-start axis
via_rad = 0.5*unique(trial_data.via_diameter);

via_poly_x1 = {nan(4,1) nan(4,1) nan(4,1)};
via_poly_y1 = via_poly_x1;

via_poly_x2 = via_poly_x1;

for i = 1:length(sv_dist)
    via_poly_x1{i}(1) = max_act_adj_angle*(i-1);
    via_poly_x1{i}(2) = max_act_adj_angle*(i);
    via_poly_x1{i}(3) = max_act_adj_angle*(i);
    via_poly_x1{i}(4) = max_act_adj_angle*(i-1);
    
    via_poly_y1{i}(1) = sv_dist(i)-via_rad;
    via_poly_y1{i}(2) = sv_dist(i)-via_rad;
    via_poly_y1{i}(3) = sv_dist(i)+via_rad;
    via_poly_y1{i}(4) = sv_dist(i)+via_rad;
    
    via_poly_x2{i}(1) = sv_dist(i)-10;
    via_poly_x2{i}(2) = sv_dist(i)+10;
    via_poly_x2{i}(3) = sv_dist(i)+10;
    via_poly_x2{i}(4) = sv_dist(i)-10;
end

via_poly_y2 = via_poly_y1;


% Draw the figure
clear g
figure('Units','centimeters','Position',[0 0 56 28])

g(1) = gramm('x',via_center_x1,'y',via_center_y1);
g(1).set_layout_options('position',[0 0 0.725 1],'legend_position',[0.1 0.825 0.175 0.2]);
g(1).geom_polygon('x',via_poly_x1,'y',via_poly_y1,'color',[1 1 1].*0.9,'alpha',1);
g(1).geom_line();
g(1).geom_vline('xintercept',[100 200],'extent',300,'style','k-');
g(1).axe_property('YLim',[0 130],'YTick',0:25:125,'XTick',0:20:300,'XLim',[-3 300],...
    'XTickLabel',[0:20:100 20:20:100 20:20:100]);
g(1).set_names('x','Actual adjustment angle [°]','y','Distance-from-start [mm]','color','');
g(1).set_color_options('map',[0 0 0]);

g(2) = gramm('x',via_center_x2,'y',via_center_y2);
g(2).geom_polygon('x',via_poly_x2,'y',via_poly_y2,'color',[1 1 1].*0.9,'alpha',1);
g(2).geom_line();
g(2).set_layout_options('position',[0.7 0 0.3 1]);
g(2).axe_property('XTick',[60 80 100],'XLim',[49 110],'YTick',0:25:125,'YTickLabel',[],'YLim',[0 130]);
g(2).set_color_options('map',[0 0 0]);
g(2).set_names('x','Via-sphere distance [mm]','y',[]);


g.set_line_options('base_size',2,'styles',{'--'});
g.set_point_options('base_size',6);
g.set_text_options('base_size',28,'label_scaling',1,'legend_scaling',1);
g.draw();

g(1).update('x',trial_data.adjustment_angle_actual2,'y',trial_data.poc3D_vel,'color',poc3D_vel_inbounds_lbl);
g(1).geom_point();
g(1).set_color_options('map',cmap_outofbounds);
g(1).draw();

g(2).update('x',trial_data.start_via_dist,'y',trial_data.poc3D_vel);
g(2).stat_boxplot();
g(2).set_color_options('map',[0.6 0.6 0.6]);
g(2).draw();

g.export('file_name','Figure_3A.pdf','file_type','pdf');


%% Figure 3B

cmap_dir = [0.3863 0.6392 0.7980
             0.4490 0.7510 0.3569];
         

% Pre-selection of trials shown in Figure 3B
selind = [
        168
        2938
         512
        1719
        1043
        3522
        2094
        2049
        2632
        1507
         756
         382];

% 1 = POC in bounds, 2 = POC too early (used as row index for subplots) 
poc_class = [
     1
     2
     1
     1
     1
     2
     2
     2
     1
     1
     2
     2];


% Data selection
sel = ismember(trial_data.index,selind);
td_subs = trial_data(sel,:);
hd_subs = hand_data(sel,:);


% Start-/via-/target-sphere polygon coordinates
[td_subs.poly_fix_x,td_subs.poly_fix_y,td_subs.poly_via_x,td_subs.poly_via_y,td_subs.poly_tgt_x,td_subs.poly_tgt_y]...
    = deal(cell(height(td_subs),1));

for i = 1:height(td_subs)
    td_subs.poly_fix_x(i) = {0 + td_subs.start_diameter(i)/2 * cos(linspace(0,2*pi,50))};
    td_subs.poly_fix_y(i) = {0 + td_subs.start_diameter(i)/2 * sin(linspace(0,2*pi,50))};
    
    td_subs.poly_via_x(i) = {td_subs.start_via_dist(i) + td_subs.via_diameter(i)/2 * cos(linspace(0,2*pi,50))};
    td_subs.poly_via_y(i) = {                                   0 + td_subs.via_diameter(i)/2 * sin(linspace(0,2*pi,50))};

    td_subs.poly_tgt_x(i) = {td_subs.target_xy_pos_2D_1(i,1) + td_subs.target_diameter(i)/2 * cos(linspace(0,2*pi,50))};
    td_subs.poly_tgt_y(i) = {td_subs.target_xy_pos_2D_1(i,2) + td_subs.target_diameter(i)/2 * sin(linspace(0,2*pi,50))};
end

% We plot a vertical line from the starting point as visual aid for showing pre-commitment bias
out_fixpoint_i = cellfun(@(x) find(~isnan(x),1),cone_data.dirdiff3D_ovs(sel));


unique_adjustment_angle_nominal = unique(trial_data.adjustment_angle_nominal);
unique_poc_class = unique(poc_class(~isnan(poc_class)));

all_ci = 1:length(unique_adjustment_angle_nominal);

clear g
figure('Units','centimeters','Position',[0 1 18 10])

for i = 1:height(td_subs)
    
    % We plot a vertical line from the starting point as visual aid for showing pre-commitment bias
    xintercept = hd_subs.hpos_xy_2D_1{i,1}(out_fixpoint_i(i));
    
    ci = all_ci(unique_adjustment_angle_nominal==td_subs.adjustment_angle_nominal(i));
    ri = poc_class(i);
    
    g(ri,ci) = gramm('x',hd_subs.hpos_xy_2D_1(i,1),'y',hd_subs.hpos_xy_2D_1(i,2));
    g(ri,ci).geom_line();
    g(ri,ci).geom_vline('xintercept',xintercept,'style','r--');
    g(ri,ci).axe_property('DataAspectRatio',[1 1 1],'XLim',[-85 85],'YLim',[-10 180],'XTick',[],'YTick',[],'XColor',[1 1 1],'yColor',[1 1 1]);
    g(ri,ci).set_names('x',[],'y',[]);
    g(ri,ci).set_color_options('map',[0 0 0]);
    g(ri,ci).geom_polygon('y',td_subs.poly_fix_x(i),'x',td_subs.poly_fix_y(i),'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    g(ri,ci).geom_polygon('y',td_subs.poly_via_x(i),'x',td_subs.poly_via_y(i),'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    g(ri,ci).geom_polygon('x',td_subs.poly_tgt_x(i),'y',td_subs.poly_tgt_y(i),'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
end

g.set_line_options('base_size',2);
g.draw();
g.redraw(0);


for i = 1:height(td_subs)
    ci = all_ci(unique_adjustment_angle_nominal==td_subs.adjustment_angle_nominal(i));
    ri = poc_class(i);
    
    POCind =  cone_data.poc3D_ind_vel{trial_data.index==td_subs.index(i)};
    x = hd_subs.hpos_xy_2D_1{i,1}(POCind);
    y = hd_subs.hpos_xy_2D_1{i,2}(POCind);
    
    g(ri,ci).update('x',x,'y',y);
    g(ri,ci).geom_point();
    g(ri,ci).set_color_options('map',[0 0 1]);
    g(ri,ci).set_point_options('base_size',5);
    g(ri,ci).draw();
end

g.export('file_name','Figure_3B.pdf','file_type','pdf');


%% Figure 3C

trial_data.target_directionUD = cell(height(trial_data),1);
trial_data.target_directionUD(trial_data.target_direction<180) = {'up'};
trial_data.target_directionUD(trial_data.target_direction>180) = {'down'};

% Display side-view onto the trajectories
hand_data.hpos_xy_2D_4      = hand_data.hpos_xyz(:,3);
hand_data.hpos_xy_2D_4(:,2) = hand_data.hpos_xyz(:,2);
hand_data.hpos_xy_2D_4(:,1) = cellfun(@(x) -x,hand_data.hpos_xy_2D_4(:,1),'uni',0);

clear g
figure('Units','centimeters','Position',[0 0 10 10])
g = gramm('x',hand_data.hpos_xy_2D_4(:,1),'y',hand_data.hpos_xy_2D_4(:,2),'color',trial_data.target_directionUD);
g.set_layout_options('legend_position',[0.2 0.825 0.2 0.2]);
g.stat_summary('type','sem','geom','line','interp_in',200);
g.geom_hline('yintercept',0);
g.axe_property('DataAspectRatio',[2 1 2],'YLim',[-10 10],'XLim',[0 120],'XTick',0:60:180,'YTick',[-20 -10 0 10]);
g.facet_grid(trial_data.start_via_dist,[]);
g.set_color_options('map',cmap_dir);
g.set_order_options('color',-1);
g.set_names('x','Distance to target [mm]','y','PlcHoldr','row','PlcHoldr','color','Target direction');
g.set_text_options('base_size',14,'facet_scaling',0.9,'legend_title_scaling',0.9);
g.set_line_options('base_size',3);
g.draw();

g.export('file_name','Figure_3C.pdf','file_type','pdf');