%cooling power pd calibration

clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
% p.circCurrent = 150*10/220;
p.hasScopResults=0;
p.hasPicturesResults=0;
p.picsPerStep=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;

p.DEBUG=DEBUG;
initinst
initr
p.expName='Cooling power PD calibration';
% p.loopVars = {'coolingPower'};



% p.loopVals={coolingPowerVals};
% 
% p.(p.loopVars{1})=p.INNERLOOPVAR;
% p.(p.loopVars{2})=p.OUTERLOOPVAR;

%% test compression
numSteps=15;
powerReadings=[];
analogChanReadings=[];
powerVals=linspace(100,940,numSteps);
for ind=1:numSteps
p.s=sqncr();
p.s.addBlock({'setAnalogChannel','channel','COOLVVAN','duration',0,'value',CoolingPower2AO(powerVals(ind))});
p.s.run();
pause(1);
% powerReadings(end+1)=mean(MeasPowerMeter);
analogChanReadings(:,end+1)=inst.com.readMemoryBlock(1101,3);
end

% save('redCalibrationCurve.mat','powerReadings','powerVals');


