function [p,fit_img] = fitImageGaussian2D(x_vec,y_vec,this_img,dilute_for_fit,varargin)

% Written by Chen and Dimitry
%
% Fit image to a 2D Gaussian
%
% Params:
% - x_vec is a vector containing the scaled x coordinates, if empty a 1:1
%   scale is assumed
% - y_vec same as x_vex (but for y, duh!)
% - this_imag (matrix) is the image to fit
% - dilute_for_fitting (int) is the binning size. Default no binning.
% - varargin is an optional argument giving the position of the cloud center
%
% Returns:
% - p is a vector with the fit results to p(1) + p(2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)))
%       - p(1) is the zero offset value
%       - p(2) is the height of the gaussian
%       - p(3) and p(4) is the position of the center of the gaussian in x
%         and y, respectively
%       - p(5) and p(6) is the width in x and y, respectively
%       - p(7) returns 2*pi*p(2)*p(5)*p(6)/(x_diff*y_diff)
% - fit_img is an image (matrix) of the best fit gaussian

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
	[orig_X_mat,orig_Y_mat] = ndgrid(orig_x_vec, orig_y_vec); %nd grid pre-coarse grain
	orig_this_img = this_img;
	
	x_vec = x_vec(1:dilute_for_fit:end); %coars graining the x vec 
	y_vec = y_vec(1:dilute_for_fit:end); %coarse graining the y vec 
	this_img = this_img(1:dilute_for_fit:end,1:dilute_for_fit:end); %coarse graining the image
	
	x_diff = mean(diff(x_vec));
	y_diff = mean(diff(y_vec));
	[X_mat,Y_mat] = ndgrid(x_vec, y_vec); %nd grid after coarse graining
		
	x_avg = mean(this_img,2); %mean in the y direction 
	y_avg = mean(this_img,1); %mean in the x direction
	bg = mean([x_avg(1),y_avg(1)]); %background reading is the average signal at the edge of the screen 
	x_avg = x_avg-x_avg(1); %subtract x background from x avg
	y_avg = y_avg-y_avg(1);%subtract y background from y avg
	
	[x_max,x0_ind] = max(x_avg); %find the max postion in x (x_avg is a col vector)
	x0_guess = x_vec(x0_ind);
	[y_max,y0_ind] = max(y_avg);%find the max postion in y (y_avg is a col vector)
	y0_guess = y_vec(y0_ind);
	
	wx_guess = (x_vec(find(x_avg>x_max*0.6,1,'last')) - x_vec(find(x_avg>x_max*0.6,1)))/2; %guess a width in x by finding coordinates of 60% of the mean value
	if isempty(wx_guess)
		if ~wx_guess
			wx_guess = 5e-3; %if you failed guessing, guess 5 mm (i assume MKS was used)
		end 
	end
	wy_guess = (y_vec(find(y_avg>y_max*0.6,1,'last')) - y_vec(find(y_avg>y_max*0.6,1)))/2; %same for y
	if isempty(wy_guess)
		if ~wy_guess
			wy_guess = 5e-3;
		end
	end
	
	try
		p0 = [bg, max(this_img(:)), x0_guess, y0_guess, wx_guess, wy_guess];
		fit_func = @(x,y,p) p(1) + p(2)*exp(-((x-p(3)).^2/(2*p(5)^2))-((y-p(4)).^2/(2*p(6)^2)));
		if exist('lsqnonlin')
			options = optimset('lsqnonlin');
			options.Display = 'none';
			p = lsqnonlin(@(p) fit_func(X_mat,Y_mat,p) - this_img, p0, [], [], options); %the least squares function takes a cost function: the difference between a perfect gaussian and our measuremnt. it returns the optimal parameters to minize the cost function: p
		elseif exist('fminsearchbnd')
			if exist('cloud_center')
				plb = [-3*abs(p0(1)) 0        cloud_center(1) cloud_center(3) 0.5e-3    0.5e-3];
				pub = [ 3*abs(p0(1)) 3*p0(2)  cloud_center(2) cloud_center(4) 15e-3  15e-3  ];
			else
				plb = [-3*abs(p0(1)) 0        5*x_vec(1)   5*y_vec(1)   0.5e-3    0.5e-3];
				pub = [ 3*abs(p0(1)) 3*p0(2)  5*x_vec(end) 5*y_vec(end) 15e-3  15e-3  ];

			end
			p = fminsearchbnd(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, plb, pub, optimset('Display', 'off'));
		else 
			p = fminsearch(@(p) sum(sum((fit_func(X_mat,Y_mat,p) - this_img).^2)), p0, optimset('Display', 'off'));
			
		end
		fit_img = fit_func(orig_X_mat,orig_Y_mat,p); %an image of the best fit gaussian
% 		figure; imagesc(fit_img);
		p(7) = 2*pi*p(2)*p(5)*p(6)/(x_diff*y_diff); %2*pi*max*wx*wy/deltax/deltay 
	% 	p(7) = sum(this_img(:));
        p(8) = fit_func(p(5)/2,p(6)/2,p);
    catch myErr
		fit_img = NaN(size(orig_this_img));
		p = NaN(1,7);
		p(7) = sum(orig_this_img(:));
		disp('Fit has failed!');
        myErr
       
	end
	
% 	ci = nlparci(p,res,J);
% 	s = diff(ci,2)/2;
end