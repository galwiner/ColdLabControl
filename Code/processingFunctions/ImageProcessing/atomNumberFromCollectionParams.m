function prefactor=atomNumberFromCollectionParams(expTime,L,k,r)
%returns the correction factor from integrated intensity in the fitted gaussian to atom
%number.
%L: distance to camera; in cm, k: quantum efficiency, r: lens radius; in cm, power: in mW,
%expTime: integration time , delta:detuning in MHz from cycling transition, waist: beam waist in cm
if nargin==0
    expTime = 200;
    L = 19.6;
    r = 2.54;
    k = 62;
end
if nargin==1
    L = 19.6;
    r = 2.54;
    k = 62;
end
gamma = 6.066; %MHz

Omega=4*pi*r^2/4/L^2;
GammaSc=gamma/2;
prefactor=k/((Omega/4/pi)*GammaSc*expTime);
end
