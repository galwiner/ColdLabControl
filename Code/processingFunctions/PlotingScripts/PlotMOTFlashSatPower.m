
imagesRS = reshape(images,[size(images,1),size(images,2),N,Navrg]);
avrgImgs = squeeze(mean(imagesRS,4));
x = (1:1:size(images,2))*pixCam.scale;
y = (1:1:size(images,1))*pixCam.scale;
bgimg = zeros(size(images,1),size(images,2));
[fp,gof,fimages]=vec2DgaussFit(x,y,avrgImgs,bgimg);
imageViewer(x,y,fimages)
figure;
plot(flashpowers,fp(7,:))
xlabel('Flash power (cooling power after DB-AOM)');
ylabel('Total pixel counts');
title('MOT flash power saturation')
set(gca,'FontSize',16)

%%
f = fp(7,:);
figure;
plot(flashpowers,f./(1-f))
