a = inputdlg('attempting to run goodNight. are you sure?');
if ~strcmpi(a{1},'yes')
    warning('goodNight did not run!!')
    return
end
    
initp
initinst
ta_on=1;
% try 
% ChannelToggler('TASwitch',0)
% ta_on=0;
% catch
%     ta_on=1;
% end
try 
ChannelToggler(p.chanNames.UVLED,0)
    uv_on=0;
catch
    uv_on=1;
end
dbr_on=1;
% try
%     switchDBRs(0)
% dbr_on=0;
% catch
%     dbr_on=1;
% end
try
dispensersState(0)
dispenser_on=0;
catch
    dispenser_on=1;
end

brm;
global inst
if isfield(inst,'dplaser')
    inst.dplaser.setLaserState(0)
    dp_on=0;
else
    disp('did not shut IPG!');
    dp_on=1;
end

if isfield(inst,'sproutLaser')
inst.sproutLaser.setLaserOff
sprout_on=0;
else
    disp('did not shut SPROUT!');
    sprout_on=1;
end

pb1=Pushbullet('o.j3zDBT7wvgkxZ0iq5pl35nazFjUqyElI'); %Gal's API key
pb2=Pushbullet('o.iSMxC5nj0HiMBdTFMhc6x6wvQBC1viyW'); %Lee's API key

state_after_run=sprintf('IPG: %d, Sprout: %d, TA: %d, dispensers: %d, DBR:%d, UV: %0.0f',dp_on,sprout_on,ta_on,dispenser_on,dbr_on,uv_on);
msg=['Good night lab! ',state_after_run];
pb1.pushNote([],'Cold Lab notification!',msg);
pb2.pushNote([],'Cold Lab notification!',msg);
clear all
instrreset
