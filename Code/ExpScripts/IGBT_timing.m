% script to test the ramp up and down times of the the PSU with/without the IGBT 
% 26/10/2017
%assuming that you have intsalled the IVI drivers, it's nice and easy to
%use the matlab quick oscilloscope object
basicImports;
seqUpload(UnloadMotSeq(channelTable)); %make sure field is off

%configure scope to trigger on rising edge at 0.1V (some low level)

scopename='USB0::0x0957::0x1799::MY55462017::0::INSTR';
% scp=oscilloscope();
% set(scp,'Resource',scopename);
% connect(scp);
% % autoSetup(scp);
% scp.TriggerMode='Normal';
% scp.TriggerLevel=0.01;
% scp.TriggerSlope='rising';
% enableChannel(scp, 'Channel1');
% setVerticalCoupling (scp, 'Channel1', 'DC');
% setVerticalRange (scp, 'Channel1', 5.0);
% scp.AcquisitionTime = 0.1;
% scp.SingleSweepMode

sc=keysightScope(scopename);

seqUpload(LoadMotSeq(channelTable)); %loadign sequence with IGBT going to HIGH

waveformArray = readWaveform(scp,'Channel1'); 
params.Icirc=100;
% 
% foldername='D:\Box Sync\Lab\ExpCold\Measurements\2017\10\26'; %TODO make auto saving func
% filename='261017_1.mat';
% save(fullfile(foldername,filename),'t','dat','params');