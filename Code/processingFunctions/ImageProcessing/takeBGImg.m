function bgImg=takeBGImg(channelTable,cameraName,cameraObj)
seqUpload(LoadMotSeq(channelTable));
setAHHCurrent(channelTable,'circ',0);
pause(2);
switch cameraName
    case 'pixelfly'
    bgImg=cameraObj.snapshot;
    otherwise
        error('no such camera');
end
        
end