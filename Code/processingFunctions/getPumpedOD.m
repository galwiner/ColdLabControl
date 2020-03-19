function pumpedOD = getPumpedOD(OD,mf2,model)
%modle = 0: x% of the atoms are in mf=2 and (100-x) are equaly distributted
%between the rest.
%modle = 1: x% of the atoms are in mf=2 and (100-x) are in mf=1.
switch model
    case 0
        factor = 0.5./(mf2*0.5+(1-mf2)*0.25*(1/3+1/5+1/10+1/30));
    case 1
        factor = 0.5./(mf2*0.5+(1-mf2)/3);

end
   pumpedOD = OD.*factor;
end