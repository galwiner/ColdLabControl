function [seq,delayVec]=TOFseq(channelTable,trigCahnnel,N,maxT,delay,motLoadTime)
%Gal W 080917
%sequence to collect two images from the camera connected to trig channel
%delay is the time between images in microseconds. 
%default delay =100uS, default mot load time 1 s
%N is number of images, maxT is the longest TOF time
%default N=2, default maxT=1500

if nargin=2
    N=2;
    maxT=1500;
    delay=100;
    motLoadTime=1e6; 
end

if nargin=3
    maxT=1500;
    delay=100;
    motLoadTime=1e6; 
end

if nargin=4
    delay=100;
    motLoadTime=1e6; 
end

%make a log spaced trigger time vector including just after Mot loading (no delay)
delayVec=[motLoadTime,logspace(motLoadTime,motLoadTime+maxT,N-1)]; 

for ind=1:N
    seq=[LoadMotSeq(channelTable),...
        trigImage(channelTable,delayVec(ind),'pixelfly')
        trigImage(channelTable,delayVec(ind),'pixelfly'),...
        UnloadMotSeq(channelTable,motLoadTime+maxT)];
  end
end