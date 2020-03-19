global inst
init
switchDBRs(1);
dispensersState(1);
ChannelToggler('TASwitch',1)
if isfield(inst,'dplaser')
fprintf('Setting IPG Laser power to 10 W\n')
inst.dplaser.setPower(10);
pause(1)
inst.dplaser.setLaserState(1);
else
    warning('No dplaser found. Not warming up')
end

if isfield(inst,'sproutLaser')
fprintf('Turning sprout laser on\n')
inst.sproutLaser.setLaserOn;
else
    warning('No sprout laser found. Not warming up')
end

% ChannelToggler('PurpleDTSwitch',1)
% ChannelToggler('BlueDTSwitch',1)
