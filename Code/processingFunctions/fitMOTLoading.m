function [fitobj,gof,output] = fitMOTLoading(time,data,initParams,varargin)
%fit to data = Nmax(1+exp(-b*t))
if nargin>5
    lowerParams = varargin{2};
    upperParams = varargin{3};
    model = varargin{1}; %model 0 : fit to linear mot, model 1 fit to non linear mot.
end
if nargin>3
        model = varargin{1}; %model 0 : fit to linear mot, model 1 fit to non linear mot.
end
if ~exist('model')
    model  = 0;
end
x = time;
if isrow(x)
    x = x';
end
y = data;
if isrow(y)
    y = y';
end
switch model
    case 0
        fitFunc = @(Nmax,b,bg,x) Nmax*(1-exp(-x*b))+bg;
        ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
            ,{'Nmax','b','bg'});
    case 1
                fitFunc = @(Nmax,b,g,x) Nmax+1./((g/(b+2*g*Nmax)-1/Nmax)*exp((b+2*g*Nmax)*x)-g/(b+2*g*Nmax));
        ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
            ,{'Nmax','b','g'});
        
    case 2
        fitFunc = @(a,b,bg,x) a/b*(1-exp(-x*b))+bg;
        ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
            ,{'a','b','bg'});
end
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>5
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
        
[fitobj,gof,output] =fit(x,y,ft,opts);
end
