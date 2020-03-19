% clear all
% load(271217_07.mat);

imagesRS = reshape(images,[size(images,1),size(images,2),N,Navrg]);
%imageViewer([],[],imagesRS(:,:,:,1))
avrgImgs =squeeze(mean(imagesRS,4));
x = (1:1:size(images,2))*pixCam.scale;
y = (1:1:size(images,1))*pixCam.scale;

[fp,gof,fimages]=vec2DgaussFit(x,y,avrgImgs,bgimg);
%[fp2,gof2,fimages2]=vec2DgaussFit(x,y,images,bgimg);
%fimages2RS = reshape(fimages2,[size(images,1),size(images,2),N,Navrg]);
%avgfimages2RS = squeeze(mean(fimages2RS,4));
imageViewer(x,y,avrgImgs)
imageViewer(x,y,fimages)
%imageViewer(x,y,avgfimages2RS)

%RSfp2=reshape(fp2,[7,N,Navrg]);
%avgfp2 = squeeze(mean(RSfp2,3));

figure;
 plot(detList/consts.Gamma,fp(7,:))
% hold on;
% plot(detList/consts.Gamma,avgfp2(7,:))
xlabel('Flash detuning[\Gamma]')
ylabel('Integrated counts');
title('MOT flash resonance search. flash power = 40mW, exposure time = 50\mus')
set(gca,'FontSize',16)