
clear all

% imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=200;
cooling=ICELaser('COM4',3,3,4);
Ndet=12;
Npower=12;
coolingDet=linspace(-8,-2,Ndet)*consts.Gamma;
coolingFreq=coolingDetToFreq(coolingDet,cooling.getMultiplyer);
coolingPower=linspace(100,800,Npower);

% take a bg image with light on but magnetic field off
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(0.2);
bgimg=pixCam.snapshot;

pixCam.setHardwareTrig(Npower*Ndet);
pixCam.start;

cooling.setIntFreq(coolingFreq(jnd));
cooling.sendSerialCommand(['EvtData 1 1 ' num2str(coolingFreq(jnd))]);
cooling.sendSerialCommand('Save');
seqUpload(AOSetVoltageSeq(channelTable,'COOLVVAN',CoolingPower2AO(coolingPower(ind))));
[temp(:,ind,jnd),images(:,:,:,ind,jnd),fitImages(:,:,:,ind,jnd),fitParams{ind,jnd}]=thermometryFunc(channelTable,pixCam,bgimg,[],100);


pixCam.stop;
customsave(mfilename)
