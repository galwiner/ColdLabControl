%This script calculats the quantum effitienct of the pixelfly form a saved
%image, taken with 100us exposure time, with a beam power of 29uW.
global p
initp
load('QuantumEffitiencyCalibIm.mat');
exposureTime = 100e-6; %in sec
beamPower = 29e-6; %in W
laserFreq = 384.227e12; %in Hz
photonEnergy = p.consts.hbar*2*pi*laserFreq;%in J
BeamEnergy = beamPower*exposureTime;
PhotonNumber = BeamEnergy/photonEnergy;
CountNumber = sum(QuantumEffitiencyCalibIm(:))-200*length(QuantumEffitiencyCalibIm(:));
QuantumEffitiency = CountNumber/PhotonNumber*100; %in %
photonsPerCount = 100/QuantumEffitiency;