function coords_spherical=toSpherical(coords_cartesian)
r=sqrt(sum(coords_cartesian.*coords_cartesian));
theta=acos(coords_cartesian(3)/r);
phi=atan2(coords_cartesian(2),coords_cartesian(1));
coords_spherical=[r,theta,phi];
end

