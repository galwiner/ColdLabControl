function [p,gof,fit_img] = fitImageGaussian2D(x_vec,y_vec,this_img,dilute_for_fit,varargin)
if nargin < 4
    dilute_for_fit = 1;
end
if nargin == 5
    cloud_center = varargin{1};
end

if isempty(x_vec)
    x_vec = 1:size(this_img,1);
end
if isempty(y_vec)
    y_vec = 1:size(this_img,2);
end
orig_x_vec = x_vec;
orig_y_vec = y_vec;
[orig_X_mat,orig_Y_mat] = ndgrid(orig_x_vec, orig_y_vec);
orig_this_img = this_img;

x_vec = x_vec(1:dilute_for_fit:end);
y_vec = y_vec(1:dilute_for_fit:end);
this_img = this_img(1:dilute_for_fit:end,1:dilute_for_fit:end);

x_diff = mean(diff(x_vec));
y_diff = mean(diff(y_vec));
[X_mat,Y_mat] = ndgrid(x_vec, y_vec);

x_avg = mean(this_img,2);
y_avg = mean(this_img,1);
bg = mean([x_avg(1),y_avg(1)]);
x_avg = x_avg-x_avg(1);
y_avg = y_avg-y_avg(1);

[x_max,x0_ind] = max(x_avg);
if nargin == 5
    x0_guess = cloud_center(1);
else
    x0_guess = x_vec(x0_ind);
end
[y_max,y0_ind] = max(y_avg);
if nargin == 5
    y0_guess = cloud_center(2);
else
    y0_guess = y_vec(y0_ind);
end

wx_guess = (x_vec(find(x_avg>x_max*0.6,1,'last')) - x_vec(find(x_avg>x_max*0.6,1)))/2;
if isempty(wx_guess)
    if ~wx_guess
        wx_guess = 5e-3;
    end
end
wy_guess = (y_vec(find(y_avg>y_max*0.6,1,'last')) - y_vec(find(y_avg>y_max*0.6,1)))/2;
if isempty(wy_guess)
    if ~wy_guess
        wy_guess = 5e-3;
    end
end
% 
% wx_guess=5;
% wy_guess=5;

try
    p0 = [bg, max(this_img(:)), x0_guess, y0_guess, wx_guess, wy_guess];
    fit_func = @(x,y,p) p(1) + p(2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)));
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
    p = fminsearch(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, optimset('Display', 'off', 'MaxIter', 100));
    % 		end
    fit_img = fit_func(orig_X_mat,orig_Y_mat,p);
    % 		figure; imagesc(fit_img);
    p(7) = 2*pi*p(2)*p(5)*p(6)/(x_diff*y_diff);
    % 	p(7) = sum(this_img(:));
catch
    fit_img = NaN(size(orig_this_img));
    p = NaN(1,7);
    p(7) = sum(orig_this_img(:));
    disp('Fit has failed!');
    
    
end

SStot=sum((this_img(:)-mean(this_img(:))).^2);
SSres=sum((this_img(:)-fit_img(:)).^2);
gof.R2=1-SSres/SStot;

if gof.R2 < 0.1
    p=p*0;
    fit_img=fit_img*0;
    warning('fit failed');
end

end