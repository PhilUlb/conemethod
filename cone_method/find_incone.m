function out = find_incone(in,match,dir)
% Indices of "in" that mark the beginning ("dir" = 1) or end ("dir" = -1)
% of periods where "in" == "match"

if iscolumn(in)
    in = in';
end

a = find(in==match);

if isempty(a)
    out = [];
elseif dir==1
    b = diff(a);
    c = find(b>1)+1;
    out = [a(1) a(c)];
elseif dir==-1
    b = diff(a);
    c = find(b>1);
    out = [a(c) a(end)];
end

