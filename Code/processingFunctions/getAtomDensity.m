function density = getAtomDensity(atomNum,sigmaVec)
global p
%in atoms per cc
if ~isfield(p,'DTPic')
    p.DTPic = 0;
end
if size(sigmaVec,1)==2
    if p.DTPic ==0
    sigmax=sigmaVec(1,:);
    sigmay=sigmax;
    sigmaz=sigmaVec(2,:);
    else
    sigmay=sigmaVec(1,:);
    sigmax=sigmaVec(2,:);
    sigmaz=sigmaVec(2,:);  
    end
else
    sigmax=sigmaVec(1,:);
    sigmay=sigmaVec(2,:);
    sigmaz=sigmaVec(3,:);
end
volume = (2*pi)^(3/2) * sigmax.*sigmay.*sigmaz;
if iscolumn(atomNum)
    atomNum = atomNum';
end
density = (10^-6)*atomNum./volume;
end

