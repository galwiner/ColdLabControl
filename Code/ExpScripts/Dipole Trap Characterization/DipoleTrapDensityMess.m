clear all
imaqreset
global p

global r
global inst
DEBUG=0;
initp
p.expName='DipoleTrapDensityMess';
% p.DTPos{1} = [770,593];
% p.DTPos{2} = [387,542];
p.hasScopResults=0;
p.hasPicturesResults=1;
p.picsPerStep=2;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.postprocessing=1;
p.calcTemp = 0;
p.cameraParams{1}.B1BinningHorizontal = '01';
p.cameraParams{1}.B2BinningVertical = '01';
p.cameraParams{1}.ROI = p.cameraParams{1}.ROI;
p.cameraParams{1}.E2ExposureTime=1e3;
p.cameraParams{2}.E2ExposureTime=1e3;
p.DEBUG=DEBUG;
initinst
initr

%%
p.flashTime = 50;
p.DTParams.TrapTime = 6e4;
p.s = sqncr;
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',4e3})
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'TakePic'})
p.s.addBlock({'pause','duration',2e5})
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','high','duration',0});
p.s.addBlock({'pause','duration',2e4})
p.s.addBlock({'LoadDipoleTrap'});
p.s.addBlock({'setCoolingDetuning','duration',0,'value',0});
p.s.addBlock({'setCoolingPower','duration',0,'value',690});
p.s.addBlock({'setDigitalChannel','channel','coolingZShutter','value','low','duration',0});
p.s.addBlock({'pause','duration',4e3})
p.s.addBlock({'setDigitalChannel','channel','BlueDTSwitch','value','low','duration',0});
p.s.addBlock({'setDigitalChannel','channel','PurpleDTSwitch','value','low','duration',0});
p.s.addBlock({'pause','duration',2.5e3})
p.s.addBlock({'TakePic'})

p.s.run

imageViewer(r.images{1}(:,:,:))
imageViewer(r.fitImages{1}(:,:,:))
%%
trapVolume = (2*pi)*(3/2)*r.fitParams{1}(5,1)^2*r.fitParams{1}(6,1);
atomNum = r.atomNum{1}(2);
atomDensity = atomNum/trapVolume*1e-6;
esstPrbOD = getODFromAtomNum(atomNum,r.fitParams{1}(5,1),r.fitParams{1}(5,1),1)