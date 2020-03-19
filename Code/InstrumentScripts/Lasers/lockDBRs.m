function lockDBRs(varargin)
if nargin==0
    lock_or_unlock=1;
else 
    lock_or_unlock=varargin{1};
end
global inst

if isfield(inst,'Lasers')
    cooling=inst.Lasers('cooling');
    repump=inst.Lasers('repump');
    if lock_or_unlock
    if strcmpi(cooling.LasingStatus,'On')
        cooling.setLaserServoStat('On');
    else
        error('cooling laser not lasing');
    end
    if strcmpi(repump.LasingStatus,'On')
        repump.setLaserServoStat('On');
    else
        error('repump laser not lasing');
    end
    fprintf('cooling and repump are locked\n');
    else
        cooling.setLaserServoStat('Off');
        repump.setLaserServoStat('Off');
        fprintf('cooling and repump are unlocked\n');
    
    end
else
    init;
    lockDBRs(lock_or_unlock)
end
end
