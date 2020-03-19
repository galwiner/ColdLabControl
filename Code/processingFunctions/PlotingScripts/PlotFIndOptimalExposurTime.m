avrgImgs = squeeze(mean(images,4));
x = (1:1:size(images,2))*4*1.65e-5;
y = (1:1:size(images,1))*4*1.65e-5;
bgimg = zeros(size(images,1),size(images,2));
[fp,gof,fimages]=vec2DgaussFit(x,y,avrgImgs,bgimg);

figure;
plot(expTimes,fp(7,:),'-o');
title('Total counts vs. exposure time, with 5 averages')
xlabel('Exposure time [\mus]')
ylabel('Total counts');
set(gca,'FontSize',16)

figure;
plot(expTimes,fp(5,:),'-o')
hold on
plot(expTimes,fp(6,:),'-o')
title('Widths vs. exposure time, with 5 averages')
xlabel('Exposure time [\mus]')
ylabel('Gaussian width');
legend('x','y')
set(gca,'FontSize',16)
