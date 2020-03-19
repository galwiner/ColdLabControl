function [  ] = Rubidium_CLOCK_2017(clock)


s3 = serial('COM16','BaudRate',9600,'DataBits',8);
  
fopen(s3);

 pause(1000e-3); 


clock_ref='00';



if clock==1
       
clock_ref='FF';

end

clock_ref=hex2dec(clock_ref);

fwrite(s3,'I');

fwrite(s3,clock_ref);

%%%   %%%%   %%%%


 fclose(s3);




end

