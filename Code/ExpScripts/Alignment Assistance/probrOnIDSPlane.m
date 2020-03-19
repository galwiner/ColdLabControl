initp
clear ids
clear im
ids = idsCam('plane');
ids.cam.Timing.Exposure.Long.SetEnable(true)
ids.setExposure(1e6);
nav = 1;
im = zeros([1024,1280,nav]);
figure;
for jj = 1:100
for ii = 1:nav
im(:,:,ii) = ids.getImage;
end
hold off;

imagesc(mean(im,3));
caxis([2,8])
hold on;
plot(1:size(im,2),p.DTPos{2}(2)*ones(1,size(im,2)),'r')
pause(0.3);
end
