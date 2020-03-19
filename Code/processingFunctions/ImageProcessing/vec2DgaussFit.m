function [fp,gof,fimages]=vec2DgaussFit(x,y,images,bgimg,xCent,yCent)

%fp is the fit parameter vector
%gof is the gooness of fit vector (R^2, maybe more stuff later)
%fimages is the array of fit images
if nargin ==4
    xCent=[];
    yCent=[];
elseif nargin ==5
    yCent=[];
end
imSize=size(images);
if length(imSize)==2
    fimages=zeros(imSize(1),imSize(2),1);  
else
    fimages=zeros(imSize(1),imSize(2),imSize(3));  
end

if length(xCent)==1
    xCent=ones(1,size(images,3))*xCent;
end

if length(yCent)==1
    yCent=ones(1,size(images,3))*yCent;
end

if ~isempty(xCent)
for ind=1:size(images,3)
    tic
    [fp(:,ind),gof(ind),fimages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind)-bgimg,1,[xCent(ind),yCent(ind)]);
    t=toc;
   % fprintf('Fitting image %d of %d. previous iteration took %.2f seconds.\n',ind,size(images,3),t);
end
else
for ind=1:size(images,3)
    tic
    [fp(:,ind),gof(ind),fimages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind)-bgimg,1);
    t=toc;
    %fprintf('Fitting image %d of %d. previous iteration took %.2f seconds.\n',ind,size(images,3),t);
end
end


end
