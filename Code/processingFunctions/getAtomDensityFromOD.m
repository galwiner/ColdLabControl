function atomDensity=getAtomDensityFromOD(OD,sigma_x,polarization,varargin)
%varargin, expect pairs of varNames and varVals, for example, 'pumped',1.
%polarization is 1 for circ (sigma+ or sigma -) and 0 for linear
%based on the formula: 
%OD = k*sqrt(2pi)sigma_x*rho*mu^2/(hbar*gamma*epsilon0)
if nargin>4
    pumpedInd = find(strcmpi(varargin,'pumped'));
    if ~isempty(pumpedInd)
       pumpedVal = varargin{pumpedInd+1};
    else
        pumpedVal = 0;
    end
else
    pumpedVal = 0;
end
global p
if ~isfield(p,'consts')
    initp
end

lambda = 780e-9;
k = 2*pi/lambda;
gamma = 2*pi*p.consts.Gamma/2*1e6; %the 2pi is important. gamma should be in 2piHz
epsilon0 = p.consts.epsilon0;
hbar = p.consts.hbar;
if polarization == 1
   if pumpedVal == 1
       CG = sqrt(1/2);
   else
       CG = sqrt(1/5*(1/30+1/10+1/5+1/3+1/2));
   end
elseif polarization == 0
       if pumpedVal == 1
       warning('this code does not include pumped linear polarization, ignoring pumped') 
       else
       CG = sqrt(1/5*(1/6+4/15+3/10+4/15+1/6));
   end
end
mu = 3.584e-29*CG; %dipole moment, in C*m;
atomDensity = OD*hbar*gamma*epsilon0./(sqrt(2*pi)*sigma_x*k*mu^2); %in m^-3
atomDensity = atomDensity*1e-6; % in cm^-3
end