function ROI = calculateROI(centx,centy,hight,width)
%this function terurns and ROI in the format of [left,top,width,hight]
ROI =round([centx-width/2,centy-hight/2,width,hight]);
end