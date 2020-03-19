function SHOVACH_SCAN(obj,span,time,center,channel,multiplyer)
%this function sets the DDS (shovach) to DRG mode (ramp), with identical ramp up and down.
% [span]=[MHz];[time]=[us];[center]=[MHz]. channel 1-4.
if time/span<2
    warning('If time/span < 2 you risk broadeniong the line');
end
N = 1000; %Number of steps
UP_FREQUENCY = (center + span/2)/multiplyer;
DOWN_FREQUENCY = (center - span/2)/multiplyer;
dfP = span*1e6/N/multiplyer; %in Hz
dtP=time*1e-6/N;%in sec
if dtP>260
    warning('Performing more then 1000 steps')
    N = time/260;
    dtP=time*1e-6/N;%in sec
    dfP = span*1e6/N/multiplyer; %in Hz
end
dtN=dtP;
dfN=dfP;
switch channel
    case 1
        SHU1_initial_2016(1,0,1);
        pause(1);
        DRG_LAB_1(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
    case 2
        SHU2_initial_2016(1,0,1);
        pause(1);
        DRG_LAB_2(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
    case 3
        SHU3_initial_2016(1,0,1);
        pause(1);
        DRG_LAB_3(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
    case 4
        SHU4_initial_2016(1,0,1);
        pause(1);
        DRG_LAB_4(obj,UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN);
    otherwise
        error('channel must be and intiger between 1 and 4')
end


end
