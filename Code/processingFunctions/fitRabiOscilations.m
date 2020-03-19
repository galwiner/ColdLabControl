function [fitobject,gof,output] = fitRabiOscilations(time,transferEffitiency,initParams,lower,upper)
%fit to  A*exp(-t/tau)*sin(omega*t+phi). 
%bounds is 1X2 vector with lower and upper frequency bounds
%initParams/lower/upper order is [period,phi0,amp,background,tau]
y = transferEffitiency;
fitFunc = @(period,phi0,amp,background,tau,time) amp*exp(-time/tau).*(sin(2*pi*time/period+phi0).^2)+background;
ft = fittype(fitFunc,'independent','time', 'dependent','y','coefficients',...
    {'period','phi0','amp','background','tau'});
p0 = initParams;
    
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lower;
        opts.Upper=upper;
        end
[fitobject,gof,output] =fit(time',y,ft,opts);
end