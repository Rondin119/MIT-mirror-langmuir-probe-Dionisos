function [num_out] = divout(num)
%GENOUT Summary of this function goes here
%   Detailed explanation goes here
numvec = de2bi(num);
if length(numvec)<12
num_out = num/2^11;
return
elseif (length(numvec)==12)
    num_out = -1*bi2de(-1*(numvec(2:12)-1))/2^11;
return 
end


remainder = numvec(end-11:end);
intig = numvec(1,end-12);
if remainder(1) == 1
   remainder_calc = -1*(remainder(2:12)-1);
   intig_calc = -1*(intig-1);
   coef1 = -1;
else
   remainder_calc = remainder;
   intig_calc = intig;
   coef1 = 1;
end



num_out = coef1*(bi2de(intig)+bi2de(remainder)/2^11);

end

