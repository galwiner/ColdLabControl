function cleanimages=imcleaner(im,bg,kernel)

if nargin==2 

    wx=5;
    wy=5;
    [x,y]=size(im);
    x= linspace(-x/2,x/2-1,x);
    y= linspace(-y/2,y/2-1,y);
    [X,Y]=meshgrid(x,y);
    kernel=1/2/pi/wx/wy*exp(-X.^2/(2*wx.^2)-Y.^2/(2*wy.^2));
end

for ind=1:size(im,3)
     thisIm=im(:,:,ind)-bg;
     %thisIm=thisIm-mean(mean(thisIm));
     %thisIm=im(:,:,ind);
     %thisIm=thisIm-mean(mean(bg));

    thisIm=filter2(kernel,thisIm,'same');
    thisIm(thisIm<0)=0;
    cleanimages(:,:,ind)=thisIm;
end

