function switchDBRs(varargin)
if nargin==0
    on_or_off=1;
else
    on_or_off=varargin{1};
end
global inst

if isfield(inst,'Lasers')
    cooling=inst.Lasers('cooling');
    repump=inst.Lasers('repump');
    if on_or_off
        cooling.setLaserStat('On');
        repump.setLaserStat('On');
        fprintf('cooling and repump are on\n');
    else
        cooling.setLaserServoStat('Off');
        repump.setLaserServoStat('Off');
        cooling.setLaserStat('Off');
        repump.setLaserStat('Off');
        fprintf('cooling and repump are off\n');
        brm
        fprintf('basicReleaseMOT ran\n');
    end
else
    fprintf('first run initinst\n');
end
end
