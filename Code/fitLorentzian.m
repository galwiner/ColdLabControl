function [fitobject,gof,output] = fitLorentzian(delta,y,initParams,varargin)
%fit an lorentzian function to delta,y vectors. 
%fitFunction maxVal*gamma^2./(gamma^2+(delta-delta0).^2)+bias;
%initParams/lower/upper structure: ['gamma','maxVal','bias','delta0']
%bounds is 1X2 vector with lower and upper frequency bounds
if nargin>3
    boundsInd = find(strcmpi(varargin,'bounds'));
    if ~isempty(boundsInd)
        bounds = varargin{boundsInd+1};
        y=y(delta>bounds(1) & delta<bounds(2));
        delta=delta(delta>bounds(1) & delta<bounds(2));
    end
        lowerInd = find(strcmpi(varargin,'lower'));
    if ~isempty(lowerInd)
        lowerVals = varargin{lowerInd+1};
    end
        upperInd = find(strcmpi(varargin,'upper'));
    if ~isempty(upperInd)
        upperVals = varargin{upperInd+1};
    end
end 
fitFunc = @(gamma,maxVal,bias,delta0,delta) maxVal*gamma^2./(gamma^2+(delta-delta0).^2)+bias;
ft = fittype(fitFunc,'independent','delta', 'dependent','y','coefficients',{'gamma','maxVal','bias','delta0'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
%         opts.Lower=lower;
        if exist('lowerVals')
        opts.Lower=lowerVals;
        end
%         opts.Upper=upper;
        if exist('upperVals')
        opts.Upper=upperVals;
        end
[fitobject,gof,output] =fit(delta,y,ft,opts);
end

