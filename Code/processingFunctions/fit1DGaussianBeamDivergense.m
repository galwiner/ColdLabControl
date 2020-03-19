function [fitobj,gof] = fit1DGaussianBeamDivergense(distances,waists,initParams,varargin)
%L.D 08/11/18. this function fits to a 1D Gaussian beam divergense, returning the z0
%and w0. 
%The model is Im =
%w = w0*sqrt(1+lambda^2*(z-z0)^2/(pi^2*w0^4))
%initParams = [w0,z0]
if nargin >3
    lambda = varargin{1};
else
    lambda = 780e-9;
end
x=distances;
y=waists;
fitFunc = @(w0,z0,x) w0*sqrt(1+lambda^2*(x-z0).^2/(pi^2*w0^4));
ft = fittype(fitFunc,'independent','x', 'dependent','y','coefficients',{'w0','z0'});
p0 = initParams;
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.StartPoint = p0;
[fitobj,gof] =fit(x',y',ft,opts);
end