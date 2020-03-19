arrSize=size(images);
imsize=[arrSize(1),arrSize(2)];
%imvec=reshape(images,[arrSize(1),arrSize(2),arrSize(3),arrSize(4)*arrSize(5)]);
imvec=reshape(images,[arrSize(1),arrSize(2),arrSize(3)*arrSize(4)*arrSize(5)]);
x=linspace(0,arrSize(2)-1,arrSize(2))*1.65e-5*4;
y=linspace(0,arrSize(1)-1,arrSize(1))*1.65e-5*4;
x0 = 171*1.65e-5*4;
y0 = 133*1.65e-5*4;
g=9.8;
delayList=[400,1000,3000,5000,10000]*1e-6; %times for the TOF flights in microseconds
% [fp(:,1,:),gof(1,:),fimages(:,:,1,:)]=vec2DgaussFit(x,y,squeeze(imvec(:,:,1,:)),bgimg,x0,y0);
% for ind = 2:length(delayList)
% y0tmp = y0-g/2*delayList(ind)^2;
% [fp(:,ind,:),gof(ind,:),fimages(:,:,ind,:)]=vec2DgaussFit(x,y,squeeze(imvec(:,:,ind,:)),bgimg,x0,y0tmp);
% end
%Fix bad points
[fp,gof,fimages]=vec2DgaussFit(x,y,imvec,bgimg);
% figure;
% subplot(1,2,1)
% imagesc(ROItest(:,:,1))
% hold on
% plot(xcent,ycent,'or');
% subplot(1,2,2)
% imagesc(fimages(:,:,1))
fimagesRS = reshape(fimages,[arrSize(1),arrSize(2),arrSize(3),arrSize(4),arrSize(5)]);
fpRS = reshape(fp,[7,arrSize(3),arrSize(4),arrSize(5)]);
gofRS=reshape(gof,[arrSize(3),arrSize(4),arrSize(5)]);
%% Get Temps
mrb=1.4432e-25;
kb=1.3806e-23;
tmp = zeros(2,arrSize(4),arrSize(5));
lingofR2=zeros(1,arrSize(4),arrSize(5));
for indp = 1:arrSize(4)
    for indd = 1:arrSize(5)
        if length(find(fpRS(5,:,indp,indd)~=0))>2
         [linfit_xtmp,lingoftmp]=fit(delayList'.^2,fpRS(5,:,indp,indd)'.^2,'poly1','Exclude', fpRS(5,:,indp,indd)== 0,'Robust','on');
         tmp(1,indp,indd)=1e6*linfit_xtmp.p1*mrb/kb;
         lingofR2(1,indp,indd)=lingoftmp.rsquare;
        else
            tmp(1,indp,indd)=NaN;
            lingofR2(1,indp,indd) = 0;
        end
        if length(find(fpRS(6,:,indp,indd)~=0))>2
         [linfit_ytmp,lingoftmp]=fit(delayList'.^2,fpRS(6,:,indp,indd)'.^2,'poly1','Exclude', fpRS(6,:,indp,indd)== 0,'Robust','on');
         tmp(2,indp,indd)=1e6*linfit_ytmp.p1*mrb/kb;
         lingofR2(2,indp,indd)=lingoftmp.rsquare;
        else
            tmp(2,indp,indd)=NaN;
            lingofR2(2,indp,indd) = 0;
        end       
    end
end
%%
figure;
subplot(1,2,1)
minxTmp=min(min(squeeze(tmp(1,:,:))));
[minxIndR,minxIndc] = find(squeeze(tmp(1,:,:))==minxTmp);
%imagesc(coolingDet/consts.Gamma,coolingPower,squeeze(tmp(1,:,:)),'AlphaData',~isnan(squeeze(tmp(1,:,:))))
imagesc(coolingDet./consts.Gamma,coolingPower,squeeze(tmp(1,:,:)))
title(sprintf('T_x. min temp is %0.2f [\\muK] for power = %0.0f and detuning = %0.2f[\\Gamma].'...
    ,minxTmp,coolingPower(minxIndR),coolingDet(minxIndc)/consts.Gamma));
xlabel('Detuning[\Gamma]');
ylabel('Cooling Power after DP-AOM[mW]');
set(gca,'FontSize',18)
colormap('jet')
colorbar

% figure;
subplot(1,2,2)
minyTmp=min(min(squeeze(tmp(2,:,:))));
[minyIndR,minyIndc] = find(squeeze(tmp(2,:,:))==minyTmp);
%imagesc(coolingDet./consts.Gamma,coolingPower,squeeze(tmp(2,:,:)),'AlphaData',~isnan(squeeze(tmp(2,:,:))))
imagesc(coolingDet./consts.Gamma,coolingPower,squeeze(tmp(2,:,:)))
title(sprintf('T_y. min temp is %0.2f [\\muK] for power = %0.0f and detuning = %0.2f[\\Gamma].'...
    ,minyTmp,coolingPower(minyIndR),coolingDet(minyIndc)/consts.Gamma));
xlabel('Detuning[\Gamma]');
ylabel('Cooling Power after DP-AOM[mW]');
set(gca,'FontSize',18)
colormap('jet')
colorbar

%% interpolated image for prettier results

% 
% xq = linspace(min(coolingDet),max(coolingDet),12)./consts.Gamma;
% yq = linspace(min(coolingPower),max(coolingPower),12);
% [X,Y]=meshgrid(coolingDet./consts.Gamma,coolingPower);
% Zy=squeeze(tmp(2,:,:));
% Zx=squeeze(tmp(1,:,:));
% [Xq,Yq] = meshgrid(xq,yq);
% Zx = interp2(X,Y,Zx,Xq,Yq,'spline');
% Zy = interp2(X,Y,Zy,Xq,Yq,'spline');
% Zx(Zx<0)=NaN;
% Zy(Zy<0)=NaN;
% figure;
% subplot(1,2,1)
% imagesc(xq,yq,Zx)
% colormap('jet')
% hold on
% % set(gca,'xtick',xq+0.5*(xq(2)-xq(1)))
% % set(gca,'ytick',yq+0.5*(yq(2)-yq(1)))
% % 
% % grid on
% % ax = gca;
% % ax.GridColor = 'k'
% % ax.Layer='top'
% % ax.GridColorMode='manual'
% % ax.GridAlpha=0.5
% % [C,h]=contour(xq,yq,Zx,'color','k');
% % clabel(C,h);
% colorbar
% xt = get(gca, 'XTick');
% set(gca, 'FontSize', 16)
% xlabel('Cooling Detuning [\Gamma]','FontSize', 18)
% ylabel('Total cooling power [mW]','FontSize', 18);
% title('T_x [\mu K]','FontSize', 18)
% axis square
% 
% subplot(1,2,2)
% imagesc(xq,yq,Zy)
% colormap('jet')
% % grid on
% hold on
% [C,h]=contour(xq,yq,Zy,[600,500,400,200,100],'color','k');
% clabel(C,h);
% set(gca,'xtick',xq+0.5*(xq(2)-xq(1)))
% set(gca,'ytick',yq+0.5*(yq(2)-yq(1)))

% grid on


% ax.GridColor = 'k'
% ax.Layer='top'
% ax.GridColorMode='manual'
% ax.GridAlpha=0.5
% xt = get(gca, 'XTick');
% xtickformat('%.1f')
% ytickformat('%.0f')
% set(gca, 'FontSize', 12)
% colorbar
% xlabel('Cooling Detuning [\Gamma]','FontSize', 18);
% ylabel('Total cooling power [mW]','FontSize', 18);
% title('T_y [\mu K]','FontSize', 18)
% axis square
% suptitle('ToF measurements of released MOT cloud')
% set(gcf,'color','w');
%% atom numbers in these figure

AtomNum=squeeze(fpRS(7,1,:,:)); %integrated intensity in the gaussian
AtomNum= AtomNum*atomNumberFromCollectionParams();
[maxAtoms,MaxAtomsInd]=max(AtomNum(:));
[MaxAtomsInd_R,MaxAtomsInd_C]=ind2sub([length(coolingPower),length(coolingDet)],MaxAtomsInd);
figure;
imagesc(coolingDet/consts.Gamma,coolingPower,AtomNum(:,:))
colormap('jet')
title(sprintf('Atom number. max is %0.2e for power = %0.0f and detuning = %0.2f.[\\Gamma]'...
    ,maxAtoms,coolingPower(MaxAtomsInd_R),coolingDet(MaxAtomsInd_C)/consts.Gamma));
xlabel('Detuning[\Gamma]');
ylabel('Cooling Power after DP-AOM[mW]');
set(gca,'FontSize',20)
colorbar
%%

peakDensity=AtomNum./squeeze(fpRS(6,1,:,:))./squeeze(fpRS(5,1,:,:).^2)/((2*pi)^(3/2)); %in 1/m^3
peakDensity = peakDensity*1e-6;
[maxDensity,MaxDensityInd]=max(peakDensity(:));
[MaxDensityInd_R,MaxDensityInd_C]=ind2sub([length(coolingPower),length(coolingDet)],MaxDensityInd);
figure;
imagesc(coolingDet/consts.Gamma,coolingPower,peakDensity(:,:))
colormap('jet')
title(sprintf('Peak density. max is %0.2e [cm^{-3}] for power = %0.0f and detuning = %0.2f[\\Gamma].'...
    ,maxDensity,coolingPower(MaxDensityInd_R),coolingDet(MaxDensityInd_C)/consts.Gamma));
xlabel('Detuning[\Gamma]');
ylabel('Cooling Power after DP-AOM[mW]');
set(gca,'FontSize',20)
colorbar

%%

%Stat
figure;
plot(lingofR2(1,:),'o');
hold on
plot(lingofR2(2,:),'o');
legend('linear fir R2 x','linear fir R2 y')
title('Linear fit R2')

figure;
R2=[gof(:).R2];
avrR2 = mean(R2);
plot(R2,'o');
title(sprintf('Gaussian fit R2. The average is %0.2f',avrR2));
 
figure;
plot(AtomNum(:),peakDensity(:),'o')
title('Peak density vs. atom number');
xlabel('Atom Number');
ylabel('Peak density[cm^{-3}]');
set(gca,'FontSize',20)

