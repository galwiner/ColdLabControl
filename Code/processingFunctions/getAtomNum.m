function atomNum=getAtomNum(fitIntegratedIntensity,varargin)
%assuming pixelfly
%L: distance to camera; in cm, k: quantum efficiency, r: lens radius; in cm, power: in mW,
%expTime: integration time , delta:detuning in MHz from cycling transition, waist: beam waist in cm
global p;
global r;
%check what camera was used
if nargin==1
    camera = 'pf';
else
    camera = varargin{1};
end
%verify camera
if strcmpi(camera,'pf')~=1&&strcmpi(camera,'ids')~=1
    error('camera must be ''pf'', or ''ids'', not %s\n',camera)
end
if strcmpi(camera,'pf')==1
    L = 10;
    R = 2.54;
else
    L = 16;
    R = 2.54;
end
% k = 62; %number pf photons per count. This is wrong! We changed this on
% 25/10/18
k = 8.96; %number pf photons per count, measured. see ...\InstrumentScripts\Camera\pixelflyQuantumEffitiencyCalib.m
gamma = 6.066; %MHz
Omega=4*pi*R^2/4/L^2;
GammaSc=gamma/2;
% fitIntegratedIntensity=reshape(fitIntegratedIntensity,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
% atomNum = ones(size(fitIntegratedIntensity));
% for ii=1:size(fitIntegratedIntensity,2)
%     atomNum(:,ii,:,:) = prefactor(ii)*fitIntegratedIntensity(:,ii,:,:);
% end
% prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
if isfield(p,'flashTime')
    if ~isempty(p.loopVars)
        if strcmpi(p.loopVars{1},'flashTime')
            expTime = p.loopVals{1};
            prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
            fitIntegratedIntensity=reshape(fitIntegratedIntensity,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
            atomNum = ones(size(fitIntegratedIntensity));
            for ii=1:size(r.images{1},5)
                atomNum(:,:,ii,:,:) = prefactor(ii)*fitIntegratedIntensity(:,:,ii,:,:);
            end
            atomNum = atomNum(:);
        else
            if length(p.loopVars)>1
                if strcmpi(p.loopVars{2},'flashTime')
                    expTime = p.loopVals{2};
                    prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
                    fitIntegratedIntensity=reshape(fitIntegratedIntensity,size(r.images{1},3),size(r.images{1},4),size(r.images{1},5),size(r.images{1},6));
                    atomNum = ones(size(fitIntegratedIntensity));
                    for ii=1:size(r.images{1},4)
                        atomNum(:,ii,:,:,:) = prefactor(ii)*fitIntegratedIntensity(:,ii,:,:,:);
                    end
                    atomNum = atomNum(:);
                else
                    expTime = p.flashTime;
                    prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
                    atomNum = prefactor*fitIntegratedIntensity;
                end
            else
                expTime = p.flashTime;
                prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
                atomNum = prefactor*fitIntegratedIntensity;
            end
        end
    else
        expTime = p.flashTime;
        prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
        atomNum = prefactor*fitIntegratedIntensity;
    end
else
    expTime=p.cameraParams{1}.E2ExposureTime;
    prefactor=k./((Omega/4/pi)*GammaSc.*expTime);
    atomNum = prefactor*fitIntegratedIntensity;
end
end
