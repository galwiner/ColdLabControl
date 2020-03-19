function [temp,Natoms]=TOFfitterFunc(images,delays,x,y,bgImg,beampower,camexposure,cameraName)
%function to return the temperature vector (in x,y) and a vector containing the number of
%atoms in each image (after each delay) 
%%

mrb=1.443161706323046e-25;
kb=1.380600000000000e-23;

NTOF=size(images,3);



for ind=1:NTOF
    [p(:,ind),fitImages(:,:,ind)]=fitImageGaussian2D(x,y,images(:,:,ind)-bgImg);
    if isnan(p(:,ind))
        error('fit has failed!')
    end
    Natoms(ind)=getAtomNumberFromImage(p(7,ind),beampower,camexposure,0,cameraName);
end

delay=delays*1e-6;
fx=fit(delay'.^2,p(5,:)'.^2,'poly1');
fy=fit(delay'.^2,p(6,:)'.^2,'poly1');

temp=[fx.p1*mrb/kb,fy.p1*mrb/kb];



end
