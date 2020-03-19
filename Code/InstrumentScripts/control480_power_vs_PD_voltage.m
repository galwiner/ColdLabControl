% control_power = [70,56,38,22,13,1.3,0];
% control_V = [9.3,7.2,5,2.7,1.6,0.08,-0.091];
% ND = '2_01';
% gain = 40;

control_power = [1.6,1.1,0.7,0.39,0.08,0.065,0.041,0.0095,0];
control_V = [9.2,7,4.5,2.4,0.437,0.338,0.179,-0.026,-0.088];
ND = '0';
gain = 30;
save(['control_power_2_PD_V_ND_' ND '_gain_' num2str(gain)],'control_power','control_V','ND','gain');
