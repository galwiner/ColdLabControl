imag = imread('D:\Box Sync\Lab\ExpCold\Measurements\2017\12\11\bg.tif');
figure;
imagesc(imag);
colormap('gray');
figure;
plot(imag(550,:))