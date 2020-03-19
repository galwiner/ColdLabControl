function success = updateThorcam()
global inst
global p
if p.tcLiveMode
    return
end
tc=inst.cameras('thorcam');
tc.setExposure(p.cameraParams{2}.exposure);
tc.setHWTrig;
% [~,num]=tc.cam.Memory.GetActive;
% num
fprintf('Updated thorcam params\n');
success=1;
end

