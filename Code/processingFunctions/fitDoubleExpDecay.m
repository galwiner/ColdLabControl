function [fitobj,gof,output] = fitDoubleExpDecay(time,data,initParams,varargin)
%fit to data = A*exp(-t/tau1)+B*exp(-t/tau2)+C
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
fitFunc = @(A,tau1,B,tau2,C,x) A*exp(-x/tau1)+B*exp(-x/tau2)+C;
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
    ,{'A','tau1','B','tau2','C'});

p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
        
[fitobj,gof,output] =fit(x,y,ft,opts);
end