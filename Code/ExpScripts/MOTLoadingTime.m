% This script loads the MOT and triggers the photodetector analog readout
%24/10/2017 LD + GW
clear all
Icirc=100;

% close all
clc
basicImports
seqUpload(UnloadMotSeq(channelTable)); %make sure the MOT is not loaded
prog=CodeGenerator(); 
prog.GenLodingMeasTrig; %trigger the analor readout loop. at this time (24/10/17) the readouts are 5ms apart. total 5 second readout
seq=LoadMotSeq(channelTable,0,Icirc); %load the mot
prog.GenSeq(seq);
prog.GenFinish;
prog.DisplayCode();
com=Tcp2Labview('localhost',6340);
com.UploadCode(prog);
com.UpdateFpga;
com.WaitForHostIdle;
com.Execute(1);
com.WaitForHostIdle;
pause(10) %wait for read-it to complete
dat=com.readMemoryBlock(1000,999); % read the memory. 
dat=dat*10/2^15; %scale to V units
t=linspace(0,5,999); %in Seconds
com.Delete;

params=struct();
params.Idis=5; %dispenser current A
params.IcircCoil=Icirc; %circular coils

figure;
plot(t,dat);

foldername='D:\Box Sync\Lab\ExpCold\Measurements\2017\10\26'; %TODO make auto saving func

filename='261017_09.mat';


save(fullfile(foldername,filename),'t','dat','params');