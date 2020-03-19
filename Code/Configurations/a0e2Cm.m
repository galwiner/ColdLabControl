function muCm = a0e2Cm(mua0e)
%L.D 04/09/18. This function gets a dipole moment in units of r0*e and returns it in units of C*m
global p
if isempty(p)
   initp
end
muCm= mua0e*p.consts.a0*p.consts.e;
end