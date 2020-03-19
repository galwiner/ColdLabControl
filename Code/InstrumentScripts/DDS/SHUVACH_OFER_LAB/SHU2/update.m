function [  ] = update()
 


s3 = serial('COM6','BaudRate',115200,'DataBits',8)
fopen(s3)


fwrite(s3,'Q');
  
fclose(s3) 




end


