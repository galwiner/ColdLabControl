 function AO = PurpleDTPower2AO(power)
%L.D 07/10/2019
%power in W
global p
load('PurpleDTPowerVsAO.mat');
if strcmpi(power,'max')
    power = max(pwr)*0.99;
end
if strcmpi(power,'half')
    power = max(pwr)/2;
end
if (any(power>max(pwr))||any(power<min(pwr)))
    error('power must be between %0.2f and %0.2f W, you asked for %0.3f W!',min(pwr),max(pwr),power)
end
AO=interp1(pwr,V,power);
if isnan(AO)
    error('Bad purple DT power requirement');
end
end

