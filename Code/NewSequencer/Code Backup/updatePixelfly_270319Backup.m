function success = updatePixelfly()
global inst
global p
if p.pfLiveMode && p.pfTopLiveMode
    return
end
if ~p.pfPlaneLiveMode
stop(inst.cameras('pixelflyPlane'));
pf=inst.cameras('pixelflyPlane');
pf.setHardwareTrig(p.cameraParams{1}.TriggerRepeat);
pf.handle.Timeout=p.cameraParams{1}.timeout;
pf.src.B1BinningHorizontal=p.cameraParams{1}.B1BinningHorizontal;
pf.src.B2BinningVertical=p.cameraParams{1}.B2BinningVertical;
pf.src.E1ExposureTime_unit=p.cameraParams{1}.E1ExposureTime_unit;
pf.src.E2ExposureTime=p.cameraParams{1}.E2ExposureTime;
pf.handle.TriggerRepeat=p.cameraParams{1}.TriggerRepeat;
pf.setROI(p.cameraParams{1}.ROI);
start(inst.cameras('pixelflyPlane'));
fprintf('Updated pixelfly params\n');
success=1;
end
if ~p.pfTopLiveMode
stop(inst.cameras('pixelflyTop'));
pf=inst.cameras('pixelflyTop');
pf.setHardwareTrig(p.cameraParams{2}.TriggerRepeat);
pf.handle.Timeout=p.cameraParams{2}.timeout;
pf.src.B1BinningHorizontal=p.cameraParams{2}.B1BinningHorizontal;
pf.src.B2BinningVertical=p.cameraParams{2}.B2BinningVertical;
pf.src.E1ExposureTime_unit=p.cameraParams{2}.E1ExposureTime_unit;
pf.src.E2ExposureTime=p.cameraParams{2}.E2ExposureTime;
pf.handle.TriggerRepeat=p.cameraParams{2}.TriggerRepeat;
pf.setROI(p.cameraParams{2}.ROI);
start(inst.cameras('pixelflyTop'));
fprintf('Updated pixelfly params\n');
success=1; 
end
end

