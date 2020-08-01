function [x1,y1,x2,y2,theta] = point2circle_tang_v2(px,py,cx,cy,cr)

x1 = (cr^2*(px-cx) + cr*(py-cy) * sqrt((px-cx)^2+(py-cy)^2-cr^2)) / ((px-cx)^2+(py-cy)^2) + cx;
x2 = (cr^2*(px-cx) - cr*(py-cy) * sqrt((px-cx)^2+(py-cy)^2-cr^2)) / ((px-cx)^2+(py-cy)^2) + cx;
y1 = (cr^2*(py-cy) - cr*(px-cx) * sqrt((px-cx)^2+(py-cy)^2-cr^2)) / ((px-cx)^2+(py-cy)^2) + cy;
y2 = (cr^2*(py-cy) + cr*(px-cx) * sqrt((px-cx)^2+(py-cy)^2-cr^2)) / ((px-cx)^2+(py-cy)^2) + cy;

theta = 2*atand(cr/sqrt((px-x1)^2+(py-y1)^2));