
clear all

% imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=200;
cooling=ICELaser('COM4',3,3,4);
Ndet=12;
Npower=12;
coolingDet=linspace(-10,-2,Ndet)*consts.Gamma;
coolingFreq=coolingDetToFreq(coolingDet,cooling.getMultiplyer);
coolingPower=linspace(100,880,Npower);
% take a bg image with light on but magnetic field off
bgimg = TakeBgImg(channelTable,pixCam);

pixCam.setHardwareTrig(Npower*Ndet);
pixCam.start;
for ind=1:Npower
    for jnd=1:Ndet
    fprintf('Setting detuning to %.2f MHz and power to %.2f mW',coolingFreq(jnd),coolingPower(ind));
    cooling.setIntFreq(coolingFreq(jnd));
    cooling.sendSerialCommand(['EvtData 1 1 ' num2str(coolingFreq(jnd))]);
    cooling.sendSerialCommand('Save');
    seqUpload(AOSetVoltageSeq(channelTable,'COOLVVAN',CoolingPower2AO(coolingPower(ind))));
    [temp(:,ind,jnd),images(:,:,:,ind,jnd),fitImages(:,:,:,ind,jnd),fitParams{ind,jnd}]=thermometryFunc(channelTable,pixCam,bgimg,[],70,coolingPower(ind));
    end
end
pixCam.stop;
customsave(mfilename)
