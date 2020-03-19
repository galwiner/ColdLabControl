
arrSize=size(images);
imsize=[arrSize(1),arrSize(2)];
imvec=reshape(images,[arrSize(1),arrSize(2),arrSize(3)*arrSize(4)*arrSize(5)]);

x=linspace(-10,10,1000);6

max_val=80;
width=0.1;
gaussian=max_val * exp(-x.^2/2/width^2);
% noise=random('Normal',sqrt(gaussian),1,size(gaussian));
shot_noise=poissrnd(sqrt(gaussian),size(gaussian));
noise_floor=poissrnd(200,size(gaussian));
signal=gaussian+noise_floor+shot_noise;
bg=poissrnd(200,size(gaussian));
signal=signal-bg;
sample_pts=[1:50:1000];
sampled_data=signal(sample_pts);

[f,gof]=fit(x(sample_pts)',sampled_data','gauss1');
figure
hold on;
plot(x,signal,'-r')
plot(x(sample_pts),sampled_data,'o')
plot(x,f(x),'-b')
title(sprintf('%.2f',gof.rsquare))
% 
figure;
testImg=imvec(:,:,1)-bgimg;
[f,gof]=fit([1:260]',testImg(:,171),'gauss1');
hold on
plot(testImg(:,171))

% imagesc(images(:,:,1))
xx=1:0.01:260;
yy=spline(1:260,testImg(:,171),xx)';
plot(xx,yy,'-')
[f,gof]=fit(xx',yy,'gauss1');
plot(xx,f(xx),'-')