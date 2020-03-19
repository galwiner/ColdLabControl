% 'magnetic trapping for bias compensation'

clear all
global p
global r
global inst
DEBUG=0;
initp
p.hasScopResults=0;
p.hasPicturesResults=1;
p.pfLiveMode=0;
p.tcLiveMode=0;
p.postprocessing=1;
p.DEBUG=DEBUG;
p.coolingDet = -5.5*p.consts.Gamma;
p.cameraParams{1}.E2ExposureTime = 50;
p.cameraParams{2}.E2ExposureTime = 10;
% p.cameraParams{2}.exposure = 700;
p.HHYCurrent=-0.081642822765022;
p.HHXCurrent = 0.047549575225662; %in A 
p.HHZCurrent=0.047061927028999;
p.circCurrent=40;

p.expName='bias compensation with strong and week MOT';
numStepsField = 10;
numStepsPower=1;
p.loopVals = {linspace(-0.02,0.15,numStepsField),linspace(880,880,numStepsPower)};
p.loopVars = {'HHXCurrent','coolingPower'};

p.picsPerStep=2;
% p.coolingPower = 300;
p.NAverage=1;

% coolingPowerVals = linspace(250,880,numSteps);
% p.loopVals={coolingPower};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;

p.magneticTrapSettleTime=80e3;
p.compressionTime = 5e3;
p.compressionEndCurrent = 220;
initinst
initr
%%
p.s.getbgImg;
p.s=sqncr();
p.s.addBlock({'setHH','direction','x','value',p.HHXCurrent})
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',100});
p.s.addBlock({'pause','duration',50e3});
% p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',50e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',2e3});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',5e5});
p.s.run;
%%
% figure
% plot(p.loopVals{1},squeeze(r.fitParams{1}(4,1,:)),'bo');
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{1}(4,2,:)),'ko');
% legend('Z position at 40 A','Z position at 220 A')
% figure
% plot(p.loopVals{1},squeeze(r.fitParams{1}(3,1,:)),'ro');
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{1}(3,2,:)),'mo');
% legend('Y position at 40 A','Y position at 220 A')
%Plot Thorcam resolts
% figure
% plot(p.loopVals{1},squeeze(r.fitParams{2}(4,1,:)),'bo');
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{2}(4,2,:)),'ko');
% legend('Z position at 40 A','Z position at 220 A')
% figure
% plot(p.loopVals{1},squeeze(r.fitParams{2}(3,1,:)),'ro');
% hold on
% plot(p.loopVals{1},squeeze(r.fitParams{2}(3,2,:)),'mo');
% legend('Y position at 40 A','Y position at 220 A')
%%
% imageViewer(squeeze(r.images{1}(:,:,2,:))-r.bgImg{1})

cam=2;
XbiasField=zeros(1,length(p.loopVals{2}));
ydata1 = squeeze(r.fitParams{cam}(3,1,:,:,:));
ydata2 = squeeze(r.fitParams{cam}(3,2,:,:,:));
ydata1(ydata1==0)=nan;
ydata2(ydata2==0)=nan;
ydata1mean = mean(ydata1,ndims(ydata1),'omitnan');
ydata2mean = mean(ydata2,ndims(ydata2),'omitnan');
ydata1var = std(ydata1,1,ndims(ydata1));
ydata2var = std(ydata2,1,ndims(ydata2));
XBiasFieldVar=zeros(length(p.loopVals{2}));
XBiasFieldMean=zeros(length(p.loopVals{2}));
for ind=1:length(p.loopVals{2})
%     try
    xvals=p.loopVals{1};
    for jnd=1:p.NAverage
%     nanInd = find(isnan(ydatamean(ind,:)));
%     excData = excludedata(p.loopVals{1}',ydatamean(ind,:)','indices',nanInd);
%     [f1,gof1]=fit(xvals',ydata1mean(ind,:)','poly1');
%     [f2,gof2]=fit(xvals',ydata2mean(ind,:)','poly1');

    [f1,gof1]=fit(xvals',ydata1(:,jnd),'poly2');
    [f2,gof2]=fit(xvals',ydata2(:,jnd),'poly2');
    conf1=confint(f1,0.95);
    conf2=confint(f2,0.95);
    dp2_1=mean(conf1(:,2));
    dp2_2=mean(conf2(:,2));
    dp1_1=mean(conf1(:,1));
    dp1_2=mean(conf2(:,1));
     XbiasField(ind,jnd)=(-(f1.p2-f2.p2)-sqrt((f1.p2-f2.p2)^2-4*(f1.p1-f2.p1)*(f1.p3-f2.p3)))/(2*(f1.p1-f2.p1));    
%     XbiasField(ind,jnd)=(f2.p2-f1.p2)./(f1.p1-f2.p1);
%     XbiasFieldError(ind)=sqrt(dp2_2^2+dp2_1^2)/(f1.p1-f2.p1)-sqrt(dp2_1^2+dp2_2^2)/(f1.p1-f2.p1)^2 *(f1.p2-f2.p2);
    figure;
    plot(p.loopVals{1}',ydata1(:,jnd),'or');
    hold on
    plot(p.loopVals{1},f1(p.loopVals{1}),'-r');
    plot(p.loopVals{1},f2(p.loopVals{1}),'-b');
    plot(p.loopVals{1}',ydata2(:,jnd),'ob');
    plot(XbiasField(ind),f2(XbiasField(ind,jnd)),'rs','MarkerSize',10,'MarkerFace','r');
    end
    
    
    
%     catch err
%         error(err.identifier,'Error on ind == %d',ind,err.message)
%     end
end
% XBiasFieldVar=var(XbiasField,1,2);
% XBiasFieldMean=mean(XbiasField,2);
% XBiasFieldMean=XbiasField(:,1);
% XBiasFieldVar=zeros(size(XBiasFieldMean));
% f3=fit(p.loopVals{2}',XBiasFieldMean,'poly1');
% 
% figure;
% errorbar(p.loopVals{2},1e3*8.49*XBiasFieldMean,1e3*8.49*XBiasFieldVar,'ob-');
% hold on
% plot(p.loopVals{2}',1e3*8.49*f3(p.loopVals{2}),'r-')
% xlabel('Cooling power [mW]');
% ylabel('field intercept [10^{-3} gauss]');
% title('bias field in Y for different cooling powers');
% % X axis bias coils: 4.35 gauss/ampere
% % Y axis bias coils: 8.49 gauss/ampere
% % Z axis bias coils:  12.09 gauss/ampere

% figure;errorbar(p.loopVals{1},mean(ydata1'),std(ydata1'));hold on;errorbar(p.loopVals{1},mean(ydata2'),std(ydata2'))
% title('Cooling power at 600mW, bias field in Y direction scanned, 10 runs averaged');
% xlabel('y bias coil current [A]');
% ylabel('cloud center pos in y [m]');
% legend({'100A in AHH coils','220A in AHH coils'})
