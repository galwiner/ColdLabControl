 ROI = [70,260,90,200]; %x1,x2,y1,y2. in pixels
%ROI = [1,260,1,348]; %y1,y2,x1,x2. in pixels
PixCamScale=4.32e-5; %m/pix
cloudCent = [83,56];

[slim,X,Y]=ROISlicer(images,ROI,PixCamScale);
[slbg,X,Y]= ROISlicer(bgimg,ROI,PixCamScale);
[fp,gof,fimages]=vec2DgaussFit([],[],imcleaner(slim,slbg),cloudCent);
imageViewer([],[],fimages)
imageViewer([],[],imcleaner(slim,slbg))

figure;
plot([gof.R2])