function [fp,gof,fit_img] = fitODGaussian(x_vec,y_vec,this_img,varargin)
%modified from Chen A & Dimitry Y's version. LD & GW Dec. 2017
%use with gaussianMatchedFilter for initial center guess for best results.
%best served cold
% fit_func = @(x,y,p) p(1) + sqrt(p(2)^2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)));
% p(7) is the integrated intensity in the gaussian (if there isn't a fit,
% then it takes the whole image)
%varargin should be in the form of parameter name and valeu pairs.
%varargin options are :'cloud_center','cloudXwidth','cloudYwidth'.
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

% if nargin == 5
%     cloud_width = varargin{2};
% end
if isempty(x_vec)
    x_vec = 1:size(this_img,2);
end
if isempty(y_vec)
    y_vec = 1:size(this_img,1);
end
orig_x_vec = x_vec;
orig_y_vec = y_vec;
[orig_X_mat,orig_Y_mat] = meshgrid(orig_x_vec, orig_y_vec);
orig_this_img = this_img;

% x_vec = orig_x_vec(1:dilute_for_fit:end);
% y_vec = orig_y_vec(1:dilute_for_fit:end);
% this_img = this_img(1:dilute_for_fit:end,1:dilute_for_fit:end);

x_diff = mean(diff(x_vec));
y_diff = mean(diff(y_vec));
[X_mat,Y_mat] = meshgrid(x_vec, y_vec);

x_avg = mean(this_img,1);
y_avg = mean(this_img,2);
bg = mean([x_avg(1),y_avg(1)]);
x_avg = x_avg-x_avg(1);
y_avg = y_avg-y_avg(1);


if exist('cloud_center')
    x0_guess = cloud_center(1);
    orig_x0_guess = x0_guess;
    x0_ind = find(x_vec>x0_guess,1);
    y0_guess = cloud_center(2);
    orig_y0_guess=y0_guess;
    y0_ind = find(y_vec>y0_guess,1);
else
[~,minInd] = min(abs(this_img(:)));
[y0_ind,x0_ind]=ind2sub(size(this_img),minInd);
y0_guess=y_vec(y0_ind);
x0_guess=x_vec(x0_ind);
end
if ~exist('wx_guess')
smoothXgauss = smooth(this_img(y0_ind,:),'sgolay');
tmpind = 1;
while tmpind<floor(length(x_vec)/2)
    minInd=length(smoothXgauss);
    if x0_ind+tmpind>minInd
        wx_guess = x_vec(x0_ind)-min(x_vec);
        break;
    end
    if (smoothXgauss(x0_ind+tmpind))>(exp(log(smoothXgauss(x0_ind))*exp(-0.5)))
        wx_guess = x_vec(x0_ind+tmpind)-x_vec(x0_ind);
        break
    end
    tmpind=tmpind+1;
end
end
if ~exist('wx_guess')
    wx_guess=x_diff(1);
end

if isempty(wx_guess)
    if ~wx_guess
        wx_guess = 5e-3;
    end
end
if ~exist('wy_guess')
smoothYgauss = smooth(this_img(:,x0_ind),'sgolay');
tmpind = 1;
while tmpind<floor(length(y_vec)/3)
    minInd=length(smoothYgauss);
    if minInd==y0_ind || y0_ind+tmpind>minInd
        wy_guess = y_vec(y0_ind)-min(y_vec);
        break;
    end
    if (smoothYgauss(y0_ind+tmpind))>(exp(log(smoothXgauss(x0_ind))*exp(-0.5)))
        wy_guess = y_vec(y0_ind+tmpind)-y_vec(y0_ind);
        break
    end
    tmpind=tmpind+1;
end
end
if ~exist('wy_guess')
    wy_guess=y_diff(1);
end
% if isempty(wy_guess)
%     if ~wy_guess
%         wy_guess = 5e-3;
%     end
% end

%Crop image for ROI of +-4sigma

% ROIFlag = 1;
% scale = y_vec(2)-y_vec(1);
% if (y0_guess-4*wy_guess)<y_vec(1) || (y0_guess+4*wy_guess)>y_vec(end)
%     ROIFlag =0;
% else
%     ROIY = [y0_guess-4*wy_guess,y0_guess+4*wy_guess]/scale;
%     y0_guess = 4*wy_guess+scale;
%     y0_ind = find(y_vec>y0_guess,1);
% end
% 
% if (x0_guess-4*wx_guess)<x_vec(1) || (x0_guess+4*wx_guess)>x_vec(end)
%     ROIFlag =0;
% else
%     if ROIFlag == 1
%         ROIX = [x0_guess-4*wx_guess,x0_guess+4*wx_guess]/scale;
%         x0_guess = 4*wx_guess+scale;
%         x0_ind = find(x_vec>x0_guess,1);
%     end
% end
% if ROIFlag == 1
%     
%     [this_img,x_vec,y_vec]=ROISlicer(this_img,[ROIY,ROIX],scale);
%     [X_mat,Y_mat] = meshgrid(x_vec, y_vec);
% end
try
%     p0 = [0,-log(abs(this_img(y0_ind,x0_ind))), x0_guess, y0_guess, wx_guess, wy_guess,imbalance_guess];
%     fit_func = @(x,y,p) p(1) + p(7)*exp(-abs(p(2))*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2))));
    p0 = [-log(abs(this_img(y0_ind,x0_ind))), x0_guess, y0_guess, wx_guess, wy_guess,imbalance_guess];
    fit_func = @(x,y,p) p(6)*exp(-abs(p(1))*exp(-((x-p(2)).^2/(2*p(4)^2))-((y-p(3)).^2/(2*p(5)^2))));
    fp = fminsearch(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, optimset('Display', 'off', 'MaxIter', 1e8,'TolFun',1e-16));
    fp = abs(fp);
%     if ROIFlag == 1
%         fit_imgROI=fit_func(X_mat,Y_mat,fp);
%         fp(3)=fp(3)+ROIX(1)*scale;
%         fp(4)=fp(4)+ROIY(1)*scale;
%     end
    fit_img = fit_func(orig_X_mat,orig_Y_mat,fp);
catch e
    fit_img = NaN(size(orig_this_img));
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