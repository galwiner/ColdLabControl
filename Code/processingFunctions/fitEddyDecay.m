function [fitobject,gof,output] = fitEddyDecay(time,shift,initParams,lower,upper)
%fit to  A*(1+B*exp(time/tau)). 
%initParams/lower/upper order is [satVal,vis,tau]
y = shift;
fitFunc = @(satVal,y0,tau,time) satVal*(1+y0*exp(-time/tau));
ft = fittype(fitFunc,'independent','time', 'dependent','y','coefficients',...
    {'satVal','y0','tau'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
[fitobject,gof,output] =fit(time',y,ft,opts);
end