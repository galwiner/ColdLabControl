function img=takeBackgroundImage(channelTable,exposure,cameraName,binning)
%Gal W
%function to take a single background image. makes sure mot is not loaded
%and returns an image. default camera is pixelfly, default exposure time is 100uS 

if nargin==1
    cameraName='pixelfly';
    exposure=100;
    binning='04';
end

if nargin ==2
    cameraName='pixelfly';
    binning='04';
end

if nargin ==2
       binning='04';
end

psuSetup;
[vid,src]=pixelflySetup(exposure,binning,binning);
basicImports 

N=1; %number of images
vid.TriggerRepeat = 0;

delayFromUnload=5e5; %0.5 second delay from laser turn off
seq=[UnloadMotSeq(channelTable),...
    trigImage(channelTable,delayFromUnload,cameraName)];

start(vid);
seqUpload(seq);
img=getdata(vid,N);
stop(vid)


