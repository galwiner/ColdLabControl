clear all
imaqreset
global p
global r
global inst
DEBUG=0;
initp
p.expName='absorption image test';
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=0;
p.absImg{1} = 1;
if p.picsPerStep == 1
    p.calcTemp = 0;
else
    p.calcTemp = 1;
end
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.ROIWidth = 200;
p.ROIHeight = 200;
p.cameraParams{1}.ROI = [p.DTPos{1}(1)-p.ROIWidth/2,p.DTPos{1}(2)-p.ROIHeight/2,p.ROIWidth,p.ROIHeight];
p.cameraParams{1}.E2ExposureTime=1e3;
initinst
initr
%%  
% p.MOTReleaseTime = 1e3;
p.DTParams.MOTLoadTime = 0.75e6;
p.DTParams.TrapTime = 7e4;
% p.DTParams.TrapTime = 1;
p.AbsImgTime = 10;
p.pauseBetweenImages = 200e3;
p.tofTime = 1;
p.NAverage = 1;
p.s=sqncr();
p.s.addBlock({'LoadDipoleTrap'});

p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',p.pauseBetweenImages});
p.s.addBlock({'TakeAbsPic'});
p.s.addBlock({'GenPause','duration',10e3})
p.s.run();
%

%
bg = 200;
x = inst.cameras('pixelfly').x;
y = inst.cameras('pixelfly').y;

% imageViewer(r.images{1})
figure;
absIm = squeeze((mean(r.images{1}(:,:,1,:),4)-bg)./(mean(r.images{1}(:,:,2,:),4)-bg));
imagesc(x*1e6,y*1e6,absIm)
% imagesc(absIm)
figure;
plot(y*1e6,absIm(:,47));
hold on;
plot(x*1e6,absIm(50,:));
figure;
subplot(1,2,1)
imagesc(r.images{1}(:,:,1))
colorbar
subplot(1,2,2)
imagesc(r.images{1}(:,:,2))
colorbar
% figure;histogram(r.images{1}(:,:,2))
% figure;histogram(r.images{1}(:,:,1))
%%
bg = 200;
absIm = squeeze((mean(r.images{1}(:,:,1,1,:,:),6)-bg)./(mean(r.images{1}(:,:,2,1,:,:),6)-bg));
scale = 4.0994;
x0 = 46;
y0 = 51;
ycros = absIm(:,x0);
xcros = absIm(y0,:);
x = (-50:49)*scale;
y = x;
fp0 = [10,1,0.08,x0,3,y0,10];
fp = fitAbsImCrossections(xcros,ycros',fp0);
figure;
subsubplot([1,1,1],[2,2,1]);
imagesc(x,y,r.images{1}(:,:,1))
title('image with atoms')
xlabel('x [\mum]');
ylabel('y [\mum]');
colorbar

subsubplot([1,1,1],[2,2,2]);
imagesc(x,y,r.images{1}(:,:,2))
title('ref image - no atoms')
xlabel('x [\mum]');
ylabel('y [\mum]');
colorbar

subsubplot([1,1,1],[2,2,3]);
imagesc(x,y,absIm)
colorbar
title('normelized image')
xlabel('x [\mum]');
ylabel('y [\mum]');

[~,panel] = subsubplot([2,1,1],[2,2,4]);
plot(x,ycros,'o')
hold on
plot(x,fit_func(1:100,fp,0))
% set(panel.Title,'Interpreter','latex')
panel.Title = sprintf('OD = %0.1f, sigma_x= %0.1f um, sigma_y = %0.1f um',fp(1),fp(5)*scale,fp(7)*scale);
panel.FontSize = 16;
xlabel('x [\mum]');
legend('data','fit','fontsize',10)
title('y cross-section')
subsubplot([2,1,2],[2,2,4]);
plot(x,xcros,'o')
hold on
plot(x,fit_func(1:100,fp,1))
xlabel('x [\mum]');
legend('data','fit','fontsize',10)
title('x cross-section')


function res = fit_func(x,p,state)
%state selects between x and y cross
switch state
    case 1 %x
        res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(4)).^2/(2*p(5)^2)));
    case 0 %y
       res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(6)).^2/(2*p(7)^2)));
end 
end
