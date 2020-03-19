%This script clears the inst global variable. This is needed because
%communication with devices must be teminated properly
clear -global inst
global p
global inst
global r
if ~isfield(inst,'ind')
    return
end

if p.pfPlaneLiveMode
    if p.pfTopLiveMode
    else
        inst.cameras('pixelflyTop').delete;
    end
else
    if p.pfTopLiveMode
        inst.cameras('pixelflyPlane').delete;
    else
        inst.cameras('pixelflyPlane').delete;
        inst.cameras('pixelflyTop').delete;
    end
end
if isfield(inst,'DDS')
inst.DDS.delete;
end
if isfield(inst,'MWSource')
    inst.MWSource.delete;
end
inst.BiasCoils{2}.setVoltageLimit(2,p.HHXVoltageLimit);

inst.Lasers('cooling').delete;
inst.Lasers('repump').delete;
%scopes
if isfield(inst,'scopes')   
    inst.scopes{1}.delete;
end
%setup spectrum analyser
if isfield(inst,spectrumAna)
    try
        inst.spectrumAna{2}.delete;
    catch
    end
    try
        inst.spectrumAna{1}.delete;
    catch
    end
end
inst = [];