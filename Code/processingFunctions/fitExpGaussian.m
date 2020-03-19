function [fitobject,gof,output] = fitExpGaussian(x,y,initParams,varargin)
%fit an A*e^(-OD*exp(-(x-x0)^2/2/sigma^2))+bg function to delta,y vectors. 
%initParams/lower/upper structure: [OD,x0,sigma,A,bg]
%bounds is 1X2 vector with lower and upper frequency bounds
if nargin>3
    lowerParams = varargin{1};
    upperParams = varargin{2};
end
fitFunc = @(OD,x0,sigma,A,bg,x) A*exp(-OD*exp(-(x-x0).^2/2/sigma^2))+bg;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'OD','x0','sigma','A','bg'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
[fitobject,gof,output] =fit(x,y,ft,opts);
end

