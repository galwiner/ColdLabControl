function [fitobject,gof,output] = fit2ExpGaussians(x,y,initParams,varargin)
%fit an A*e^(-OD*exp(-(x-x0)^2/2/sigma^2))+bg function to delta,y vectors. 
%initParams/lower/upper structure: [OD1,OD2,x0,sigma1,sigma2,A,bg]
%bounds is 1X2 vector with lower and upper frequency bounds
if nargin>3
    lowerParams = varargin{1};
    upperParams = varargin{2};
end
fitFunc = @(OD1,OD2,x0,sigma1,sigma2,A,bg,x) A*exp(-OD1*exp(-(x-x0).^2/2/sigma1^2)).*...
    exp(-OD2*exp(-(x-x0).^2/2/sigma2^2))+bg;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'OD1','OD2','x0','sigma1','sigma2','A','bg'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
[fitobject,gof,output] =fit(x,y,ft,opts);
end

