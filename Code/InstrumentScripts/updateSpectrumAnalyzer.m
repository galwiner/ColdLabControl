global p
global inst
if ~p.hasSpecResults
    return
end
if p.handheldSpecRes
   hh = inst.spectrumAna{2};
   hhparams = p.spectrumAnaParams{2};
   hh.setCenterFreq(hhparams.centerFreq);
   hh.setSpan(hhparams.span);
   hh.setAvrageCount(hhparams.NAverages);
   hh.setAmplitude(hhparams.refAmp);
   hh.setResolutionBW(hhparams.BW);
end
if p.benchtopSpecRes
   bt = inst.spectrumAna{1};
   btparams = p.spectrumAnaParams{1};
   bt.setCenterFreq(btparams.centerFreq);
   bt.setSpan(btparams.span);
   bt.setAvrageCount(btparams.NAverages);
   bt.setAmplitude(btparams.refAmp);
   bt.setResolutionBW(btparams.BW);
end