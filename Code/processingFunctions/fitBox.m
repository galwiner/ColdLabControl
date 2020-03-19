function [fo,fp] = fitBox(y)
%this function fits the values in y to a "box" potential of max val A min
%bal bg, center y0 and width w
x = (1:length(y))';
[~,minInd] = min(y);
p0 = [max(y),min(y),minInd,length(y)/10];
ft = fittype('fitBox_fit_func(x,A,bg,w,y0)','independent','x', 'dependent','y','coefficients',{'A','bg','y0','w'});
opts = fitoptions( 'Display', 'iter', 'MaxIter', 1e6,'TolFun',1e-16,'MaxFunEvals',1e5,'Method', 'NonlinearLeastSquares','TolX',1e-15,'DiffMinChange',1e-16,'DiffMaxChange',1e-10);
opts.StartPoint = p0;
fo =fit(x,y,ft,opts);
fp = coeffvalues(fo);
end