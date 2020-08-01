function xyz = my_axe_rotation(xyz,t,axe)
% axe: x, y, or z

if strcmp(axe,'x')
     xyz = [xyz(:,1) xyz(:,2).*cosd(t)-xyz(:,3).*sind(t) xyz(:,2).*sind(t)+xyz(:,3).*cosd(t)];
end

if strcmp(axe,'y')
    xyz = [xyz(:,1).*cosd(t)+xyz(:,3).*sind(t) xyz(:,2) -xyz(:,1).*sind(t)+xyz(:,3).*cosd(t)];
end

if strcmp(axe,'z')
    xyz = [xyz(:,1).*cosd(t)-xyz(:,2).*sind(t) xyz(:,1).*sind(t)+xyz(:,2).*cosd(t) xyz(:,3)];
end


% function [x,y,z] = my_axe_rotation(x,y,z,t,axe)
% % axe: x, y, or z
% 
% if strcmp(axe,'x')
%     y = y.*cosd(t)-z.*sind(t);
%     z = y.*sind(t)+z.*cosd(t);
% end
% 
% if strcmp(axe,'y')
%     x =  x.*cosd(t)+z.*sind(t);
%     z = -x.*sind(t)+z.*cosd(t);
% end
% 
% if strcmp(axe,'z')
%     x = x.*cosd(t)-y.*sind(t);
%     y = x.*sind(t)+y.*cosd(t);
% end