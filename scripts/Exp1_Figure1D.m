%% Figure 1D

% Color map
cmap_nomAdjA = [253 141  60
                166  54   3
                158 154 200
                 84  39 143
                116 196 118
                  0 109  44]./255;
             
cmap_nomAdjA = cmap_nomAdjA([1 3 5 2 4 6],:);


% Single subject data figure
sel1 = trial_data.subject_index==1 & (trial_data.target_direction==45 | trial_data.target_direction==225); 


% For stable condition - color - mapping across subplots
aux_adjangle1 = unique(trial_data.adjustment_angle_nominal(sel1));
   

clear g
figure('Units','centimeters','Position',[0 0 28 7.5])

unique_start_via_dist = unique(trial_data.start_via_dist(sel1));
for i = 1:length(unique_start_via_dist)
    sel2 = sel1 & trial_data.start_via_dist==unique_start_via_dist(i);
    
    td_subs = trial_data(sel2,:);
    hd_subs = hand_data(sel2,:);
    
    % For stable condition - color - mapping across subplots
    aux_adjangle2 = unique(td_subs.adjustment_angle_nominal);
    cmap_sel = ismember(aux_adjangle1,aux_adjangle2);
    cmap_subs = cmap_nomAdjA(cmap_sel,:);
    
    %tgtdir_45_225 = td_subs.target_direction==45 | td_subs.target_direction==225;
    
    if i==1
        ylbl = 'Distance-from-start [mm]';
    else
        ylbl= ' ';
    end
    
    g(i) = gramm('x',hd_subs.hpos_xy_2D_1(:,1),'y',hd_subs.hpos_xy_2D_1(:,2),...
        'color',td_subs.adjustment_angle_nominal);
    g(i).set_layout_options('position',[0+0.32*(i-1) 0 0.32 1],'redraw',1);
    g(i).geom_line();
    g(i).set_names('y',ylbl,'x','Lateral deviation [mm]');
    g(i).set_color_options('map',cmap_subs);
    g(i).no_legend();
    g(i).set_text_options('base_size',14);
    
    if i==1
        g(i).axe_property('DataAspectRatio',[1 1 1],'XLim',[-90 90],'YLim',[-15 180],'XTick',-60:60:60,'YTick',0:60:180);
    else
        g(i).axe_property('DataAspectRatio',[1 1 1],'XLim',[-90 90],'YLim',[-15 180],'XColor',[1 1 1],'YColor',[1 1 1]);
    end
    
    % Polygon starting sphere
    fix_x = {0 + unique(td_subs.start_diameter)/2 * cos(linspace(0,2*pi,50))};
    fix_y = {0 + unique(td_subs.start_diameter)/2 * sin(linspace(0,2*pi,50))};
    g(i).geom_polygon('y',fix_x,'x',fix_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    
    % Polygon via-sphere
    inter_tgt_x = {                       0 + unique(td_subs.via_diameter)/2 * cos(linspace(0,2*pi,50))};
    inter_tgt_y = {unique_start_via_dist(i) + unique(td_subs.via_diameter)/2 * sin(linspace(0,2*pi,50))};
    g(i).geom_polygon('x',inter_tgt_x,'y',inter_tgt_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
    
    % Polygon target
    unique_tgt_dir = unique(td_subs.target_direction);
    unique_tgt_latoff = unique(td_subs.target_lateral_offset);
    for j = 1:length(unique_tgt_dir)
        for k = 1:length(unique_tgt_latoff)
            sel = find(td_subs.target_direction==unique_tgt_dir(j) & td_subs.target_lateral_offset==unique_tgt_latoff(k),1);
            target_radius = unique(td_subs.target_diameter)/2;
            
            tgt_x = {td_subs.target_xy_pos_2D_1(sel,1) + target_radius * cos(linspace(0,2*pi,50))};
            tgt_y = {td_subs.target_xy_pos_2D_1(sel,2) + target_radius * sin(linspace(0,2*pi,50))};
            
            g(i).geom_polygon('x',tgt_x,'y',tgt_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
        end
    end
end


% Target XY location insets
tgt_pos_tbl = grpstats(trial_data,{'target_direction','target_lateral_offset'},'unique','DataVars','target_xyz_pos');
tgt_pos_tbl.tgtdir_45_225 = tgt_pos_tbl.target_direction==45 | tgt_pos_tbl.target_direction==225;

g(4) = gramm('x',tgt_pos_tbl.unique_target_xyz_pos(:,1),'y',tgt_pos_tbl.unique_target_xyz_pos(:,2));
g(4).set_layout_options('position',[0.1 0.2 0.36 0.36]);
g(4).geom_point();
g(4).axe_property('DataAspectRatio',[1 1 1],'XLim',[-70 70],'YLim',[-70 70],'XTick',[],'YTick',[]);
g(4).set_color_options('map',[0.3 0.3 0.3]);
g(4).set_names('y','Down-up','x','Left - right');

% Polygon reference targets
subs = tgt_pos_tbl(tgt_pos_tbl.tgtdir_45_225==1,:);
for j = 1:height(subs)
    tgt_x = {subs.unique_target_xyz_pos(j,1) + target_radius * cos(linspace(0,2*pi,50))};
    tgt_y = {subs.unique_target_xyz_pos(j,2) + target_radius * sin(linspace(0,2*pi,50))};
    
    g(4).geom_polygon('y',tgt_x,'x',tgt_y,'color',[220 220 220]./255,'alpha',1,'line_style',{'-'});
end


% Out of bounds dummy plot for adjustment_angle_nominal color legend
g(5) = gramm('x',aux_adjangle1,'y',aux_adjangle1,'color',aux_adjangle1);
g(5).set_layout_options('position',[-1 -1 0 0],'legend_position',[0.855 0.15 0.1 0.6]);
g(5).geom_point();
g(5).set_color_options('map',cmap_nomAdjA);
g(5).set_names('color',{'Nominal' 'adjustment angle [°]'});

g.draw();


% Draw main figure X-axis in inset plot
g(4).update('x',tgt_pos_tbl.unique_target_xyz_pos(:,1),'y',tgt_pos_tbl.unique_target_xyz_pos(:,2),'subset',tgt_pos_tbl.tgtdir_45_225==1);
g(4).geom_point();
g(4).geom_line();
g(4).set_color_options('map',[49,130,189]./255);
g(4).draw();


g.export('export_path',fig_dir,'file_name','Figure_1D.pdf','file_type','pdf');
