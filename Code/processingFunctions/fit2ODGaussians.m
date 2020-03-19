function [fp,gof,fit_img] = fit2ODGaussians(x_vec,y_vec,this_img,varargin)
%This function fits, using fminsearch, an image to 2 Gauissans
if nargin > 3
    parsFlag = 0;
    cloud_centerInd = find(strcmpi(varargin,'cloud_center'));
    if ~isempty(cloud_centerInd)
        cloud_center = varargin{cloud_centerInd+1};
        parsFlag = 1;
    end
    cloudXwidthInd = find(strcmpi(varargin,'cloudXwidth'));
    if ~isempty(cloudXwidthInd)
        wx_guess = varargin{cloudXwidthInd+1};
        parsFlag = 1;
    end
    cloudYwidthInd = find(strcmpi(varargin,'cloudYwidth'));
    if ~isempty(cloudYwidthInd)
        wy_guess = varargin{cloudYwidthInd+1}; %should be [xWidth,yWidth]
        parsFlag = 1;
    end
    imbalanceInd = find(strcmpi(varargin,'imbalance'));
    if ~isempty(imbalanceInd)
        imbalance_guess = varargin{imbalanceInd+1};
        parsFlag = 1;
    else
        imbalance_guess = 1;
    end 
    if parsFlag==0
        warning('more than 3 input arguments ware entered, but no parsing was made.\nAvalble inputs are: ''cloud_center'', ''cloudXwidth'', and ''cloudXwidth''');
    end
else
    imbalance_guess = 1;
end
if isempty(x_vec)
    x_vec = 1:size(this_img,2);
end
if isempty(y_vec)
    y_vec = 1:size(this_img,1);
end
x_diff = mean(diff(x_vec));
y_diff = mean(diff(y_vec));
[X_mat,Y_mat] = meshgrid(x_vec, y_vec);
if exist('cloud_center')
    x0_guess = cloud_center(1);
    x0_ind = find(x_vec>x0_guess,1);
    y0_guess = cloud_center(2);
    y0_ind = find(y_vec>y0_guess,1);
else
[~,minInd] = min(abs(this_img(:)));
[y0_ind,x0_ind]=ind2sub(size(this_img),minInd);
y0_guess=y_vec(y0_ind);
x0_guess=x_vec(x0_ind);
end
try
%     p0 = [0,-log(abs(this_img(y0_ind,x0_ind))), x0_guess, y0_guess, wx_guess, wy_guess,...
%         -log(abs(this_img(y0_ind,x0_ind)))/5, x0_guess, y0_guess, wx_guess*3, wy_guess*3,imbalance_guess];
%     fit_func = @(x,y,p) p(1)+p(12)*exp(-abs(p(2))*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)))).*...
%         exp(-abs(p(7))*exp(-((x-p(8)).^2/(2*p(10)^2))-((y-p(9)).^2/(2*p(11)^2))));
    p0 = [-log(abs(this_img(y0_ind,x0_ind))), x0_guess, y0_guess, wx_guess, wy_guess,...
        -log(abs(this_img(y0_ind,x0_ind)))/5, x0_guess, y0_guess, wx_guess*3, wy_guess*3,imbalance_guess];
    fit_func = @(x,y,p) p(11)*exp(-abs(p(1))*exp(-((x-p(2)).^2/(2*p(4)^2))-((y-p(3)).^2/(2*p(5)^2)))).*...
        exp(-abs(p(6))*exp(-((x-p(7)).^2/(2*p(9)^2))-((y-p(8)).^2/(2*p(10)^2))));
    fp = fminsearch(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, optimset('Display', 'off', 'MaxIter', 1e8,'TolFun',1e-16));
    fp = abs(fp);
%     if ROIFlag == 1
%         fit_imgROI=fit_func(X_mat,Y_mat,fp);
%         fp(3)=fp(3)+ROIX(1)*scale;
%         fp(4)=fp(4)+ROIY(1)*scale;
%     end
    fit_img = fit_func(X_mat,Y_mat,fp);
catch e
    fit_img = NaN(size(this_img));
    fp = zeros(1,7);
    disp('Fit has failed!');
    disp(e.message) 
end
% if ROIFlag == 1
%     if ~isnan(fp(2))
% SStot=sum((this_img(:)-mean(this_img(:))).^2);
% SSres=sum((this_img(:)-fit_imgROI(:)).^2);
% gof.R2=1-SSres/SStot;
% % chisquared=sum((FillterdImg(:)-fit_img(:)).^2 ./ fit_img(:));
% % gof.chi2=chisquared/(length(fit_img(:))-6);
% 
% chisquared=sum((this_img(:)-fit_imgROI(:)).^2 ./ fit_imgROI(:));
% gof.chi2=chisquared/(length(fit_imgROI(:))-6);
%     else
%         gof.R2=0;
%         gof.chi2=0;
%     end
% else
SStot=sum((this_img(:)-mean(this_img(:))).^2);
SSres=sum((this_img(:)-fit_img(:)).^2);
gof.R2=1-SSres/SStot;
% chisquared=sum((FillterdImg(:)-fit_img(:)).^2 ./ fit_img(:));
% gof.chi2=chisquared/(length(fit_img(:))-6);

chisquared=sum((this_img(:)-fit_img(:)).^2 ./ fit_img(:));
gof.chi2=chisquared/(length(fit_img(:))-6);
% end
global p
% 
% if gof.R2 < p.GaussianFitThreshold
%     fp=fp*0;
%     fit_img=fit_img*0;
%     warning('fit failed');
% end
end