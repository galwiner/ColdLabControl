function [fp,gof,fimages]=vecAbsImFit(x,y,normIm,xCents,yCents,xWidths,yWidths)

%fp is the fit parameter vector
%gof is the gooness of fit vector (R^2, maybe more stuff later)
%fimages is the array of fit images
imSize=size(normIm);
% if length(imSize)==2
%     fimages=zeros(imSize(1),imSize(2),1);  
% else
%     fimages=zeros(imSize(1),imSize(2),imSize(3));  
% end

if length(xCents)==1
    xCents=ones(1,size(normIm,3))*xCents;
end
if length(yCents)==1
    yCents=ones(1,size(normIm,3))*yCents;
end
if length(xWidths)==1
    xWidths=ones(1,size(normIm,3))*xWidths;
end
if length(yWidths)==1
    yWidths=ones(1,size(normIm,3))*yWidths;
end
for ii=1:size(normIm,3)
    [fp(:,ii),gof(ii),fimages(:,:,ii)]=fitODGaussian(x,y,normIm(:,:,ii),'cloud_center',[xCents(ii),yCents(ii)]...
        ,'cloudXwidth',xWidths(ii),'cloudYwidth',yWidths(ii));
end
end
