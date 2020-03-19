
function atomNumber=getAtomNumberFromImage(p7,power,exposure,delta,cameraName)
%4/12/17 LD&GW.
%function to calculate the atom number from the integrated intensity in the
%fitted gaussian (p7). power in mW. delta is the detuning of the imaging
%beam, exposure is exposure time in microseconds

if strcmpi(cameraName,'pixelfly')
L=19.6;%cm
k=62; %photons/count
r=2.5; %cm
waist=0.5*2.54;%1 inch diameter collimated cooling beams
else
    error('no other cameras exist in getAtomNumberFromImage');
end

prefactor=atomNumberFromCollectionParams(L,k,r,power,exposure,delta,waist);
atomNumber=prefactor*p7;

end
