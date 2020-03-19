function labShutdown
global inst
global p

fprintf('shutting down lab');
dispensersState(0);

% inst.Lasers('cooling').setLaserServoStat('off');
% fprintf('cooling lock off');
% inst.Lasers('repump').setLaserServoStat('off');
% fprintf('repump lock off');

% pause(1);


end
