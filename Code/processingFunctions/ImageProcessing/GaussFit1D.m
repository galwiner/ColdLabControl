

image = images(:,:,2,2,1);
[image,y,x] = ROISlicer(image,[105,159,151,191],1);
[X,Y]=meshgrid(x,y);
xGauss = squeeze(mean(image,1));
yGauss = squeeze(mean(image,2));

gaussEqn = 'a*exp(-(x-b)^2/(2*c^2))+d';
xstarpoints = [10,20,1,200];
ystarpoints = [10,30,1,200];
fitx = fit(x',xGauss',gaussEqn,'Start',xstarpoints);
fity = fit(y',yGauss,gaussEqn,'Start',ystarpoints);

[pf,gof,gauss2Dfit]=fitImageGaussian2D(x,y,image,[],[20,30]);

figure;
subplot(2,1,1)
plot(x,xGauss);
title('Gaussian in x');
hold on;
plot(x,fitx(x),'r');

subplot(2,1,2)
plot(y,yGauss);
title('Gaussian in y');
hold on;
plot(y,fity(y),'r');

dauss2D = (fitx.d+fity.d)/2+(fitx.a*fity.a)*exp(-(X-fitx.b).^2/(2*fitx.c^2)-(Y-fity.b).^2/(2*fity.c^2));
figure;
subplot(2,2,1)
imagesc(image);
title('Original image');

subplot(2,2,2)
imagesc(dauss2D);
title('1D gaussian fitted image');

subplot(2,2,3)
imagesc(gauss2Dfit);
title('2D gaussian fitted image');

