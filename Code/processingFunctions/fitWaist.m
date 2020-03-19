function [fitobj, fp]=fitWaist(x,y,initParams)
% returns a cfit object of a waist
% 'y' is the function (measured values), 'x' is the variable
%assumes dimention in micron. wavelength of 780 nm.
% initParams are [w0,z0]
%% fitting
lambda = 0.78;
% zr = pi*w0.^2/lambda;
fitFunc = @(w0,z0,x) w0*sqrt(1+(x-z0).^2/(pi*w0.^2/lambda).^2);
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'w0','z0'});

p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares','Display','off', 'MaxIter', 1e6,'TolFun',1e-12,'MaxFunEvals',1e6);
        opts.StartPoint = p0;
if ~iscolumn(x)
    x = x';
end
if ~iscolumn(y)
    y = y';
end
goodInds = isfinite(x)&isfinite(y);
fitobj =fit(x(goodInds),y(goodInds),ft,opts);
fp = coeffvalues(fitobj);

end

