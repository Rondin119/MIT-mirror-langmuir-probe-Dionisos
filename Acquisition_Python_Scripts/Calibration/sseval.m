function sse = sseval(x,tdata,ydata)
%SSEVAL Summary of this function goes here
%   Detailed explanation goes here
A=x(1);
b=x(2);
c =x(3);
d=x(4);


sse = sum((ydata - A*cos(b*tdata+d)+c).^2);


end

