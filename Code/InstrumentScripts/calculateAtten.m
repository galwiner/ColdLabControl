function [atten,maxPower,minPower]=calculateAtten(ND_list,laserName)
    %based on calibration data from 13/02/19
    %maxPower and minPower gives output limits ON ATOMS given the calibration curve
    %and selected attenuators. for the probe maxPower (and min) are in nW.
    %for the zeeman beams it is in mW
    
    
    atten=1;
    if nargin==0
        ND_list=[];
        laserName='probe';
    end
    if nargin==1
        laserName='probe';
    end
    switch lower(laserName)
        case lower('probe')
            load('probePower2AO.mat')
        case lower('zeemanPump')
            load('ZeemanPumpPower2AO.mat')
        case lower('zeemanRepump')
            load('ZeemanRepumpPower2AO.mat')
        case 'control'
            load('controlAngle2Power.mat')
        otherwise
            error('no such laser!');
    end 
    
    
    if any(ND_list==1)%ND4
        atten=atten*0.0019;
    end
    if any(ND_list==2)%ND3
        atten=atten*0.0088;
    end
    if any(ND_list==3)%ND6
        atten=atten*4.87e-4;
    end
    if any(ND_list==4)%ND0.5
        atten=atten*0.5441;
    end
    if any(ND_list==5)%ND0.5
        atten=atten*0.4964;
    end
    if any(ND_list==6)%ND4
        atten=atten*2e-3;
    end
    if any(ND_list==7)%ND2
        atten=atten*0.0368;
    end
    if any(ND_list==8)%ND1
        atten=atten*0.1851;
    end
    if any(ND_list==9)%ND0.3
        atten=atten*0.58;
    end
    if any(ND_list==10) %ND1
        atten=atten*0.19;
    end
    if any(ND_list==11) %ND3
        atten=atten*0.0094;
    end
    if any(ND_list==12) %ND0.5
        atten=atten*0.4;
    end
    if any(ND_list==13) %ND5
        atten=atten*4.5783e-04;
    end
    if any(ND_list==14) %ND6
        atten=atten*4.2899e-04;
    end
    if any(ND_list==15) %ND0.5 calibrated at 480nm!
        atten=atten*0.3418;
    end
    if any(ND_list==16) %ND2 calibrated at 480nm!
        atten=atten*0.0072;
    end
    if strcmpi(laserName,'probe')
    maxPower=max(pwr)*atten*1e9;
    minPower=min(pwr)*atten*1e9;
    else
        maxPower=max(pwr)*atten*1e3;
        minPower=min(pwr)*atten*1e3;
    end
end
