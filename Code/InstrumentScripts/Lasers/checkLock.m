if exist('cooling') && exist('repump')
    assert(strcmpi(cooling.getLaserServoStat,'On'))
    assert(strcmpi(repump.getLaserServoStat,'On'))
    fprintf('cooling and repump are locked\n');
else 
    fprintf('first run initinst\n');
end