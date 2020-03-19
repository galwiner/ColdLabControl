global p
initp
load('idsQuantumEffitiencyCalibIm.mat');
QuantumEffitiencyCalibIm = im2;
exposureTime = 1e-6; %in sec
beamPower = 75e-6; %in W
laserFreq = 384.227e12; %in Hz
% bg = 1.3131;
bg = 0;
photonEnergy = p.consts.hbar*2*pi*laserFreq;%in J
BeamEnergy = beamPower*exposureTime;
PhotonNumber = BeamEnergy/photonEnergy;
CountNumber = sum(QuantumEffitiencyCalibIm(:))-bg*length(QuantumEffitiencyCalibIm(:));
QuantumEffitiency = CountNumber/PhotonNumber*100; %in %
photonsPerCount = 100/QuantumEffitiency;