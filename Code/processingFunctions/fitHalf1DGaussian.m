function [fitobject,fitParams,fitFunc,gof,output] = fitHalf1DGaussian(x,y,initParams,varargin)
%fit to a Gaussian
%initParams [Amp,cent,sigma,bg]
%fitParams(1) = amp;fitParams(2)= cent;fitParams(3) = sigma;fitParams(4) =
%bg;
if ~isvector(x)
    error('x must be a vector')
elseif ~iscolumn(x)
    x = x';
end
if nargin>3
   Lower =  varargin{1};
   Upper = varargin{2};
end
fitFunc = @(Amp,cent,sigma,bg,x) Amp*exp(-(x-cent).^2/(2*sigma^2)).*heaviside(x-cent)+bg;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'Amp','cent','sigma','bg'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if exist('Lower','var')
          opts.Lower = Lower;
          opts.Upper = Upper;
        end
[fitobject,gof,output] =fit(x,y,ft,opts);
fitParams(1) = fitobject.Amp;
fitParams(2) = fitobject.cent;
fitParams(3) = fitobject.sigma;
fitParams(4) = fitobject.bg;


end

