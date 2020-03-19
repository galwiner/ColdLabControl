function [fitobject,gof,output,fitFunc] = fitOpticalPumpning(delta,y,initParams,lower,upper)
%fit an e^(-T) function to delta,y vectors. 
%initParams/lower/upper structure: [OD,gamma,delta0,B,amp1,amp2,amp3,amp4]
%bounds is 1X2 vector with lower and upper frequency bounds

% gamma = 3.05;
fitFunc = @(OD,gamma,delta0,B,amp1,amp2,amp3,amp4,delta) exp(-OD*...
    (amp1*gamma^2./(gamma^2+(delta-delta0-B*(3*0.93-2*0.7)).^2)+...
    0.6667*amp2*gamma^2./(gamma^2+(delta-delta0-B*(2*0.93-1*0.7)).^2)+...
    0.4*amp3*gamma^2./(gamma^2+(delta-delta0-B*(1*0.93-0*0.7)).^2)+...
    0.2*amp4*gamma^2./(gamma^2+(delta-delta0-B*(0*0.93+1*0.7)).^2)+...
    0.0667*(1-amp1-amp2-amp3-amp4)*gamma^2./(gamma^2+(delta-delta0-B*(-1*0.93+2*0.7)).^2)));

ft = fittype(fitFunc,'independent','delta', 'dependent','y','coefficients',{'OD','gamma','delta0','B','amp1'...
    'amp2','amp3','amp4'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
% opts.Display = 'iter';
opts.MaxFunEvals = 2e4;
opts.MaxIter = 1e3;
opts.TolFun = 1e-10;
opts.DiffMinChange = 1e-3;
if length(delta)>length(y)
    delta=delta(1:length(y));
end

if ~iscolumn(delta)
    delta=delta';
end

if ~iscolumn(y)
    y=y';
end

idx = isfinite(delta) & isfinite(y);


[fitobject,gof,output] =fit(delta(idx),y(idx),ft,opts);
end

