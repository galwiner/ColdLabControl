clear all
basicImports;
pixCam=pixelfly();
pixCam.src.E1ExposureTime_unit='us';
pixCam.src.E2ExposureTime=200;
pixCam.src.B1BinningHorizontal='04';
pixCam.src.B2BinningVertical='04';

figure
xlable
while 1
imagesc(pixCam.snapshot)
pause(1);
end
