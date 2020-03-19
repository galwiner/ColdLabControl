function countRate = probePower2CountRate(probePower)
load('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\probePowerToCountRate.mat');
if any(probePower<min(setPower))||any(probePower>max(setPower))
%     error('probePower must be between %0.1d and %0.1d, you requested %0.1d.',min(setPower),max(setPower),probePower(1))
error('probePower must be between %0.1d and %0.1d',min(setPower),max(setPower))
end
countRate=interp1(setPower,countRateVec,probePower);
end
