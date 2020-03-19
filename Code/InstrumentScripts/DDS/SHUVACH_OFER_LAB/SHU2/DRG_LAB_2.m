function [  ] = DRG_LAB_2(UP_FREQUENCY,DOWN_FREQUENCY,dtP,dtN,dfP,dfN)
% [[MHz], [MHz], timesteps_upramp [sec], timesteps_downramp [sec],freqstep_upramp [Hz],freqstep_downramp [Hz]
s3 = serial('COM16','BaudRate',9600,'DataBits',8);
fopen(s3);
fsys=1000;
DRG_LIMITS_UP=(2^32)*(UP_FREQUENCY)/(fsys);
DRG_LIMITS_DOWN=round((2^32)*(DOWN_FREQUENCY)/(fsys));
   up=dec2binvec(DRG_LIMITS_UP,32);
   down=dec2binvec(DRG_LIMITS_DOWN,32);
   fsys_timing=1000e6;
   Mi=dec2binvec(dfP*2^32/fsys_timing,32);
   Md=dec2binvec(dfN*2^32/fsys_timing,32);
%    m=dfN*2^32/fsys
   fsys_timing=1000e6;
   i= (dtP*fsys/4);
   PtP=dec2binvec(dtP*fsys_timing/4,16);
   PtM=dec2binvec(dtN*fsys_timing/4,16);
  
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%RAMP-LIMITS%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   p1=up(25:32);
   %a1=flip(a1)
   DRG_56_63_up=binvec2dec(p1);
   
   p2=up(17:24);
   %a1=flip(a1)
   DRG_48_55_up=binvec2dec(p2);
   
   p3=up(9: 16);
   %a1=flip(a1)
   DRG_40_47_up=binvec2dec(p3);
   
   p4=up(1:8);
   %a1=flip(a1)
   DRG_32_39_up=binvec2dec(p4);
   
   
   p5=down(25:32);
   %a1=flip(a1)
   DRG_24_31_down=binvec2dec(p5);
   
   p6=down(17:24);
   %a1=flip(a1)
   DRG_16_23_down=binvec2dec(p6);
   
   p7=down(9: 16);
   %a1=flip(a1)
   DRG_8_15_down=binvec2dec(p7);
   
   p8=down(1:8);
   %a1=flip(a1)
   DRG_0_7_down=binvec2dec(p8);
   
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%RAMP-STEP%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   f1=Md(25:32);
   DRG_56_63_dfN=binvec2dec(f1);
   f2=Md(17:24);
   
   DRG_48_55_dfN=binvec2dec(f2);
   
   f3=Md(9: 16);
   %a1=flip(a1)
   DRG_40_47_dfN=binvec2dec(f3);
   
   f4=Md(1:8);
   %a1=flip(a1)
   DRG_32_39_dfN=binvec2dec(f4);
   
   
   f5=Mi(25:32);
   %a1=flip(a1)
   DRG_24_31_dfP=binvec2dec(f5);
   
   f6=Mi(17:24);
   %a1=flip(a1)
   DRG_16_23_dfP=binvec2dec(f6);
   
   f7=Mi(9: 16);
   %a1=flip(a1)
   DRG_8_15_dfP=binvec2dec(f7);
   
   f8=Mi(1:8);
   %a1=flip(a1)
   DRG_0_7_dfP=binvec2dec(f8);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%RAMP-RATE%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   t1=PtM(9: 16);
   DRG_24_31_dtM=binvec2dec(t1);
   t2=PtM(1:8);
   %a1=flip(a1)
   DRG_16_23_dtM=binvec2dec(t2);
   
   t3=PtP(9: 16);
   %a1=flip(a1)
   DRG_8_15_dtP=binvec2dec(t3);
   
   t4=PtP(1:8);
   %a1=flip(a1)
   DRG_0_7_dtP=binvec2dec(t4);
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   

fwrite(s3,'m');
  
DRG_Limit=bin2dec('00001011');
 
fwrite(s3,DRG_Limit);

fwrite(s3,DRG_56_63_up);

fwrite(s3,DRG_48_55_up ) ;

fwrite(s3,DRG_40_47_up );
 
fwrite(s3,DRG_32_39_up );

fwrite(s3,DRG_24_31_down);

fwrite(s3,DRG_16_23_down) ;

fwrite(s3,DRG_8_15_down);
 
fwrite(s3,DRG_0_7_down);
% 
% %    
% 
% DRG_56_63_dec='00';
% DRG_48_55_dec='5D';
% DRG_40_47_dec='9F';
% DRG_32_39_dec='73';
% 
% DRG_24_31_inc='00';
% DRG_16_23_inc='5D';
% DRG_8_15_inc='9F';
% DRG_0_7_inc='73';
% 
% pause(1000e-6); 
% fwrite(s3,'m');
%  

DRG_Step_Size=bin2dec('00001100');
 
fwrite(s3,DRG_Step_Size);

fwrite(s3,DRG_56_63_dfN );

fwrite(s3,DRG_48_55_dfN ) ;

fwrite(s3,DRG_40_47_dfN );
 
fwrite(s3,DRG_32_39_dfN );

fwrite(s3,DRG_24_31_dfP);

fwrite(s3,DRG_16_23_dfP) ;

fwrite(s3,DRG_8_15_dfP);
 
fwrite(s3,DRG_0_7_dfP);

% 
% %    
% 
% 
% DRG_24_31_Pslope='44';
% DRG_16_23_Pslope='5C';
% DRG_8_15_Pslope='44';
% DRG_0_7_Pslope='5C';
% 
% pause(1000e-6); 
% fwrite(s3,'n');
% 

DRG_Ramp_Rate=bin2dec('00001101');
 
fwrite(s3,DRG_Ramp_Rate);

fwrite(s3,DRG_24_31_dtM);

fwrite(s3,DRG_16_23_dtM) ;

fwrite(s3,DRG_8_15_dtP);
 
fwrite(s3,DRG_0_7_dtP);


%    
fclose(s3); 
% % 
% 
% 
 end
% 

