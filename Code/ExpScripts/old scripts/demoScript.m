%MOT DEMO Script
clear all
basicImports
cooling=ICELaser('COM4',3,3,4);
repump=ICELaser('COM4',4,1,2);

cooling.setExtFreq(coolingDetToFreq(-3*consts.Gamma));
repump.setExtFreq(repumpDetToFreq(0));
bpsu1=BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'); % Z and Y bias coils 
bpsu2=BiasPSU('TCPIP::10.10.10.107::inst0::INSTR'); % X bias coil
% seqUpload(channelToggleSeq(channelTable,'TA',1));%this is a dangeroud
% line! don't use unless you know the DBRs are on! also, implement a
% protection with a photodiode as soon as possible

pixCam=pixelfly();
pixCam.setExposure(3000);
pixCam.handle.ROIPosition=[410 475 276 208];
seqUpload(LoadMotSeq(channelTable,0,70));
% figure;


% subplot(2,1,1);    h=imagesc(im); axis square;
% subplot(2,1,2);    imagesc(fitIm); axis square;
% while 1
%     
% im=pixCam.snapshot();    
%     [p,fitIm]=fitImageGaussian2D([],[],im);
%     subplot(2,1,1);    imagesc(im); axis square;
%     subplot(2,1,2);    imagesc(fitIm); axis square;
%     title(sprintf('N= %.2e',p(7)));
%     pause(0.5);
% end

% Create a figure window. This example turns off the default
% toolbar and menubar in the figure.
hFig = figure('Toolbar','none',...
       'Menubar', 'none',...
       'NumberTitle','Off',...
       'Name','My Custom Preview GUI');

% Set up the push buttons
uicontrol('String', 'Start Preview',...
    'Callback', 'preview(pixCam.handle)',...
    'Units','normalized',...
    'Position',[0 0 0.15 .07]);
uicontrol('String', 'Stop Preview',...
    'Callback', 'stoppreview(pixCam.handle)',...
    'Units','normalized',...
    'Position',[.17 0 .15 .07]);
uicontrol('String', 'Close',...
    'Callback', 'close(gcf)',...
    'Units','normalized',...
    'Position',[0.34 0 .15 .07]);

% Create the text label for the timestamp
hTextLabel = uicontrol('style','text','String','Timestamp', ...
    'Units','normalized',...
    'Position',[0.85 -.04 .15 .08]);
vidRes = pixCam.handle.VideoResolution;
imWidth = vidRes(1);
imHeight = vidRes(2);

nBands = pixCam.handle.NumberOfBands;
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );

% hImage2 = image( zeros(vidRes(2), vidRes(1), nBands) );



% Specify the size of the axes that contains the image object
% so that it displays the image at the right resolution and
% centers it in the figure window.
figSize = get(hFig,'Position');
figWidth = figSize(3);
figHeight = figSize(4);
gca.unit = 'pixels';
gca.position = [ ((figWidth - imWidth)/2)... 
               ((figHeight - imHeight)/2)...
               imWidth imHeight ];
           



% Set up the update preview window function.
setappdata(hImage,'UpdatePreviewWindowFcn',@mypreview_fcn);
% setappdata(hImage2,'UpdatePreviewWindowFcn',@mypreview_fcn2);
% Make handle to text label available to update function.
setappdata(hImage,'HandleToTimestampLabel',hTextLabel);

preview(pixCam.handle, hImage); 


function mypreview_fcn(obj,event,himage)
% Example update preview window function.

% Get timestamp for frame.
tstampstr = event.Timestamp;

% Get handle to text label uicontrol.
ht = getappdata(himage,'HandleToTimestampLabel');

% Set the value of the text label.
ht.String = tstampstr;

% Display image data.
[~,fitIm]=fitImageGaussian2D([],[],event.Data);
himage.CData = fitIm;
end

function mypreview_fcn2(obj,event,himage)
% Example update preview window function.

% Display image data.

himage.CData = abs(event.Data).^2;

end
% 
% for ind=1:10
%     for jnd=1:10
% 
%     end
% end
% 





