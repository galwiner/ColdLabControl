clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.spectrumAnaParams{1}.centerFreq = 150;
p.spectrumAnaParams{1}.span = 200;
p.spectrumAnaParams{1}.refAmp = 10;
p.hasSpecResults = 1;
p.benchtopSpecRes = 1;
p.NAverage = 1;
p.DEBUG=DEBUG;
p.pauseBetweenRunSteps = 1;
initinst
initr
p.expName='Cooling VCO calibration';
%%
nsteps = 30;
AOstart = 0.1;
AOEnd = 10;
AOVals = linspace(AOstart,AOEnd,nsteps);
p.loopVals{1} = AOVals;
p.loopVars{1} = 'VCOVoltage';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','coolingSwitch','duration',0,'value','high'});
p.s.addBlock({'setAnalogChannel','channel','COOLVCO','duration',0,'value',p.VCOVoltage});
% p.s.addBlock({'GenPause','duration',1e6});
p.s.run;
%%
freqs = linspace(p.spectrumAnaParams{1}.centerFreq-p.spectrumAnaParams{1}.span/2,p.spectrumAnaParams{1}.centerFreq+p.spectrumAnaParams{1}.span/2,461);
%find peaks
figure;
hold on
for jj = 1:p.NAverage
    for ii = 1:length(p.loopVals{1})
        [~,tmpInds] = findpeaks(r.specRes{1}(:,2,1,ii,jj),'MinPeakProminence',50);
        if ~isempty(tmpInds)
        VCOFreqInds(ii,jj) = tmpInds;
        VCOFreq(ii,jj) = freqs(VCOFreqInds(ii,jj));
        else
        VCOFreqInds(ii,jj) =nan;
        VCOFreq(ii,jj) = nan;   
        end
        
    end
    plot(AOVals,VCOFreq(:,jj))
end
    
