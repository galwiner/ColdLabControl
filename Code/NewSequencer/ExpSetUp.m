%helper script to generate p files
global p
initp
p.expName = 'MOTStability';
p.expDescription = 'Load a MOT, release and take a picture, repeat to see if the MOT moves';
% p.ProbeFlashTime=p.INNERLOOPVAR;
% p.circCurrent=p.OUTERLOOPVAR;
% p.loopVars={'ProbeFlashTime'};
% p.ScanTime = 600;
% p.cameraParams{1}.E2ExposureTime = flashTime;
% p.loopVals={flashTime};
p.hasScopResults = 0;
p.NAverage=1;
p.pfLiveMode=0;
p.tcLiveMode=1;
p.hasPicturesResults=1;
p.postprocessing=0;
p.picsPerStep=1;
p.circCurrent = 40*10/220;
p.NAverage = 10;
% p.MOTReleaseTime = 200;
% p.IGBTDelay = 10;
% For CurrentShotDoun p.s.addBlock({
%     {'Load MOT'};...
%     {'TrigScope'};...
%     {'Release MOT'};...
%     });
%% For ProbeAlignmentViaOD

p.s.addBlock({
    {'Load MOT'};...
    {'Release MOT'};...
    {'TakePic'}
    });
basePath=fullfile(fileparts(which('basicImports')),'..','NewSequencer','experiments','pBank');
expfile=fullfile(basePath, [p.expName '.mat']);
save(expfile,'p')