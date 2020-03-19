function power = controlV2Power(V,gain,nd)
%L.D & T.Z 19/03/20
%this function uses the calibration of control power (before the cell) to
%power detector voltage (measured with 1MOhm termination) after the cell.
if ~strcmp(nd,'0')&&~strcmp(nd,'2_01')
    error('nd could be ''0'' or ''2_01''!')
end
if gain~=30&&gain~=40
    error('gain could be 30 or 40!')
end
base_str = 'control_power_2_PD_V_ND_';
filename = [base_str nd '_gain_' num2str(gain)];
load(filename)
power=interp1(control_V,control_power,V);
end
