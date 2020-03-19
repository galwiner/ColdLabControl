function success = updatePixelfly()
global inst
global p
if p.pfLiveMode
    return
else
stop(inst.cameras('pixelfly'));
pf=inst.cameras('pixelfly');
pf.setHardwareTrig(p.cameraParams{1}.TriggerRepeat);
pf.handle.Timeout=p.cameraParams{1}.timeout;
pf.src.B1BinningHorizontal=p.cameraParams{1}.B1BinningHorizontal;
pf.src.B2BinningVertical=p.cameraParams{1}.B2BinningVertical;
pf.src.E1ExposureTime_unit=p.cameraParams{1}.E1ExposureTime_unit;
pf.src.E2ExposureTime=p.cameraParams{1}.E2ExposureTime;
pf.handle.TriggerRepeat=p.cameraParams{1}.TriggerRepeat;
pf.setROI(p.cameraParams{1}.ROI);
start(inst.cameras('pixelfly'));
fprintf('Updated pixelfly params\n');
success=1;
end
end

