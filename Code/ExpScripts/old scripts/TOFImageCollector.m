function [images,x,y]=TOFImageCollector(channelTable,delays,pixCam,circCoilCurrent)
%this function takes a camera instance and a list of delays and returnes
%the TOF images and the image plane coordinates

if nargin<4
    circCoilCurrent=100;
end

NTOFimages=length(delays); %how many images are we taking?
pixCam.setHardwareTrig(NTOFimages);
motLoadTime=4e6; %4 seconds
pixCam.start;
for ind=1:NTOFimages
    fprintf('taking image: %d at delay %d \n',ind,delays(ind));
    seqUpload(TOFseq(channelTable,'pixelfly',delays(ind),motLoadTime,pixCam.src.E2ExposureTime,circCoilCurrent));
    pause(motLoadTime*1e-6);
end

images=pixCam.getImages(NTOFimages);
pixCam.stop;

scale=4.32e-5; %m/pixel
imsize=size(images(:,:,1));
x=linspace(-imsize(1)/2,imsize(1)/2,imsize(1))*scale;
y=linspace(-imsize(2)/2,imsize(2)/2,imsize(2))*scale;

end

