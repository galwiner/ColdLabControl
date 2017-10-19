clear all
close all
clc

prog=CodeGenerator();
prog.GenPause(1e6);
prog.GenLodingMeasTrig;
prog.GenFinish();
prog.DisplayCode();

com=Tcp2Labview('localhost',6340);
com.UploadCode(prog);
com.UpdateFpga;
com.WaitForHostIdle;
com.Execute(1);
dat=com.readMemoryBlock(1500,100);
com.Delete;

figure;
plot(dat)
