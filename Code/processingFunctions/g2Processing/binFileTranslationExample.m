tic
binFileName='D:\Box Sync\Lab\ExpCold\Measurements\2019\05\01\tt\tt_010519_01__no exp name.bin';
datMat=binFileToMat(binFileName);
toc
save('this.mat','datMat')
clear datMat
tic
load('this.mat')
toc
