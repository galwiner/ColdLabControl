function intens = coolingPower2Intensity(coolingPower)
%L.D 14/01/19.
%this function returns the Intensity of the cooling power on the atoms.
%The funtion assumes a 80% coupling into the SM fibers and a maximal power
%of 690 mW after the DP-AOM. Also, it assumes that the beam size is 1'' in
%diameter
%I = 2*P/(pi*w0^2);
w0 = 2.54/2;
P = coolingPower*0.8; %power into all three fibers
P = P*2; %account for retro
intens = 2*P/(pi*w0^2);
end