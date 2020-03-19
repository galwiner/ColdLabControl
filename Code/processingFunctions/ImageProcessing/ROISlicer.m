function [SlicedImages,X,Y] = ROISlicer(images,ROI,scale)
%LD & GW 6.12
%This function cropes an image to a specified ROI
% in format [y1,y2,x1,x2] the diagonal corners of the image

%     ScalingFactorX = (abs(ROIXvec(end)-ROIXvec(1)))/abs(Xcoords(end)-Xcoords(1));
%     ScalingFactorY = (abs(ROIYvec(end)-ROIYvec(1)))/abs(Ycoords(end)-Ycoords(1));
%     X = Xcoords*ScalingFactorX;
% %     Y = Ycoords*ScalingFactorY;
for ind = 1:length(ROI)
    if (ROI(ind)-floor(ROI(ind)))<(ceil(ROI(ind))-ROI(ind))
        ROI(ind)=floor(ROI(ind));
    else
     ROI(ind) = ceil(ROI(ind));
    end
end
    height = ROI(2)-ROI(1);

    width = ROI(4)-ROI(3);
%  Y = linspace(-height/2,height/2-1,height+1)*scale;
%     X = linspace(-width/2,width/2-1,width+1)*scale;
Y = (1:1:floor(height+1))*scale;
X = (1:1:floor(width+1))*scale;
SlicedImages = images(ROI(1):ROI(2),ROI(3):ROI(4),:);
    
end
