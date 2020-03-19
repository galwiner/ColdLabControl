function [fitobject,gof,output] = fitSinc(freq,transferEffitiency,initParams,lower,upper)
%fit to  A*(sin(B*(x-C))/((x-C)))^2+D. 
%initParams/lower/upper order is [amp,center,period,background]
y = transferEffitiency;
x = freq;
% ft = fittype('x','independent','x', 'dependent','y','coefficients',...
%     {'amp','center','period','background'});

ft = fittype('sinc(x,amp,center,period,background)','independent','x', 'dependent','y','coefficients',...
        {'amp','center','period','background'});
p0 = initParams;

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.StartPoint = p0;
        opts.Lower=lower;
        opts.Upper=upper;
[fitobject,gof,output] =fit(freq',y,ft,opts);
end
