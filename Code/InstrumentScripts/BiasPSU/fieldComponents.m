function [Bcomp,Icomp]=fieldComponents(B,theta,phi)
%theta,phi are in degrees
%theta is between 0 and 180, measured from z axis
%phi is 0 and 360, measured from x axis
%B gradient Gauss/A [x,y,z] = [8.496,4.355,12.097]
% at 1A each, |B|=15.4 Gauss
%max current per channel is 1.51A
currentCoeffs= [8.496,4.355,12.097];
assert((theta<=180)&&(theta>=0));
assert((phi<=360)&&(theta>=0));
theta=theta*pi/180;
phi=phi*pi/180;

Bx=B*sin(theta)*cos(phi);
By=B*sin(theta)*sin(phi);
Bz=B*cos(theta);

Bcomp=[Bx,By,Bz];
Icomp=Bcomp./currentCoeffs;
if any(Icomp>1.51)
    warning('Requested field requires more than PSU max current');
end

end
