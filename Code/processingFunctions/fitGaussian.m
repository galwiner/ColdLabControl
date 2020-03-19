function [fitobj, gof]=fitGaussian(x,y,initParams,lower,upper,exclude)
% returns a cfit object of a three Lorentzians
% 'y' is the function (measured values), 'x' is the variable
% 'start' is a vector containing starting values for
%[a1-a4,b1-b4,c1-c4,d] a-amplitude, b - center, c - HWHM, d - background
% 'lower' and 'upper' are corresponding limits
%% fitting

fitFunc = @(a,b,c,d,x) a.*exp(-(x-b).^2/(2*c.^2)) + d;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'a','b','c','d'});

p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if exist('lower','var')
        opts.Lower=lower;
        end
        if exist('upper','var')
        opts.Upper=upper;
        end

opts.StartPoint = p0;
if ~exist('lower','var')
    exclude=[-inf,inf];
end
if ~isequal(size(x),size(y))
    x = x';
end
excluded=excludedata(x,y,'range',exclude);
if ~iscolumn(x)
    x = x';
end
if ~iscolumn(y)
    y = y';
end
[fitobj,gof] =fit(x(~excluded),y(~excluded),ft,opts);

end

