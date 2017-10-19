function [vid,src]=pixelflySetup(exposure,Hbinning,Vbinning)
imaqreset
if nargin<1
    exposure=1;
    Hbinning='01';
    Vbinning='01';
end

if nargin==1
    Hbinning='01';
    Vbinning='01';   
end

vid = videoinput('pcocameraadaptor', 0, 'USB 2.0');
src = getselectedsource(vid);
src.E1ExposureTime_unit = 'us';
src.E2ExposureTime = exposure;
src.PCPixelclock_Hz = '24000000';
src.TMTimestampMode = 'No Stamp';
src.B1BinningHorizontal = Hbinning;
src.B2BinningVertical = Vbinning;
end
