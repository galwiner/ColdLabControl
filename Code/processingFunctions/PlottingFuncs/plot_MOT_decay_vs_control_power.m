global p;
global r
clear D
powers = controlV2Power(squeeze(mean(r.scopeRes{1}(:,3,:),1)),p.control_pd_gain,p.control_pd_nd);
t0Ind = find(r.scopeDigRes{1}(:,2,1)==1,1)*2+100;
% t0Ind = 1;
t0 = r.scopeRes{1}(t0Ind,1,1);
tf = p.measTime*1e-6+t0;
tfInd = find(r.scopeRes{1}(:,1,1)>tf,1)-100;
if isempty(tfInd)
    tfInd = length(r.scopeRes{1}(:,1,1))-10;
end
D(:,:) = squeeze(r.scopeRes{1}(t0Ind:tfInd,2,:));
goodInds = ones(1,length(p.loopVals{1}));
goodInds(1) = 0;
goodInds(35) = 0;
  ip = [5,0,0.5];
  lp = [0 0 0 ];
  up = [inf inf inf];
  fos = {};
  r2 = zeros(1,length(powers));
  coefs = zeros(3,length(powers));
T = r.scopeRes{1}(t0Ind:tfInd,1,1)-t0;
for ii = 1:length(powers)
[fos{end+1},gof,output] = fitMOTDecay_v2(T,D(:,ii)-p.NoAtomsVal,ip,lp,up);
if ~goodInds(ii)
 r2(ii) = nan;
 coefs(:,ii) = nan(size(coefs,1),1);
 continue
end
r2(ii) = gof.rsquare;
coefs(:,ii) = coeffvalues(fos{end});
end
% coefs(:,r2<0.98) = nan;
N0 = coefs(1,:);
Nf = coefs(2,:);
beta = coefs(3,:);
n=sscanf(p.level,'%d%s');
l = char(n(2));
n(2) = [];
if strcmpi(l,'s')
    warning('Rabi frequency calibration only works for S stats.')
end
rabi = getRabiRb87Sn(powers*1e-3,13*1e-3,n);
dN = N0-Nf;
rabi_log = logspace(log10(min(rabi)),log10(max(rabi)),1e3);
dplit = dN./N0;
ip = [1,0.92,0.95,0.97];
co = colororder;
figure;
subplot(1,2,1)
semilogx(rabi,dplit,'o');
ylabel('\DeltaN/N');
xlabel('\Omega_c [MHz]');
set(gca,'FontSize',14)
grid minor
set(gca,'MinorGridAlpha',1)
%decay rate fit
subplot(1,2,2)
semilogx(rabi,beta,'o')
ylabel('\beta [s^{-1}]');
xlabel('\Omega_c [MHz]');
grid minor
set(gca,'MinorGridAlpha',1)
set(gca,'FontSize',14)