
clear all

% imaqreset
basicImports;
pixCam=pixelfly();
pixCam.src.E2ExposureTime=20;
cooling=ICELaser('COM4',3,3,4);
NCour=12;
Npower=12;
courrentVals = linspace(25,140,NCour);
coolingPower=linspace(100,880,Npower);
coolingDet = -5; %Gamma
% take a bg image with light on but magnetic field off
bgimg = TakeBgImg(channelTable,pixCam);

pixCam.setHardwareTrig(Npower*NCour);
pixCam.start;
for ind=1:Npower
    seqUpload(AOSetVoltageSeq(channelTable,'COOLVVAN',CoolingPower2AO(coolingPower(ind))));
    for jnd=1:NCour
    fprintf('Setting courrent to %.2f A and power to %.2f mW\n',courrentVals(jnd),coolingPower(ind));
    [temp(:,ind,jnd),images(:,:,:,ind,jnd),fitImages(:,:,:,ind,jnd),fitParams{ind,jnd}]=...
        thermometryFunc(channelTable,pixCam,bgimg,[],courrentVals(jnd),coolingPower(ind));
    end
end
pixCam.stop;
customsave(mfilename)
