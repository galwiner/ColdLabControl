function [  ] = Rubidium_CLOCK_INIT(obj,clock)


% s3 = serial(obj.comport,'BaudRate',9600,'DataBits',8);
  
% fopen(s3);

 pause(1000e-3); 


clock_ref='00';



if clock==1
       
clock_ref='FF';

end

clock_ref=hex2dec(clock_ref);

fwrite(obj.s,'I');

fwrite(obj.s,clock_ref);

%%%   %%%%   %%%%


%  fclose(s3);




end

