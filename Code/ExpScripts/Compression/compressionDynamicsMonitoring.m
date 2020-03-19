%test analog ramp

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=1;
p.hasPicturesResults=1;
p.picsPerStep=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.cameraParams{1}.E2ExposureTime=20;
p.DEBUG=DEBUG;
initinst
initr
% inst.DDS.setFreq(2,p.probeLockCenter/32,0,0);
% p.circCurrent=40;
%%setting up the sweep
p.expName='Compression end current sweep';
p.loopVars = {'pictureTime'};
numSteps=10;
% compressionEndCurrentVals=ceil(linspace(40,220,numSteps));
pictureTime=linspace(1e3,500e3,numSteps); %in us
p.loopVals={pictureTime};
% 
p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.(p.loopVars{2})=p.OUTERLOOPVAR;

%% test compression
% p.MOTLoadTime=1e6;

p.compressionTime = 20e3; %in us
p.compressionEndCurrent=220;
p.cameraParams{1}.E2ExposureTime=20;
p.s=sqncr();
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','value','high','duration',0,'description','probe on'});
% p.s.addBlock({'setICEDetuning','Laser Name','cooling','detuning',p.compressionDetuning,'evtNum',3});
p.s.addBlock({'Load MOT'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'pause','duration',p.pictureTime});
p.s.addBlock({'TakePic'});
p.s.addBlock({'pause','duration',p.compressionTime});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'GenPause','channel','none','value','none','duration',1e6});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'}); %two triggers to put the ice int freq to -70MHz detuning
% p.s.addBlock({'pause','duration',300});
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'});
% p.s.addBlock({'pause','duration',300});
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','high','duration',0,'description','cooling beams on'});
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
% p.s.addBlock({'pause','duration',p.compressionTime});
% p.s.addBlock({'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'});
% p.s.addBlock({'pause','duration',300});


% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
% p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','value','low','duration',0,'description','cooling beams off'});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','value',100*10/220,'duration',0});
% p.s.addBlock({'pause','duration',100e3});
% p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
% p.s.addBlock({'pause','duration',1e3});
% p.s.addBlock({'pause','duration',1e6});
% p.s.addBlock({'setAnalogChannel','channel','CircCoil','value',40*10/220,'duration',0});


p.looping = int16(1);
p.s.run();
% figure;imagesc(r.images{1})

% 
% figure;
% colnum=5;
% rownum=5;
% images=r.fitImages{1};
% maxVals=[];
% for ind=1:numSteps
%     
%     
%     subplot(rownum,colnum,ind2sub([rownum colnum],ind));
% %     imagesc(images(:,:,1,1,ind));
%     imagesc(images(:,:,1,ind));
%     colorbar
% %     maxVals(end+1)=max(max(images(:,:,1,1,ind)));
% %     title(max(max(images(:,:,1,1,ind))));
%         maxVals(end+1)=max(max(images(:,:,1,ind)));
%     title(max(max(images(:,:,1,ind))));
% end
% 
% imageViewer(squeeze(r.images{1}))
%%
AtomNum=squeeze(r.fitParams{1}(7,1,:,:)); %integrated intensity in the gaussian
AtomNum= AtomNum*atomNumberFromCollectionParams();
peakDensity=AtomNum./squeeze(r.fitParams{1}(6,1,:,:))./squeeze(r.fitParams{1}(5,1,:,:).^2)/((2*pi)^(3/2)); %in 1/m^3
peakDensity = peakDensity*1e-6;

figure;
subplot(3,1,1)
plot(pictureTime,peakDensity,'o-');
title('density')
xlabel('pictureTime [\mus]')
ylabel('density [cc^-1]')


subplot(3,1,2)
plot(pictureTime,squeeze(r.fitParams{1}(6,1,:,:)),'or-')
hold on
plot(pictureTime,squeeze(r.fitParams{1}(5,1,:,:)),'ob-')
title('gaussian width')
xlabel('pictureTime [\mus]')
legend('\sigma_x','\sigma_z')
subplot(3,1,3)
plot(pictureTime,AtomNum,'or-')
title('atom number')
xlabel('pictureTime [\mus]')
% figure;
% subplot(3,1,1)
% plot(compressionDetuningVals,peakDensity,'o-');
% title('density')
% xlabel('compression detuning')
% ylabel('density [cc^-1]')
% 
% 
% subplot(3,1,2)
% plot(compressionEndCurrentVals,squeeze(r.fitParams{1}(6,1,:,:)),'or-')
% hold on
% plot(compressionEndCurrentVals,squeeze(r.fitParams{1}(5,1,:,:)),'ob-')
% title('gaussian width')
% legend('\sigma_x','\sigma_z')
% subplot(3,1,3)
% plot(compressionEndCurrentVals,AtomNum,'or-')
% title('atom number')
% 
% 
% figure;
% subplot(3,1,1)
% plot(compressionTimeVals,peakDensity,'o-');
% title('density')
% xlabel('compression time [mS]')
% ylabel('density [cc^-1]')
% 
% 
% subplot(3,1,2)
% plot(compressionTimeVals,squeeze(r.fitParams{1}(6,1,:,:)),'or-')
% hold on
% plot(compressionTimeVals,squeeze(r.fitParams{1}(5,1,:,:)),'ob-')
% title('gaussian width')
% legend('\sigma_x','\sigma_z')
% subplot(3,1,3)
% plot(compressionTimeVals,AtomNum,'or-')
% title('atom number')
