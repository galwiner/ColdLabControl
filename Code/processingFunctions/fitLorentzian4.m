function [cfun, gof]=fitLorentzian4(f,x,start,lower,upper,domain)
% returns a cfit object of a three Lorentzians
% 'f' is the function, 'x' is the variable
% 'start' is a vector containing starting values for
%[a1-a4,b1-b4,c1-c4,d] a-amplitude, b - center, c - HWHM, d - background
% 'lower' and 'upper' are corresponding limits
%% fitting
ffun=fittype('a1*c1^2/((x-b1)^2 + c1^2) + a2*c2^2/((x-b1-54.84)^2 + c2^2) + a3*c3^2/((x-b1-266.65/2)^2 + c3^2) + a4*c4^2/((x-b1-266.65)^2 + c4^2) + d');
options=fitoptions(ffun);
options.StartPoint=start;
if nargin==5
    options.Lower=lower;
    options.Upper=upper;
end
if nargin==6
    options.Exclude=domain;
end
[cfun,gof]=fit(x,f,ffun,options);
end

