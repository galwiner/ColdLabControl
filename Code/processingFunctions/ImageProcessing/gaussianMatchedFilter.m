function [xcent,ycent]=gaussianMatchedFilter(im,bg)
%returns the maximum pixel location after matched filter (max SNR)
%if an array of images is input, it is assumed to be of size pixX * pixY * N images (3 dimensional)    
%use reshape() accordingly
    
    wx=5;
    wy=5;
    [y,x]=size(im);
    x= linspace(-x/2,x/2-1,x);
    y= linspace(-y/2,y/2-1,y);
    [X,Y]=meshgrid(x,y);
    kernel=1/2/pi/wx/wy*exp(-X.^2/(2*wx.^2)-Y.^2/(2*wy.^2));


for ind=1:size(im,3)
    tic
    thisIm=im(:,:,ind)-bg;
    thisIm=filter2(kernel,thisIm,'same');
%     thisIm=conv2(kernel,thisIm,'same');
    maxSNR=max(max(thisIm));
    [ycent(ind),xcent(ind)]=find(maxSNR==thisIm);
    t=toc;
    fprintf('MATCHED FILTER: image %d of %d. previous iteration took %.2f seconds.\n',ind,size(im,3),t);
end

