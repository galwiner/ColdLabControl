function [  ] = setFreqInternal(obj,chan,fout,offset_phase,Adb)
global p;
if strcmpi(obj.s.Status,'closed')
    fopen(obj.s);
end

switch chan
    case 1
        if ~strcmpi(obj.state(1),'single')
            SHO_profile0_A(obj,fout,offset_phase,Adb)
            SHOVACH_INIT_1(obj,0,1,1);
            obj.state(1) = 'single';
        else
        SHO_profile0_A(obj,fout,offset_phase,Adb)
        end
    case 2
        if ~strcmpi(obj.state(2),'single')
           SHO_profile0_B(obj,fout,offset_phase,Adb)
           SHOVACH_INIT_2(obj,0,1,1);
           obj.state(2) = 'single';
        else
        SHO_profile0_B(obj,fout,offset_phase,Adb)
        end
    case 3
        if ~strcmpi(obj.state(3),'single')
            SHO_profile0_C(obj,fout,offset_phase,Adb)
            SHOVACH_INIT_3(obj,0,1,1);
           obj.state(3) = 'single';
        else
            SHO_profile0_C(obj,fout,offset_phase,Adb)
        end
    case 4
        if ~strcmpi(obj.state(4),'single')
           SHO_profile0_D(obj,fout,offset_phase,Adb)
           SHOVACH_INIT_4(obj,0,1,1);
           obj.state(4) = 'single';
        else
        SHO_profile0_D(obj,fout,offset_phase,Adb)
        end
end
if ~isfield(p,'holdFreqPrint')
fprintf('DDS Channel %0.0d: Freq set to %0.2f\n',chan,fout)
end

end

