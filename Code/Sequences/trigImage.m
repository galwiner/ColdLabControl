function seq=trigImage(channelTable,trigTime,cameraName)
%Gal W
%this function generates the sequence needed to take an image by cameraName
%at trigTime.
%default is cameraName='pixelfly' and trigTime=0;

if nargin==1
    trigTime=0;
    cameraName='pixelfly';
end

if nargin==2
    cameraName='pixelfly';
end

seq={Pulse(channelTable.PhysicalName{'pixelfly'},trigTime,20)};
