% 
clear all
close all
clc
basicImports
seqUpload(UnloadMotSeq(channelTable));
prog=CodeGenerator();
prog.GenLodingMeasTrig;
seq=LoadMotSeq(channelTable,0,100);
prog.GenSeq(seq);
prog.GenFinish;
prog.DisplayCode();
com=Tcp2Labview('localhost',6340);
com.UploadCode(prog);
com.UpdateFpga;
com.WaitForHostIdle;
com.Execute(1);
com.WaitForHostIdle;
pause(10)
dat=com.readMemoryBlock(1000,999);

dat=dat*10/2^15;

com.Delete;


figure;
plot(dat)

foldername=
filename=

save(dat,