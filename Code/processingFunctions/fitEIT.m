function [fitobject,gof,output] = fitEIT(delta,y,initParams,lower,upper,bounds)
%fit an e^(-T) function to delta,y vectors. 
%initParams/lower/upper structure: [OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c]
%bounds is 1X2 vector with lower and upper frequency bounds
if nargin == 6
y=y(delta>bounds(1) & delta<bounds(2));
delta=delta(delta>bounds(1) & delta<bounds(2));
end
fitFunc = @(OD,gamma,maxVal,Omega_c,gamma_s,bias,delta0_p,delta0_c,delta)...
    maxVal*exp(-imag(OD*1i*gamma./(gamma-1i*(delta-delta0_p)+Omega_c^2./(gamma_s-1i*(delta-delta0_p+delta0_c)))))+bias;
ft = fittype(fitFunc,'independent','delta', 'dependent','y','coefficients',...
    {'OD','gamma','maxVal','Omega_c','gamma_s','bias','delta0_p','delta0_c'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares');
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
        opts.Display = 'off';
        opts.TolFun = 1e-12;
%         opts.TolX = 1e-10;
[fitobject,gof,output] =fit(delta,y,ft,opts);
end

