function [efficiency,mf2]=getPumpingEffitiency(ODRatio,model)
%modle = 0: x% of the atoms are in mf=2 and (100-x) are equaly distributted
%between the rest.
%modle = 1: x% of the atoms are in mf=2 and (100-x) are in mf=1.
switch model
    case 0
        % ODRatio=(x*0.5+(1-x)*0.25*(1/3+1/5+1/10+1/30))/((1-x)*0.25*(1/12+1/8+1/8+1/12))
        mf2 = (ODRatio*5/48-1/6)./(1/2+ODRatio*5/48-1/6);
        
    case 1
        mf2 = (ODRatio/12-1/3)./(1/2+ODRatio/12-1/3);    
end
efficiency = 125*(mf2-0.2);
end
