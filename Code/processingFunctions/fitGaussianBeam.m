function [fitParams,fitImage] = fitGaussianBeam(im,initParams,scale,varargin)
%L.D 08/11/18. this function fits an image to a gaussian beam
%scale is important because of the dependense in wavelength
%The model is Im =
%I0*1/(1+((x-x0)/xr)^2)*exp(-2*(y-y0)^2/(w0^2*(1+x^2/xr^2), where
%xr=pi*w0^2/780e-9
%initParams = [x0,y0,w0,I0,bias]
x_vec = (1:size(im,2))*scale;
y_vec = (1:size(im,1))*scale;
[X,Y] = meshgrid(x_vec,y_vec);
lambda = 780e-9;
% fitFunc = @(x0,y0,w0,I0,bias,x,y) I0*1./(1+(x-x0).^2/(pi*w0^2/lambda)^2).*...
%     exp(-2*((y-y0).^2)./(w0^2*(1+(x-x0).^2/(pi*w0^2/lambda)^2)))+bias;
%p = [x0,y0,w0,I0,bias]
fitFunc = @(x,y,p) p(4)*1./(1+(x-p(1)).^2/(pi*p(3)^2/lambda)^2).*...
    exp(-2*((y-p(2)).^2)./(p(3)^2*(1+(x-p(1)).^2/(pi*p(3)^2/lambda)^2)))+p(5);
p0 = initParams;
fp = fminsearch(@(p) sum(sum((fitFunc(X,Y,p) - im).^2)), p0,...
    optimset('Display', 'off', 'MaxIter', 1e6,'TolFun',1e-12));
fitParams = fp;
fitImage = fp(4)*1./(1+(X-fp(1)).^2/(pi*fp(3)^2/lambda)^2).*...
    exp(-2*((Y-fp(2)).^2)./(fp(3)^2*(1+(X-fp(1)).^2/(pi*fp(3)^2/lambda)^2)))+fp(5);
end