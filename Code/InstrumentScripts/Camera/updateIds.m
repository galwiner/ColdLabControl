function success = updateIds()
global inst
global p
if p.idsLiveMode
    return
end
ids=inst.cameras('ids');
ids.setExposure(p.cameraParams{2}.E2ExposureTime);
ids.setHWTrig;
ids.startRingBufferMode(p.picsPerStep);
fprintf('pausing for 1s for camera setup')
pause(1);
% [~,num]=tc.cam.Memory.GetActive;
% num
fprintf('Updated ids params\n');
success=1;
end

