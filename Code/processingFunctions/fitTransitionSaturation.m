function [fitobj,gof,output] = fitTransitionSaturation(powers,atomNum,initParams)
%fit to data = A*x/x0/(1+x/x0)
y = atomNum;
x = powers;
fitFunc = @(A,x0,x) A*x/x0./(1+x/x0);
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'A','x0'});

p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
%         opts.Lower=lower;
%         opts.Upper=upper;
[fitobj,gof,output] =fit(x,y,ft,opts);
end