clear all
load('D:\Box Sync\Lab\ExpCold\Measurements\2017\11\25\251117_05.mat');

%%

magGradValsZ = 0.376*1e2*currentVals;
magGradValsX=magGradValsZ/2;
magGradValsY=magGradValsZ/2;

CenterPixCamY = pp(3,:)-pp(3,end); %The centers of pixelfly y, which is the Z direction. 0 is the position at 220A
CenterPixCamX = pp(4,:)-pp(4,end); %The centers of pixelfly y, which is the Z direction. 0 is the position at 220A
%%

figure;
plot(1./magGradValsZ,CenterPixCamY,'ob');
xlabel('1/\nablaB_z [m/G]');
ylabel('Cloud displacement with respect to max gradiant[m]');

fPixY = fit(1./magGradValsZ',CenterPixCamY','poly1');
hold on;
plot(1./magGradValsZ,fPixY(1./magGradValsZ),'k');


plot(1./magGradValsY,CenterPixCamX,'or');
xlabel('1/\nablaB_z [m/G]');
ylabel('Cloud displacement with respect to max gradiant[m]');

fPixX = fit(1./magGradValsY',CenterPixCamX','poly1');
hold on;
plot(1./magGradValsY,fPixX(1./magGradValsY),'k');
legend('Cloud displacement in Z','Linear fit','Cloud displacement in Y','Linear fit')
title(['B_z = ' num2str(-fPixY.p1) '[G]. B_y = ' num2str(-fPixX.p1) '[G].'])
set(gca,'FontSize',16)
