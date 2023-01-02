load([data_dir 'Exp1_cone_data.mat'])

%%

cmap_marker = [ 77 175  74
               152  78 163
               255 127   0
               166  86  40]./255;


selind = 1391; % Add more indices to this variable to plot multiple example trials
          


dirdiff = cone_data.dirdiff3D_ovs;

for i = 1:length(selind) % Set up to plot multiple trials 
    sel = trial_data.index==selind(i);
    td_subs = trial_data(sel,:);
    hd_subs = hand_data(sel,:);
    
    % Trajectory plot axis limits
    tgt_dir = td_subs.target_xy_pos_2D_1(1)/abs(td_subs.target_xy_pos_2D_1(1));
    traj_xlim = sort([-tgt_dir*(td_subs.via_diameter/2+5) td_subs.target_xy_pos_2D_1(1) + tgt_dir*(td_subs.target_diameter/2+5)]);
    traj_ylim = [-15 td_subs.target_xy_pos_2D_1(2) + td_subs.target_diameter/2 + 5];
    
    clear g
    figure('Units','centimeters','Position',[0 1 28 20])
    
    for j = 1:4
        switch j % Trajectory subplots. Plot POC at position...
            case 1 % halfway between start cutoff & POC ovs
                
                % In case cone start cutoff comes after trial start
                % cone_start = find(isnan(dirdiff{sel}(1:end-1)),1,'last');
                % ind = cone_start + ceil((td_subs.poc3D_vel-cone_start)/2);
                
                % In case cone start cutoff = trial start
                ind = ceil(td_subs.poc3D_vel/2);
                ind_t1 = ind;
            case 2 % POC ovs
                ind = find(hd_subs.hpos_xy_2D_1{2}==td_subs.poc3D_ovs);
                ind_d = ind;
                ind_t2 = ind;
            case 3 % POC vel
                ind = find(hd_subs.hpos_xy_2D_1{2}==td_subs.poc3D_vel);
                ind_t3 = ind;
            case 4 % halfway between in cone start & trial end
                ind = find(dirdiff{sel}==0,1);
                ind_t4 = ind;
        end
        
        g(1,j) = gramm('x',hd_subs.hpos_xy_2D_1(:,1),'y',hd_subs.hpos_xy_2D_1(:,2));
        
        for k = 1:4
            switch k
                case 1 % 1: Draw the starting sphere
                    x = {0 + td_subs.start_diameter/2 * cos(linspace(0,2*pi,50))};
                    y = {0 + td_subs.start_diameter/2 * sin(linspace(0,2*pi,50))};
                    
                case 2 % 2: Draw the via-sphere
                    x = {td_subs.via_xy_pos_2D_1(1) + td_subs.via_diameter/2 * cos(linspace(0,2*pi,50))};
                    y = {td_subs.via_xy_pos_2D_1(2) + td_subs.via_diameter/2 * sin(linspace(0,2*pi,50))};
                
                case 3 % 3: Draw the cone
                    cone_peak_px = hd_subs.hpos_xy_2D_1{:,1}(ind);
                    cone_peak_py = hd_subs.hpos_xy_2D_1{:,2}(ind);
                    [tx1,ty1,tx2,ty2] = point2circle_tang_v2(cone_peak_px,cone_peak_py,...
                        td_subs.target_xy_pos_2D_1(1),td_subs.target_xy_pos_2D_1(2),td_subs.target_diameter/2);
                    x = {[cone_peak_px tx1 tx2 cone_peak_px]};
                    y = {[cone_peak_py ty1 ty2 cone_peak_py]};
                
                case 4 % 4: Draw the target sphere
                    x = {td_subs.target_xy_pos_2D_1(1) + td_subs.target_diameter/2 * cos(linspace(0,2*pi,50))};
                    y = {td_subs.target_xy_pos_2D_1(2) + td_subs.target_diameter/2 * sin(linspace(0,2*pi,50))};
            end
            
            % Polygon appearance
            if k~=3
                cmap_poly = [220 220 220]./255; % start/via/target color
            else
                cmap_poly = [166,206,227]./255; % cone color
            end
            line_color = cmap_poly.*0.5;
            g(1,j).geom_polygon('x',x,'y',y,'color',cmap_poly,'alpha',1,'line_style',{'-'},'line_color',line_color);
        end
        
        % 5: Draw the trajectory
        g(1,j).geom_line();
        g(1,j).axe_property('DataAspectRatio',[1 1 1],'XLim',traj_xlim,'YLim',traj_ylim,...
            'XTick',[-80:40:80],'YTick',[0:40:160]);
        g(1,j).set_color_options('map',[0 0 0]);
        g(1,j).set_names('x','Lateral deviation [mm]','y','Distance-from-start [mm]');
        
        
        % Cone theta
        ct_xlim = [0 hd_subs.hpos_xy_2D_1{2}(end)+10];
        ct_ylim = [min(dirdiff{1})-3 max(dirdiff{1})+3];
        ct_xrange = range(ct_xlim);
        ct_yrange = range(ct_ylim);
        g(2,1) = gramm('x',hd_subs.hpos_xy_2D_1(2)','y',dirdiff(sel));
        g(2,1).set_layout_options('position',[0 0 0.5 0.5]);
        g(2,1).geom_line();
        g(2,1).axe_property('DataAspectRatio',[5 10*ct_yrange/ct_xrange 10],'XLim',ct_xlim,'YLim',ct_ylim);
        g(2,1).set_names('x','Distance-from-start [mm]','y','Diff. current dir. - cone [°]');
        g(2,1).set_color_options('map',[0 0 0]);
        
        
        % Speed
        v_xlim = [0 hd_subs.hpos_xy_2D_1{2}(end)+10];
        %v_ylim = [min(hd_subs.hspeed{:})-0.03 max(hd_subs.hspeed{:})+0.03];
        v_ylim = [0 max(hd_subs.hspeed{:})+0.03];
        v_xrange = range(v_xlim);
        v_yrange = range(v_ylim);
        g(2,2) = gramm('x',hd_subs.hpos_xy_2D_1(2)','y',hd_subs.hspeed);
        g(2,2).set_layout_options('position',[0.5 0 0.5 0.5]);
        g(2,2).geom_line();
        g(2,2).axe_property('DataAspectRatio',[5 10*v_yrange/v_xrange 10],'XLim',v_xlim,'YLim',v_ylim);
        g(2,2).set_names('x','Distance-from-start [mm]','y','Speed [m/s]');
        g(2,2).set_color_options('map',[0 0 0]);
    end
    
    g.set_text_options('base_size',14,'legend_scaling',0.9);
    %g.set_line_options('base_size',2);
    g.draw();
    
    % Update run
    for j = 1:4
        switch j % 6: Draw the position marker (sep color per subplot)
            case 1 % halfway between trial start & POC dir
                ind = ind_t1;
            case 2 % POC dir
                ind = ind_t2;
            case 3 % POC vel
                ind = ind_t3;
            case 4 % halfway between in cone start & trial end
                ind = ind_t4;
        end
        
        % Trajectory plot markers
        g(1,j).update();
        px = hd_subs.hpos_xy_2D_1{:,1}(ind);
        py = hd_subs.hpos_xy_2D_1{:,2}(ind);
        x = {px + 5 * cos(linspace(0,2*pi,50))};
        y = {py + 5 * sin(linspace(0,2*pi,50))};
        line_color = cmap_marker.*0.5;
        g(1,j).geom_polygon('x',x,'y',y,'color',cmap_marker(j,:),'alpha',0.7,'line_style',{'-'},'line_color',line_color(j,:));
        g(1,j).draw();
        
        % Current direction markers
        px1 = hd_subs.hpos_xy_2D_1{:,1}(ind);
        px2 = hd_subs.hpos_xy_2D_1{:,1}(ind+1);
        vx = diff([px1 px2]);
        py1 = hd_subs.hpos_xy_2D_1{:,2}(ind);
        py2 = hd_subs.hpos_xy_2D_1{:,2}(ind+1);
        vy = diff([py1 py2]);
        th = atan2d(vy,vx);
        px3 = cosd(th);
        py3 = sind(th);
        curr_dir_x = [px1 px1+50*px3];
        curr_dir_y = [py1 py1+50*py3];
        
        g(1,j).update('x',px1,'y',py1);
        g(1,j).geom_point();
        g(1,j).set_color_options('map',[1 0 0]);
        g(1,j).draw();
        
        g(1,j).update('x',curr_dir_x,'y',curr_dir_y);
        g(1,j).geom_line();
        g(1,j).set_color_options('map',[1 0 0]);
        g(1,j).set_line_options('base_size',1);
        g(1,j).draw();
        
        for k = 1:2 % Put all markers in the cone theta & velocity plots
            g(2,k).update();
            
            px = hd_subs.hpos_xy_2D_1{:,2}(ind);
            
            if k==1
                py = dirdiff{sel}(ind);
                xscale = 0.5*ct_xrange/ct_yrange;
                pscale = 0.03*ct_yrange;
            else
                py = hd_subs.hspeed{:}(ind);
                xscale = 0.5*v_xrange/v_yrange;
                pscale = 0.03*v_yrange;
            end
            
            x = {px + pscale * xscale * cos(linspace(0,2*pi,50))};
            y = {py + pscale * sin(linspace(0,2*pi,50))};
            line_color = cmap_marker.*0.5;
            g(2,k).geom_polygon('x',x,'y',y,'color',cmap_marker(j,:),'alpha',0.7,'line_style',{'-'},'line_color',line_color(j,:));
            g(2,k).draw();
        end
    end
    
    g.export('export_path',fig_dir,'file_name','Figure_2.pdf','file_type','pdf');
end

