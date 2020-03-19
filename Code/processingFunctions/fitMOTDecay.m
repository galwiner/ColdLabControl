function [fitobj,gof,output] = fitMOTDecay(time,data,initParams,varargin)
%fit to data = (N0-Nf)exp(-b*t)+Nf, assuming N0 is givven as the first
%point
if nargin>3
    lowerParams = varargin{1};
    upperParams = varargin{2};
    model = varargin{3}; %model 0 : fit to linear mot, model 1 fit to non linear mot.
end
if ~exist('model')
    model  = 0;
end
x = time;
y = data;
if length(y)>2000
    N0 = mean(y(1:101));
else
N0 = mean(y(1:round(length(y)/100)));
end
switch model
    case 0
        fitFunc = @(Nf,b,x) (N0-Nf)*exp(-b*x)+Nf;
        ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
            ,{'Nf','b'});
%     case 1
%                 fitFunc = @(Nmax,b,g,x) Nmax+1./((g/(b+2*g*Nmax)-1/Nmax)*exp((b+2*g*Nmax)*x)-g/(b+2*g*Nmax));
%         ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
%             ,{'Nmax','b','g'});
%         
%     case 2
%         fitFunc = @(a,b,x) a*b*(1-exp(-x/b));
%         ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients'...
%             ,{'a','b'});
end
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        if nargin>3
        opts.Lower=lowerParams;
        opts.Upper=upperParams;
        end
        
[fitobj,gof,output] =fit(x,y,ft,opts);
end
