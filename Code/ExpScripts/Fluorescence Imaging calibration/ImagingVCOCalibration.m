clear all
global p
global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
centFreq = 110;
span = 100;
p.spectrumAnaParams{1}.centerFreq = centFreq;
p.spectrumAnaParams{1}.span = span;
p.spectrumAnaParams{1}.refAmp = 10;
p.hasSpecResults = 1;
p.benchtopSpecRes = 1;
p.NAverage = 1;
p.DEBUG=DEBUG;
p.pauseBetweenRunSteps = 1;
initinst
initr
p.expName='Imaging VCO calibration';
%%
nsteps = 20;
AOstart = 2;
AOEnd = 10;
AOVals = linspace(AOstart,AOEnd,nsteps);
p.loopVals{1} = AOVals;
p.loopVars{1} = 'VCOVoltage';
p.(p.loopVars{1}) = p.INNERLOOPVAR;
p.s = sqncr;
% p.s.addBlock({'setDigitalChannel','channel','ZEEMANSwitch','duration',0,'value','high'});
p.s.addBlock({'setAnalogChannel','channel','ImagingVCO','duration',0,'value',p.VCOVoltage});
% p.s.addBlock({'GenPause','duration',1e6});
p.s.run;
%%
freqs = linspace(centFreq-span/2,centFreq+span/2,461);
%find peaks
figure;
hold on
for jj = 1:p.NAverage
    for ii = 1:length(p.loopVals{1})
        [~,tmpInds] = findpeaks(r.specRes{1}(:,2,1,ii,jj),'MinPeakProminence',40);
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
    
