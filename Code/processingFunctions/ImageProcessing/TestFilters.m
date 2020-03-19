clear all
load('D:\Box Sync\Lab\ExpCold\Measurements\2017\12\11\111217_03.mat');
img = images(:,:,5)-bgimg; %TOF after 10ms minus the background
img(img<0)=0;
x = 1:1:size(img,2);
y = 1:1:size(img,1);
[X,Y]=meshgrid(x,y);
sigx = 10;
sigy = 10;
% img = 20*exp(-(X-size(img,2)/2).^2/2/sigx^2-(Y-size(img,1)/2).^2/2/sigy^2);
% img = img+ poissrnd(100,size(img));
% img = img- poissrnd(100,size(img));
%unfilters fit
unfiltimg = img;
unfiltimg(unfiltimg<0)=0;
[puf,gofuf,fituf]=fitImageGaussian2D([],[],unfiltimg);

% filter2 with 4x4 ones matrix (normelized)
filt2img = filter2(1/16*ones(4),img,'same');
filt2img(filt2img<0)=0;
[pf2,goff2,fitf2]=fitImageGaussian2D([],[],filt2img);

%Gaussian smothening with sigma=3
filtgus = imgaussfilt(img,3);
filtgus(filtgus<0)=0;
[pgus,gofgus,fitgus]=fitImageGaussian2D([],[],filtgus);

figure;
subplot(3,2,1)
imagesc(unfiltimg);
title('unfiltered image');
subplot(3,2,2)
imagesc(fituf);
title(['unfiltered image fit. R^2 = ' num2str(gofuf.R2)]);

subplot(3,2,3)
imagesc(filt2img);
title('filter2 image');
subplot(3,2,4)
imagesc(fitf2);
title(['filter2 image fit. R^2 = ' num2str(goff2.R2)]);

subplot(3,2,5)
imagesc(filtgus);
title('Gaussinan filter with \sigma =3');
subplot(3,2,6)
imagesc(fitgus);
title(['Gaussinan filter fit. R^2 = ' num2str(gofgus.R2)]);


