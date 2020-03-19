 clear all;
load('D:\Box Sync\Lab\ExpCold\Measurements\2017\11\26\261117_33.mat');

wx=3;
wy=3;
x=size(images,2);
y=size(images,1);

x= linspace(-x/2,x/2-1,x);
y= linspace(-y/2,y/2-1,y);
[X,Y]=meshgrid(x,y);
kernel=1/2/pi/wx/wy*exp(-X.^2/(2*wx.^2)-Y.^2/(2*wy.^2));
cleanimages=imcleaner(images(:,:,6),bgimg,kernel);
wx=wx+1;
wy=wx+1;
goFlag = 1;
while goFlag ==1
    kernel=1/2/pi/wx/wy*exp(-X.^2/(2*wx.^2)-Y.^2/(2*wy.^2));
    tmp=imcleaner(images(:,:,1),bgimg,kernel);
    if max(max(tmp))> max(max(cleanimages))
        cleanimages=tmp;
        wx=wx+1;
        wy=wx+1;
    else
        goFlag=0;
        wx=wx-1;
        wy=wx-1;
    end
   disp(['wx = ' num2str(wx)]); 
end
figure;
subplot(2,1,1)
imagesc(images(:,:,6));
title('Original image');

subplot(2,1,2)
imagesc(kernel);
title('optimal Match filter kernel');
