function [vid,src]=pixelflySetup(exposure,Hbinning,Vbinning)
%Gal W
%this function sets up the pixelfly camera to exposure time in uS
%with Hbinning, Vbinning.
%defaults: exposure=10uS, binning 01X01. binning can be '01','02','04'
%(strings) in each direction

if nargin==0
    exposure=10;
    Hbinning='01';
    Vbinning='01';
end


if nargin==1
    Hbinning='01';
    Vbinning='01';
end

vid = videoinput('pcocameraadaptor', 0, 'USB 2.0');
src = getselectedsource(vid);
vid.FramesPerTrigger = inf;
src.E1ExposureTime_unit = 'us';
src.E2ExposureTime = exposure;
triggerconfig(vid, 'hardware', '', 'ExternExposureStart');
src.PCPixelclock_Hz = '24000000';
src.TMTimestampMode = 'No Stamp';
src.B1BinningHorizontal = Hbinning;
src.B2BinningVertical = Vbinning;

if ~isrunning(camHandles.PixFly1)
    start(camHandles.PixFly1);
end
flushdata(camHandles.PixFly1);


end
