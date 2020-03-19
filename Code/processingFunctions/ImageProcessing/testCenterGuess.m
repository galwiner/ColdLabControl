testImages = images(:,:,:,2,3);
imvec=reshape(images,[arrSize(1),arrSize(2),arrSize(3),arrSize(4)*arrSize(5)]);
x=linspace(0,arrSize(2)-1,arrSize(2))*pixCam.scale;
y=linspace(0,arrSize(1)-1,arrSize(1))*pixCam.scale;
x0 = 171*pixCam.scale;
y0 = 133*pixCam.scale;
g=9.8;
delayList=[200,1000,3000,5000,10000]*1e-6; %times for the TOF flights in microseconds

% figure;
% subplot(3,2,1)
% imagesc(x,y,testImages(:,:,1));
% hold on
% plot(x0,y0,'or');
% 
% for ind = 2:length(delayList)
%     subplot(3,2,ind)
%     imagesc(x,y,testImages(:,:,ind));
%     hold on
%     plot(x0,y0-g/2*delayList(ind)^2,'or');
% end
figure;
imagesc(sum(imvec(:,:,1,:),4));