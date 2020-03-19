function absImagePostproc()
global r 
global p
global inst
picsPerStep=size(r.images{1},3);
origSize=size(r.images{1});
r.AbsoImagesStack=(r.images{1}(:,:,1,:,:,:)-200)./(r.images{1}(:,:,2,:,:,:)-200);

if picsPerStep==1
    Warning("Only one absorption image. cannot calculate OD witouth reference picture")
    return 
end
   
if mod(picsPerStep,2)~=0
    warning("not an even number of pictures in absImagePostProc. Using second picture as reference for missing pictures")
end
fp=[]; 
if ~isfield(r,'absoOD')
    r.abso_rho=[];
end
for ind=1:size(r.AbsoImagesStack,4)
    for jnd=1:size(r.AbsoImagesStack,5)
        for knd=1:size(r.AbsoImagesStack,6)
xcross=r.AbsoImagesStack(:,p.absoImageCenter(1),1,ind,jnd,knd);
ycross=r.AbsoImagesStack(p.absoImageCenter(2),:,1,ind,jnd,knd);
r.absoImCrosses{1}(ind,jnd,knd,:) = xcross;
r.absoImCrosses{2}(ind,jnd,knd,:) = ycross;
fp(ind,jnd,knd,:)=fitAbsImCrossections(xcross,ycross);
r.abso_rho(ind,jnd,knd)=getAtomDensityFromOD(fp(ind,jnd,knd,1),fp(ind,jnd,knd,5)*inst.cameras('pixelfly').getScale,1);
r.absoImCrossesFit{ind,jnd,knd,:,1} = absoImageCrossfit_func(1:length(xcross),fp(ind,jnd,knd,:),1);
r.absoImCrossesFit{ind,jnd,knd,:,2} = absoImageCrossfit_func(1:length(ycross),fp(ind,jnd,knd,:),0);
        end
    end
end

% figure;
% for ind=1:p.NAverage
% subplot(1,2,1)
% plot(absoImageCrossfit_func(1:200,fp(1,1,knd,:),1))
% hold on
% subplot(1,2,2)
% plot(absoImageCrossfit_func(1:200,fp(1,1,knd,:),0))
% hold on
% end
% r.abso_rho=reshape(r.abso_rho,origSize(4:6));
r.abso_rho_std=std(r.abso_rho,1,3);
r.abso_rho_mean=mean(r.abso_rho,3);

r.absImfp=fp;



