function field=getGreatCirclePath(Bi,Bf,nPts)
%returns the shortest path along the sphere (the great circle) required to get from Bi to Bf in nPts
%Bi, Bf are cartesian triplets in Gauss. Note this is a path on a spehre
%because we want to keep the total field constant
%S for spherical coords

planeNormal=cross(Bi,Bf); %normal to the plane spanned by the Bi and Bf vectors
% planeNormal
BiS=toSpherical(Bi);
BfS=toSpherical(Bf);
% deltaB=BfS-BiS;
r=linspace(BiS(1),BfS(1),nPts);
theta=linspace(BiS(2),BfS(2),nPts);
phi=linspace(BiS(3),BfS(3),nPts);
B=toCartesian([r',theta',phi']);
Bx=B(:,1);
By=B(:,2);
Bz=B(:,3);

field=[Bx,By,Bz];
end
