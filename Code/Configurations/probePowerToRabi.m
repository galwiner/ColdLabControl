function rabi = probePowerToRabi(power,waist)
%power should be in mW
%waist should be in mm
%based on the calculation in the one note - "Laser power and Rabi
%frequency"

if nargin==1
    waist = 8.5e-3;
end
warning('correcting for power calibration factor, based on calibration test done in 19/06/19.')
power = power*4.58; %correct for calibration error factor (measured on 19/06/19.
rabi = 5.23*2.534*sqrt(power)/waist;
end