function dirdiff = dirdiff_fun(...
                                hpos,... % datapoints * dimensions vector
                                target_pos,... % 1 * dimensions vector
                                target_radius)
                           
                                              
        
ndims    = size(hpos,2);    % 2D or 3D reaches?
nsamples = size(hpos,1)-1;  % minus one because we always need 2 neighboring samples for the current direction

p1 = hpos(1:end-1,:);               % current position at t
p2 = hpos(2:end,:);                 % current position at t+1
p3 = repmat(target_pos,nsamples,1); % target position

zero_aux = zeros(nsamples,1);


if ndims==3 % We rotate the plane defined by p1, p2, p3 onto the xy plane
    zar = cross(p2-p1,p3-p1,2);
    yar = cross(repmat([1 0 0],nsamples,1),zar,2);
    xar = cross(zar,yar,2);
    
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

% CHECK: current pos - target vector on X axis & current direction always pointing in 1st quadrant, thus cone_theta
% calculated as elevation from current position to cone surface?


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
target_radius = repmat(target_radius,nsamples,1);

for i = nsamples:-1:1
    [~,~,~,~,cone_theta(i)] = point2circle_tang_v2(0,0,p3r2(i,1),p3r2(i,2),target_radius(i));
    curr_dir_theta(i) = atan2d(norm(cross(p2r2(i,:),[0 1 0])),dot(p2r2(i,:),[0 1 0]));
end
            

dirdiff = abs(curr_dir_theta)-abs(cone_theta./2);



dirdiff(dirdiff<=0) = 0;

dirdiff = dirdiff';
