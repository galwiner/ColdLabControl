function [fitobject,gof,output,fitFunc] = fitExpLorentzian(delta,y,initParams,lower,upper,bounds,varargin)
%fit an e^(-T) function to delta,y vectors. 
%initParams/lower/upper structure: [OD,Gamma,maxVal,bias,delta0]
%bounds is 1X2 vector with lower and upper frequency bounds


if nargin > 5
    if ~isempty(bounds)
        y=y(delta>bounds(1) & delta<bounds(2));
        delta=delta(delta>bounds(1) & delta<bounds(2));
    end
end

%varargin has the weight vector (optionally)
if ~isempty(varargin)
    weights=varargin{1};
else
    weights=[];
end
    

% fitFunc = @(OD,Gamma,maxVal,bias,delta0,delta) maxVal*exp(-imag(OD*1i*Gamma./(Gamma-1i*(delta-delta0))))+bias;
fitFunc = @(OD,Gamma,maxVal,bias,delta0,delta) maxVal*exp(-OD*Gamma^2./(Gamma^2+(delta-delta0).^2))+bias;

ft = fittype(fitFunc,'independent','delta', 'dependent','y','coefficients',{'OD','Gamma','maxVal','bias','delta0'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
        opts.Weights=weights;
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

