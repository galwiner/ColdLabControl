% Lee 12.09.17

%This script loads a MOT. After a load time, takes a picture then starts optical mollasses for
%a cirtan duration. Then it takes another picture.
clear all
exposure = 50;
duration = 0.5e3;
psuSetup;
[vid,src]=pixelflySetup(exposure,'01','01');
basicImports 

N=1; %number of images
vid.TriggerRepeat = N-1;
cameraName  = 'pixelfly';
delayFromUnload=5e5; %0.5 second delay from laser turn off
seq=[LoadMotSeq(channelTable),... %Turn on MOT
    ...%trigImage(channelTable,delayFromUnload-10e3,cameraName),...%Triger MOT image 10ms before turn off
    MollassesSeq(channelTable,delayFromUnload+exposure,duration),...%Do optical mollases
    trigImage(channelTable,delayFromUnload+duration,cameraName),...%Triger image just befor the end of the mollasses
    ];
% seq=[LoadMotSeq(channelTable),trigImage(channelTable,delayFromUnload-10e3,cameraName)];
start(vid);
pause(1);
seqUpload(seq);
img=getdata(vid,N);
stop(vid)
figure;
imagesc(img)