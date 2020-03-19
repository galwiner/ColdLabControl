function [temp,images,fitImages,fitParams]=thermometryFunc(ct,pixCam,bgimg,delayList,current,coolingPower)

% % take a bg image with light on but magnetic field off
% seqUpload(LoadMotSeq(ct));
% setAHHCurrent(ct,'circ',0);
% pause(0.2);
% bgimg=pixCam.snapshot;

if isempty(delayList)
    delayList=[400,1000,3000,5000,10000]; %times for the TOF flights in microseconds
end

N=length(delayList); %how many images are we taking?

% pixCam.setHardwareTrig(N);

motLoadTime=2e6; %2 seconds

% pixCam.start;


%     fprintf('taking image: %d at delay %d \n',ind,delayList(ind));

[seq,tend]=TOFseq(ct,'pixelfly',delayList,motLoadTime,pixCam.src.E2ExposureTime,current,coolingPower);
seqUpload(seq);
pause(tend*1e-6+0.01);
images=pixCam.getImages(N);
% pixCam.stop;
% setAHHCurrent(ct,'circ',0);

scale=pixCam.scale;


% cleanimages=imcleaner(images,bgimg,ones(4));
 imsize=size(images(:,:,1));
 y=linspace(1,imsize(1)+1,imsize(1))*scale;
 x=linspace(1,imsize(2)+1,imsize(2))*scale;
for ind=1:N
    [fitParams.fgaussian(:,ind),fitParams.gaussGOF(:,ind),fitImages(:,:,ind)]=...
        fitImageGaussian2D(x,y,images(:,:,ind)-bgimg,1,[x(171),y(133)]);
end

delayList=delayList*1e-6;
if length(find(fitParams.fgaussian(5,:)>0))>2
[fx,fitParams.gofx]=fit(delayList'.^2,fitParams.fgaussian(5,:)'.^2,'poly1',...
    'Exclude',fitParams.fgaussian(5,:)==0);
else
    fx.p1=0;
    fitParams.gofx = 0;
end
if length(find(fitParams.fgaussian(6,:)>0))>2
[fy,fitParams.gofy]=fit(delayList'.^2,fitParams.fgaussian(6,:)'.^2,'poly1',...
    'Exclude',fitParams.fgaussian(6,:)==0);
else
    fy.p1=0;
    fitParams.gofy = 0;
end
temp=zeros(1,2);
mrb=1.4432e-25;
kb=1.3806e-23;

temp(1)=1e6*fx.p1*mrb/kb;
if temp(1)==0
temp(1) = NaN;
end
temp(2)=1e6*fy.p1*mrb/kb;
if temp(2)==0
temp(2) = NaN;
end
end

