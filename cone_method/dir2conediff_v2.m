function [diff_dir2cone,diff_drv1,diff_drv2] = dir2conediff_v2(...
                                               pos_coords,... % datapoints * dimensions vector
                                               offset,...    
                                               tgt_coords,... % 1 * dimensions vector
                                               tgt_radius,...
                                               ignore_zdim)
                                                 
                                  
% TO DO: Add all target center coord to differentiate between spatially
% averaged movements & overshots

if ignore_zdim
    pos_coords = pos_coords(:,1:2);
    tgt_coords = tgt_coords(:,1:2);
end
        
ndims    = size(pos_coords,2); % 2D or 3D reaches?
nsamples = size(pos_coords,1)-1; % minus one because we always need 2 neighboring samples for the current direction

p1 = pos_coords(1:end-1,:); % current position
p2 = pos_coords(2:end,:); % current position +1
p3 = repmat(tgt_coords,nsamples,1); % target position

zero_aux = zeros(nsamples,1);

if ndims==3 % We rotate the plane defined by p1, p2, p3 onto the xy plane
    zar = cross(p2-p1,p3-p1,2);
    yar = cross(repmat([1 0 0],nsamples,1),zar,2);
    xar = cross(zar,yar,2);
    
    % We have to loop, since norm doesn't work dimension-wise
    for i = 1:nsamples
        xar(i,:) = xar(i,:)/norm(xar(i,:));
        yar(i,:) = yar(i,:)/norm(yar(i,:));
    end
    
    p1r = [dot(p1,xar,2) dot(p1,yar,2) zero_aux];
    p2r = [dot(p2,xar,2) dot(p2,yar,2) zero_aux];
    p3r = [dot(p3,xar,2) dot(p3,yar,2) zero_aux];
    
else % Add z=0 to all coords
    p1r = [p1 zero_aux];
    p2r = [p2 zero_aux];
    p3r = [p3 zero_aux];
end

% Set p1 = 0 and align ->(p1p3) w/y axis
p2r2 = p2r-p1r;
p3r2 = p3r-p1r;


for i = 1:nsamples
    rota = atan2(norm(cross(p3r2(i,:),[0 1 0])),dot(p3r2(i,:),[0 1 0]));
    
    if p3r2(i,1)<0
        rota = -rota;
    end
    
    rotm = [cos(rota) -sin(rota)
            sin(rota)  cos(rota)];
        
    p2r2(i,1:2) = rotm*p2r2(i,1:2)';
    p3r2(i,1:2) = rotm*p3r2(i,1:2)';
   
end
            
            
% Direction - cone - distance

% 1. Tangent points
tgt_radius = repmat(tgt_radius,nsamples,1);

% We have to loop, since norm doesn't work dimension-wise
for i = nsamples:-1:1
    [~,~,~,~,cone_theta(i)] = point2circle_tang_v2(0,0,p3r2(i,1),p3r2(i,2),tgt_radius(i));
    curr_dir_theta(i) = atan2d(norm(cross(p2r2(i,:),[0 1 0])),dot(p2r2(i,:),[0 1 0]));
end
            
% Add last row w/NAN
% cone_theta     = [cone_theta'; nan];
% curr_dir_theta = [curr_dir_theta'; nan];

diff_dir2cone = abs(curr_dir_theta)-abs(cone_theta./2);

% diff_drv1 = diff([nan diff_dir2cone]);
% diff_drv2 = diff(diff([nan nan diff_dir2cone]));

diff_dir2cone(diff_dir2cone<=0) = 0;
% diff_drv1(diff_dir2cone<=0) = nan;
% diff_drv2(diff_dir2cone<=0) = nan;
diff_drv1 = diff([nan diff_dir2cone]);
diff_drv2 = diff(diff([nan nan diff_dir2cone]));

if offset>0
    diff_dir2cone(1:offset) = nan;
    diff_drv1(1:offset) = nan;
    diff_drv2(1:offset) = nan;
end
