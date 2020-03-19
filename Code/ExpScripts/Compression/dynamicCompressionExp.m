%measure dynamic compression benefit

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
p.coolingDet=-3*p.consts.Gamma;
p.cameraParams{1}.E2ExposureTime=10;
p.DEBUG=DEBUG;
initinst
initr
%% test ramp

p.loopVars = {'compressionTime'};
p.loopVals={linspace(1e3,40e3,20)};
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.compressionEndCurrent=220;
p.s=sqncr();
p.s.addBlock({'Load MOT'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({'TrigScope'});
p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',p.compressionEndCurrent});
p.s.addBlock({'pause','duration',p.compressionTime});
p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger photo'});
p.s.addBlock({'pause','duration',1e6});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','value','High','duration',0});

p.looping = int16(1);
p.s.run();
figure;
dat=squeeze(r.images{1});
for ind=1:size(dat,3)

subplot(size(dat,3),1,ind)
imagesc(dat(:,:,ind))
hold on
end
fdat=squeeze(r.fitImages{1});

figure;
totIntensity=squeeze(r.fitParams{1}(2,1,1,:,1));
plot(p.loopVals{1},totIntensity,'o-')

figure;
for ind=1:size(dat,3)

subplot(size(fdat,3),1,ind)
imagesc(fdat(:,:,ind))
hold on
end





