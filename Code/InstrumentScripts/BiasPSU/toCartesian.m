function coords_cartesian=toCartesian(coords_spherical)
x=coords_spherical(:,1).*sin(coords_spherical(:,2)).*cos(coords_spherical(:,3))
y=coords_spherical(:,1).*sin(coords_spherical(:,2)).*sin(coords_spherical(:,3));
z=coords_spherical(:,1).*cos(coords_spherical(:,2));
coords_cartesian=[x,y,z];
end

