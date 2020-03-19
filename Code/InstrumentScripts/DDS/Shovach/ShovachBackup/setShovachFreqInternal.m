function [  ] = setFreqInternal(obj,chan,fout,offset_phase,Adb)
if strcmpi(obj.s.Status,'closed')
    fopen(obj.s);
end

switch chan
    case 1
%         SHOVACH_INIT_1(obj,0,1,1);
        SHO_profile0_A(obj,fout,offset_phase,Adb)
    case 2
%         SHOVACH_INIT_2(obj,0,1,1);
        SHO_profile0_B(obj,fout,offset_phase,Adb)
    case 3
%         SHOVACH_INIT_3(obj,0,1,1);
        SHO_profile0_C(obj,fout,offset_phase,Adb)
    case 4
%         SHOVACH_INIT_4(obj,0,1,1);
        SHO_profile0_D(obj,fout,offset_phase,Adb)
        


disp('DDS: Freq set success')


end

