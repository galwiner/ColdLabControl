function cameraSetup(p)
% setup all cameras, generating the camera handels globabl if needed.
global camHandels

if ~isfield(camHandles, 'PixFly1') || ~isobject(camHandles.PixFly1)
	camHandles.PixFly1 = videoinput('pcocameraadaptor', 0, 'USB 2.0');
end

PixFly1Src = getselectedsource(camHandles.PixFly1);
camHandles.PixFly1.FramesPerTrigger = inf;

			if camHandles.PixFly1.FramesPerTrigger ~= inf || ...
					~strcmpi(PixFly1Src.E1ExposureTime_unit, 'us') || ...
					PixFly1Src.E2ExposureTime ~=  p.cam_params(1).shutter_time * 1e6 || ...
					~strcmpi(PixFly1Src.B1BinningHorizontal, num2str(p.cam_params(1).Hbinning)) || ...
					~strcmpi(PixFly1Src.B2BinningVertical, num2str(p.cam_params(1).Vbinning)) || ...
					~strcmpi(trigconf.TriggerType,'Hardware') || ...
					~strcmpi(trigconf.TriggerSource,'ExternExposureStart') || ...
					~strcmpi(trigconf.TriggerCondition,'')
				if isrunning(camHandles.PixFly1)
					stop(camHandles.PixFly1);
				end
				camHandles.PixFly1.FramesPerTrigger = inf;
				PixFly1Src.E1ExposureTime_unit = 'us';
				PixFly1Src.E2ExposureTime = p.cam_params(1).shutter_time * 1e6;		
				PixFly1Src.B1BinningHorizontal = num2str(p.cam_params(1).Hbinning);
				PixFly1Src.B2BinningVertical = num2str(p.cam_params(1).Vbinning);
				triggerconfig(camHandles.PixFly1, 'hardware', '', 'ExternExposureStart');
			end
			if ~isrunning(camHandles.PixFly1)
				start(camHandles.PixFly1);
			end	
			flushdata(camHandles.PixFly1);

end