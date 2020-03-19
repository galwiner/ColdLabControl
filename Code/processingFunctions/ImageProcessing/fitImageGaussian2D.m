function [pf,gof,fit_img] = fitImageGaussian2D(x_vec,y_vec,this_img,dilute_for_fit,varargin)
%modified from Chen A & Dimitry Y's version. LD & GW Dec. 2017
%use with gaussianMatchedFilter for initial center guess for best results.
%best served cold
% fit_func = @(x,y,p) p(1) + sqrt(p(2)^2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)));
% p(7) is the integrated intensity in the gaussian (if there isn't a fit,
% then it takes the whole image)
if nargin < 4
    dilute_for_fit = 1;
end
if nargin == 5
    cloud_center = varargin{1};
end
if nargin == 6
    cloud_width = varargin{2};
end
if isempty(dilute_for_fit)
    dilute_for_fit=1;
end


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

x_vec = orig_x_vec(1:dilute_for_fit:end);
y_vec = orig_y_vec(1:dilute_for_fit:end);
this_img = this_img(1:dilute_for_fit:end,1:dilute_for_fit:end);

x_diff = mean(diff(x_vec));
y_diff = mean(diff(y_vec));
[X_mat,Y_mat] = meshgrid(x_vec, y_vec);

x_avg = mean(this_img,1);
y_avg = mean(this_img,2);
bg = mean([x_avg(1),y_avg(1)]);
x_avg = x_avg-x_avg(1);
y_avg = y_avg-y_avg(1);


if nargin >= 5 && ~isempty(cloud_center)
    x0_guess = cloud_center(1);
    orig_x0_guess = x0_guess;
    x0_ind = find(x_vec>x0_guess,1);
    assert(~isempty(x0_ind),'Bad x0_guess!');
    y0_guess = cloud_center(2);
    orig_y0_guess=y0_guess;
    y0_ind = find(y_vec>y0_guess,1);
    assert(~isempty(x0_ind),'Bad y0_guess!');
else
%     [x_max,x0_ind] = max(x_avg);
%     x0_guess = x_vec(x0_ind);
%     [y_max,y0_ind] = max(y_avg);
%     y0_guess = y_vec(y0_ind);
[~,maxInd] = max(this_img(:));
[y0_ind,x0_ind]=ind2sub(size(this_img),maxInd);
y0_guess=y_vec(y0_ind);
x0_guess=x_vec(x0_ind);
end

% smoothXgauss = smooth(this_img(y0_guess,:),19);
smoothXgauss = smooth(this_img(y0_ind,:),'sgolay');

tmpind = 1;
while tmpind<floor(length(x_vec)/2)
    maxInd=length(smoothXgauss);
    if x0_ind+tmpind>maxInd
        wx_guess = x_vec(x0_ind)-min(x_vec);
        break;
    end
    if (smoothXgauss(x0_ind+tmpind)-bg)<(smoothXgauss(x0_ind)-bg)*0.6
        wx_guess = x_vec(x0_ind+tmpind)-x_vec(x0_ind);
        break
    end
    tmpind=tmpind+1;
end

if ~exist('wx_guess')
    wx_guess=x_diff(1);
end
% wx_guess = find(smoothXgauus>smoothXgauus(x0_guess)*0.6,1,'last');
%wx_guess = (x_vec(find(x_avg> x_max*0.6,1,'last')) - x_vec(find(x_avg>x_max*0.6,1)))/2;
if isempty(wx_guess)
    if ~wx_guess
        wx_guess = 5e-3;
    end
end
% smoothYgauss = smooth(this_img(:,x0_guess),19);
smoothYgauss = smooth(this_img(:,x0_ind),'sgolay');
% wy_guess = find(smoothYgauus>smoothYgauus(y0_guess)*0.6,1,'last');

tmpind = 1;
while tmpind<floor(length(y_vec)/3)
    maxInd=length(smoothYgauss);
    if maxInd==y0_ind || y0_ind+tmpind>maxInd
        wy_guess = y_vec(y0_ind)-min(y_vec);
        break;
    end
    if (smoothYgauss(y0_ind+tmpind)-bg)<(smoothYgauss(y0_ind)-bg)*0.6
        wy_guess = y_vec(y0_ind+tmpind)-y_vec(y0_ind);
        break
    end
    tmpind=tmpind+1;
end
if ~exist('wy_guess')
    wy_guess=y_diff(1);
end
%wy_guess = (y_vec(find(y_avg>y_max*0.6,1,'last')) - y_vec(find(y_avg>y_max*0.6,1)))/2;
if isempty(wy_guess)
    if ~wy_guess
        wy_guess = 5e-3;
    end
end

%Crop image for ROI of +-4sigma

ROIFlag = 1;
scale = y_vec(2)-y_vec(1);
if (y0_guess-4*wy_guess)<y_vec(1) || (y0_guess+4*wy_guess)>y_vec(end)
    ROIFlag =0;
else
    ROIY = [y0_guess-4*wy_guess,y0_guess+4*wy_guess]/scale;
    y0_guess = 4*wy_guess+scale;
    y0_ind = find(y_vec>y0_guess,1);
end

if (x0_guess-4*wx_guess)<x_vec(1) || (x0_guess+4*wx_guess)>x_vec(end)
    ROIFlag =0;
else
    if ROIFlag == 1
        ROIX = [x0_guess-4*wx_guess,x0_guess+4*wx_guess]/scale;
        x0_guess = 4*wx_guess+scale;
        x0_ind = find(x_vec>x0_guess,1);
    end
end
if ROIFlag == 1
    
    [this_img,x_vec,y_vec]=ROISlicer(this_img,[ROIY,ROIX],scale);
    [X_mat,Y_mat] = meshgrid(x_vec, y_vec);
end
% figure;
% imagesc(this_img);
% hold on
% plot(x0_guess,wy_guess+y0_guess,'or');
% plot(wx_guess+x0_guess,y0_guess,'or');

try
    p0 = [bg, this_img(y0_ind,x0_ind), x0_guess, y0_guess, wx_guess, wy_guess];
    fit_func = @(x,y,p) p(1) + sqrt(p(2)^2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)));
    % 		if exist('lsqnonlin')
    % 			disp('I''m slow fix me! (fitImageGaussian2D)');
    %
    % 			options = optimset('lsqnonlin');
    % 			options.Display = 'none';
    % 			p = lsqnonlin(@(p) fit_func(X_mat,Y_mat,p) - this_img, p0, [], [], options);
    % 		elseif exist('fminsearchbnd')
    % 			if exist('cloud_center')
    % 				plb = [-3*abs(p0(1)) 0        cloud_center(1) cloud_center(3) 0.5e-3    0.5e-3];
    % 				pub = [ 3*abs(p0(1)) 3*p0(2)  cloud_center(2) cloud_center(4) 15e-3  15e-3  ];
    % 			else
    % 				plb = [-3*abs(p0(1)) 0        5*x_vec(1)   5*y_vec(1)   0.5e-3    0.5e-3];
    % 				pub = [ 3*abs(p0(1)) 3*p0(2)  5*x_vec(end) 5*y_vec(end) 15e-3  15e-3  ];
    %
    % 			end
    % 			p = fminsearchbnd(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, plb, pub, optimset('Display', 'off'));
    % 		else
    pf = fminsearch(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, optimset('Display', 'off', 'MaxIter', 1e6,'TolFun',1e-12,'MaxFunEvals',1e6));
    % 		end
    pf = abs(pf);
    if ROIFlag == 1
        fit_imgROI=fit_func(X_mat,Y_mat,pf);
        pf(3)=pf(3)+ROIX(1)*scale;
        pf(4)=pf(4)+ROIY(1)*scale;
    end
    fit_img = fit_func(orig_X_mat,orig_Y_mat,pf);
    % 		figure; imagesc(fit_img);
    pf(7) = 2*pi*pf(2)*pf(5)*pf(6)/(x_diff*y_diff);
    % 	p(7) = sum(this_img(:));
catch e
    fit_img = NaN(size(orig_this_img));
    pf = zeros(1,7);
    pf(7) = sum(orig_this_img(:));
    disp('Fit has failed!');
    disp(e.message)
    
    
    
end
% FillterdImg = filter2(1/16*ones(4),this_img);

% SStot=sum((FillterdImg(:)-mean(FillterdImg(:))).^2);
% SSres=sum((FillterdImg(:)-fit_img(:)).^2);
if ROIFlag == 1
    if ~isnan(pf(2))
SStot=sum((this_img(:)-mean(this_img(:))).^2);
SSres=sum((this_img(:)-fit_imgROI(:)).^2);
gof.R2=1-SSres/SStot;
% chisquared=sum((FillterdImg(:)-fit_img(:)).^2 ./ fit_img(:));
% gof.chi2=chisquared/(length(fit_img(:))-6);

chisquared=sum((this_img(:)-fit_imgROI(:)).^2 ./ fit_imgROI(:));
gof.chi2=chisquared/(length(fit_imgROI(:))-6);
    else
        gof.R2=0;
        gof.chi2=0;
    end
else
    SStot=sum((this_img(:)-mean(this_img(:))).^2);
SSres=sum((this_img(:)-fit_img(:)).^2);
gof.R2=1-SSres/SStot;
% chisquared=sum((FillterdImg(:)-fit_img(:)).^2 ./ fit_img(:));
% gof.chi2=chisquared/(length(fit_img(:))-6);

chisquared=sum((this_img(:)-fit_img(:)).^2 ./ fit_img(:));
gof.chi2=chisquared/(length(fit_img(:))-6);
end
global p
if ~isfield(p,'GaussianFitThreshold')
    p.GaussianFitThreshold = 0.0;
end
if gof.R2 < p.GaussianFitThreshold
    pf=pf*0;
    fit_img=fit_img*0;
    warning('fit failed');
end
end