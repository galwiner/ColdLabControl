function [fitobj,gof,output] = fitExpDecay(time,data,initParams,varargin)
%fit to data = A*exp(-t/tau)+B
if nargin>3
    lowerParams = varargin{1};
    upperParams = varargin{2};
end
x = time;
if isrow(x)
    x = x';
end
y = data;
if ~iscolumn(y)
    y = y';
end
fitFunc = @(A,tau,bg,x) A*exp(-x/tau)+bg;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'A','tau','bg'});

p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
        
[fitobj,gof,output] =fit(x,y,ft,opts);
end