clear all;
global inst
clear global inst
global inst
instrreset;
init
switchDBRs(1);
try
    ChannelToggler('TASwitch',1);
    ta_on=1;
catch
    disp('did not start TA');    
    ta_on=0;
end

if isfield(inst,'sproutLaser')
fprintf('Turning sprout laser on\n')
inst.sproutLaser.setLaserOn;
    sprout_on=1;
else
    warning('No sprout laser found. Not warming up')
    sprout_on=0;
end
pb1=Pushbullet('o.j3zDBT7wvgkxZ0iq5pl35nazFjUqyElI'); %Gal's API key
pb2=Pushbullet('o.iSMxC5nj0HiMBdTFMhc6x6wvQBC1viyW'); %Lee's API key
if isfield(inst,'dplaser')
fprintf('Setting IPG Laser power to 10 W\n')
inst.dplaser.setPower(10);
pause(1)
inst.dplaser.setLaserState(1);
fprintf('Pausing for 30 mins and setting IPG Laser power to 20 W\n')
pause(30*60)
inst.dplaser.setPower(20);
    dp_on=1;
else
    warning('No dplaser found. Not warming up')
    dp_on=0;
end
try
    dt = date;
    if strcmpi('19-feb-2020',dt)
        dispensersState(1);
        ds = 1;
    else
        ds = 0;
    end
catch
    ds = 0;
end
if ds==0
state_after_run=sprintf('IPG: %d, Sprout: %d, TA: %d',dp_on,sprout_on,ta_on);
else
    state_after_run=sprintf('IPG: %d, Sprout: %d, TA: %d, Dispenser: 1',dp_on,sprout_on,ta_on);
end
msg=['Good morning lab! ',state_after_run];
pb1.pushNote([],'Cold Lab notification!',msg);
pb2.pushNote([],'Cold Lab notification!',msg);
% ChannelToggler('PurpleDTSwitch',1)
% ChannelToggler('BlueDTSwitch',1)

exit
