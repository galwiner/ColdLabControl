function h=imageViewer(images,x,y,titleList,suptitleText,varargin)
%varargin{1} is a flag to plot beamlines on the images

images = squeeze(images);
if length(size(images))>3
    error('images hase more then 3 non-singlton dimentions'); 
end
N=size(images,3);
if nargin<2
    x=[];
    y=[];
end
if nargin<4
    titleList=cell(1,N);
end

if nargin<5
    suptitleText='';
end

if nargin<6
    scaleAll=0;
end


if isempty(titleList)
    titleList=cell(1,N);
end

h=figure;

imsize=[size(images,1),size(images,2)];
if isempty(x)
    x=1:1:imsize(2);
end

if isempty(y)
    y=1:1:imsize(1);
end
beamLineFlag  = 0;
if nargin == 6
  if varargin{1}==1
      beamLineFlag  = 1;
      whiteBeam = whiteBeamLine(x,x(2)-x(1));
      redBeam = redBeamLine(x,x(2)-x(1));
  end
end
t=annotation('textbox', [0 0.9 1 0.1], ...
    'String', suptitleText, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
t.FontSize=18;
colnum=4;
rownum=ceil(N/4);
if N<4
    colnum = N;
end
maxPix=max(images(:));
minPix=min(images(:));
for ind =1:size(squeeze(images(size(images,1),size(images,2),:)),1)
    subplot(rownum,colnum,ind);
    imagesc(x,y,squeeze(images(:,:,ind)));
    if scaleAll
        caxis([minPix,maxPix]);
    end
    title(titleList{ind});
    colorbar
    
    if beamLineFlag
        hold on
        line(x,whiteBeam,'color','r');
        line(x,redBeam,'color','r');
    end
end

