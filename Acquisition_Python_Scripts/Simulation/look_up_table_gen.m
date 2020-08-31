xVal = linspace(-8,8,2^13);
yVal = 0;
y = @(x) 1/(exp(x)-1);

for i = 1:length(xVal)
    if (xVal(i)> -1)&&(xVal(i)<1)
    yVal(i) = y(xVal(i))*2^2;
    else
    yVal(i) = y(xVal(i))*2^13;    
    end
end


yVal=yVal';
yVal = round(yVal);






