function [fitobject,gof,output,fitFunc] = fitApproxVoigt(x,y,initParams,lower,upper,bounds,varargin)
%
%initParams/lower/upper structure: [OD,Gamma,maxVal,bias,delta0]
%bounds is 1X2 vector with lower and upper frequency bounds


if nargin > 5
    if ~isempty(bounds)
        y=y(x>bounds(1) & x<bounds(2));
        x=x(x>bounds(1) & x<bounds(2));
    end
end

%varargin has the weight vector (optionally)
if ~isempty(varargin)
    weights=varargin{1};
else
    weights=[];
end
    

% fitFunc = @(OD,Gamma,maxVal,bias,delta0,delta) maxVal*exp(-imag(OD*1i*Gamma./(Gamma-1i*(delta-delta0))))+bias;
% fitFunc = @(OD,Gamma,maxVal,bias,delta0,delta) maxVal*exp(-OD*Gamma^2./(Gamma^2+(delta-delta0).^2))+bias;
fitFunc=@(amp,center,gamma,sigma,bias,x) PVoigtApprox(x,amp,center,gamma,sigma)+bias;

ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'amp','center','gamma','sigma','bias'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
        opts.Weights=weights;
if length(x)>length(y)
    x=x(1:length(y));
end

if ~iscolumn(x)
    x=x';
end

if ~iscolumn(y)
    y=y';
end

idx = isfinite(x) & isfinite(y);


[fitobject,gof,output] =fit(x(idx),y(idx),ft,opts);
end

