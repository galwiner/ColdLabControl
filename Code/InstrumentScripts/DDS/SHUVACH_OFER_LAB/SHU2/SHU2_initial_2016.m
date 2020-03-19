
function [ output_args ] = SHU2_initial_2016(DRG,Singlemode,REF1)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

s3 = serial('COM16','BaudRate',9600,'DataBits',8);
  
fopen(s3);

 pause(1000e-3); 

cfr2_0_7='80';
cfr2_16_23='40';
cfr1_8_15='00'; 

 if (DRG==1)
        
     cfr2_16_23='48';      
 end

  
 
tt=Singlemode;
    
cfr1_24_31='00';
cfr1_16_23='00';
cfr1_8_15='20';
cfr1_0_7='02';

cfr2_24_31='01';
%%cfr2_16_23='40';
cfr2_8_15='08';
%%cfr2_0_7='00';

cfr3_24_31= '2D';
cfr3_16_23='3F';
cfr3_8_15='C1';
cfr3_0_7='C8';

io_update_24_31='00';
io_update_16_23='00';
io_update_8_15='00';
io_update_0_7='02';

Dac_24_31='00';
Dac_16_23='00';
Dac_8_15='00';
Dac_0_7='FF';


SYNC_24_31='00';  %% SYNC Recieve ON ,Transmit OFF
SYNC_16_23='00';
SYNC_8_15='00';
SYNC_0_7='00';


ASF_24_31='FF';
ASF_16_23='FF';
ASF_8_15='FF';
ASF_0_7='7F';


REF='FF';
CONTROL='FF';


if REF1==1
       
REF='00';
CONTROL='00';
end

REF=hex2dec(REF);
CONTROL=hex2dec(CONTROL);


% cfr1(cfr1_24_31,cfr1_16_23,cfr1_8_15,cfr1_0_7)
% cfr2(cfr2_24_31,cfr2_16_23,cfr2_8_15,cfr2_0_7);
% cfr3(cfr3_24_31,cfr3_16_23,cfr3_8_15,cfr3_0_7);
% dac( dac_24_31,dac_16_23,dac_8_15,dac_0_7 );
% io_update(io_update_24_31,io_update_16_23,io_update_8_15,io_update_0_7 );




cfr1_address=bin2dec('00000000');

cfr1_24_31=hex2dec(cfr1_24_31);
cfr1_16_23=hex2dec(cfr1_16_23);
cfr1_8_15=hex2dec(cfr1_8_15);
cfr1_0_7=hex2dec(cfr1_0_7);

cfr2_address=bin2dec(' 00000001');

cfr2_24_31=hex2dec(cfr2_24_31);
cfr2_16_23=hex2dec(cfr2_16_23);
cfr2_8_15=hex2dec(cfr2_8_15);
cfr2_0_7=hex2dec(cfr2_0_7);

cfr3_address=bin2dec('00000010');

cfr3_24_31=hex2dec(cfr3_24_31);
cfr3_16_23=hex2dec(cfr3_16_23);
cfr3_8_15=hex2dec(cfr3_8_15);
cfr3_0_7=hex2dec(cfr3_0_7);



fwrite(s3,'B');
fwrite(s3,cfr1_address);
fwrite(s3,cfr1_24_31);

fwrite(s3,cfr1_16_23);
fwrite(s3,cfr1_8_15);
 
fwrite(s3,cfr1_0_7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fwrite(s3,cfr2_address);

fwrite(s3,cfr2_24_31);

fwrite(s3,cfr2_16_23);

fwrite(s3,cfr2_8_15);

fwrite(s3,cfr2_0_7);
% %  
% 
fwrite(s3,cfr3_address);
fwrite(s3,cfr3_24_31);
fwrite(s3,cfr3_16_23);
fwrite(s3,cfr3_8_15);
fwrite(s3,cfr3_0_7);
% 
% 

io_update_address=bin2dec('00000100');

io_update_24_31=hex2dec(io_update_24_31);
io_update_16_23=hex2dec(io_update_16_23);
io_update_8_15=hex2dec(io_update_8_15);
io_update_0_7=hex2dec(io_update_0_7);


fwrite(s3,io_update_address);
fwrite(s3,io_update_24_31);
fwrite(s3,io_update_16_23);
fwrite(s3,io_update_8_15);
fwrite(s3,io_update_0_7);

Dac_address=bin2dec('00000011');

Dac_24_31=hex2dec(Dac_24_31);
Dac_16_23=hex2dec(Dac_16_23);
Dac_8_15=hex2dec(Dac_8_15);
Dac_0_7=hex2dec(Dac_0_7);

fwrite(s3,Dac_address);
fwrite(s3,Dac_24_31);
fwrite(s3,Dac_16_23);
fwrite(s3,Dac_8_15);
fwrite(s3,Dac_0_7);

% 
ASF_address=bin2dec('00001001');

ASF_24_31=hex2dec(ASF_24_31);
ASF_16_23=hex2dec(ASF_16_23);
ASF_8_15=hex2dec(ASF_8_15);
ASF_0_7=hex2dec(ASF_0_7);

fwrite(s3,ASF_address);
fwrite(s3,ASF_24_31);
fwrite(s3,ASF_16_23);
fwrite(s3,ASF_8_15);

fwrite(s3,ASF_0_7);

SYNC_address=bin2dec('00001010');

SYNC_24_31=hex2dec(SYNC_24_31);
SYNC_16_23=hex2dec(SYNC_16_23);
SYNC_8_15=hex2dec(SYNC_8_15);
SYNC_0_7=hex2dec(SYNC_0_7);

fwrite(s3,SYNC_address);
fwrite(s3,SYNC_24_31);
fwrite(s3,SYNC_16_23);
fwrite(s3,SYNC_8_15);
fwrite(s3,SYNC_0_7);


fwrite(s3,REF);
fwrite(s3,CONTROL);
%%%   %%%%   %%%%


fclose(s3);


end

