function AO = ImagingVCOFreq2AO(NeededVCOFreq,varargin)
%L.D 14.10.18. This function loads the calibration data of AOVoltage to
%imaging VCO frequency and extrapulates it, in order to give the wanted
%imaging VCO frequency.
%
load('AOVoltage2ImagingVCOFreq.mat');
if any(NeededVCOFreq>max(VCOFreq))||any(NeededVCOFreq<min(VCOFreq))
    error('VCO frequency must be between %0.2f and %0.2f!',min(VCOFreq),max(VCOFreq))
end

AO=interp1(VCOFreq,AOVals,NeededVCOFreq);
if isnan(AO)
    error('VCO frequency must be between %0.2d and %0.2d!',min(VCOFreq),max(VCOFreq));
end
end

