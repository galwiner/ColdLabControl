%initialize result structure
global p
global r
global inst
% clear -gloval r %comentade out on 06/09/18 by LD. This caused a problem
% where the images would not be returned form p.s.run.
if isfield(p,'pfLiveMode')
    p.pfPlaneLiveMode = p.pfLiveMode;
end
if isfield(p,'tcLiveMode')
    p.pfTopLiveMode = p.tcLiveMode;
end
if p.pfPlaneLiveMode && p.pfTopLiveMode && ~p.hasScopResults && ~p.hasSpecResults
    return
end
r.ncams=2;
% tcImSizeX=double(tc.ImageData.Width);
% tcImSizeY=double(tc.ImageData.Height);
% first array is pixefly, secondarray is thorcam
% r.images={zeros(pxImSizeY,pxImSizeX,p.NTOF,length(p.loopVals{1}),length(p.loopVals{2}),p.NAverage),...
%           zeros(tcImSizeY,tcImSizeX,p.NTOF,length(p.loopVals{1}),length(p.loopVals{2}),p.NAverage)};
if size(p.loopVals,2)~=0
    NIner = length(p.loopVals{1});
else
    NIner=1;
end
if size(p.loopVals,2)>1
    NOuter = length(p.loopVals{2});
else
    NOuter=1;
end
if NIner==0
    error('Can''t run a loop on outer loop without inner loop!');
end
if p.hasScopResults
    r.scopeRes=[];
    r.scopeDigRes=[];
end

if p.pfPlaneLiveMode && p.pfTopLiveMode
    r.images={{},{}};
elseif p.pfPlaneLiveMode && ~p.pfTopLiveMode
    pfTop=inst.cameras('pixelflyTop');
%     [x,y]=getImSize(obj)
%changed on 25/10/2018
%     pxImSizeX=pfTop.src.H2HardwareROI_Width;
%     pxImSizeY=pfTop.src.H5HardwareROI_Height;
    [pxImSizeX,pxImSizeY] = pfTop.getImSize;
    r.bgImg={[],zeros(pxImSizeY,pxImSizeX)};
    r.images={[],zeros(pxImSizeY,pxImSizeX,p.picsPerStep,NOuter,NIner,p.NAverage)};
elseif ~p.pfPlaneLiveMode && p.pfTopLiveMode
    pf=inst.cameras('pixelflyPlane');
    %changed on 25/10/2018
%     pxImSizeX=pf.src.H2HardwareROI_Width;
%     pxImSizeY=pf.src.H5HardwareROI_Height;
    [pxImSizeX,pxImSizeY] = pf.getImSize;
    r.bgImg={zeros(pxImSizeY,pxImSizeX),[]};
    r.images={zeros(pxImSizeY,pxImSizeX,p.picsPerStep,NOuter,NIner,p.NAverage),[]};
elseif ~p.pfPlaneLiveMode && ~p.pfTopLiveMode
    pfTop=inst.cameras('pixelflyTop');
    %changed on 25/10/2018
%     pxTopImSizeX=pfTop.src.H2HardwareROI_Width;
%     pxTopImSizeY=pfTop.src.H5HardwareROI_Height;
    [pxTopImSizeX,pxTopImSizeY] = pfTop.getImSize;
    r.images={[],zeros(pxTopImSizeY,pxTopImSizeX,p.picsPerStep,NOuter,NIner,p.NAverage)};
    pf=inst.cameras('pixelflyPlane');
    %changed on 25/10/2018
%     pxImSizeX=pf.src.H2HardwareROI_Width;
%     pxImSizeY=pf.src.H5HardwareROI_Height;
    [pxImSizeX,pxImSizeY] = pf.getImSize;
    r.bgImg={zeros(pxImSizeY,pxImSizeX),zeros(pxTopImSizeY,pxTopImSizeX)};
    r.images={zeros(pxImSizeY,pxImSizeX,p.picsPerStep,NOuter,NIner,p.NAverage),...
        zeros(pxTopImSizeY,pxTopImSizeX,p.picsPerStep,NOuter,NIner,p.NAverage)};
end
r.fitImages=r.images;
r.fitParams={zeros(7,p.picsPerStep,NOuter,NIner,p.NAverage),...
    zeros(7,p.picsPerStep,NOuter,NIner,p.NAverage)};

r.atomNum={zeros(p.picsPerStep,NOuter,NIner,p.NAverage),0};
r.atomDensity={zeros(p.picsPerStep,NOuter,NIner,p.NAverage),0};
%spectrum analyzer results
if p.hasSpecResults
   r.specRes = {'',''};
   r.specRes{1} = zeros(461,2,NOuter,NIner,p.NAverage);
   r.specRes{2} = zeros(461,2,NOuter,NIner,p.NAverage);
end