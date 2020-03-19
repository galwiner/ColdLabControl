function readings = spcmLinearize(readings)
%inputs is readings in Mega counts per second
load('SPCM_CAL_CURVE.mat');
readings=readings.*interp1(SPCM_CAL_CURVE(:,1),SPCM_CAL_CURVE(:,2),readings);
end

