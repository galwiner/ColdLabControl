function [fitobj,gof,output] = fitMOTDecay_v2(time,data,initParams,varargin)
%fit to data = (N0-Nf)exp(-b*t)+Nf, assuming N0 is givven as the first
%point
if nargin>3
    lowerParams = varargin{1};
    upperParams = varargin{2};
end

x = time;
y = data;
fitFunc = @(N0,Nf,b,x) (N0-Nf)*exp(-b*x)+Nf;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'N0','Nf','b'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
        
[fitobj,gof,output] =fit(x,y,ft,opts);
end
