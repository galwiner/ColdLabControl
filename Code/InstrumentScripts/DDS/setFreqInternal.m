function [  ] = setFreqInternal(obj,fout,offset_phase,Adb)





obj.s = serial(obj.comport,'BaudRate',9600,'DataBits',8);
fopen(obj.s);
%   pause(1000e-3);
%    fout=100;
fsys=1000;
FTW=round((2^32)*(fout)/(fsys));
POW=(offset_phase*2^16)/360;
ASF=round((2^14-1)*10^(Adb/20));

c=dec2binvec(ASF,16);
b=dec2binvec(POW,16);
a=dec2binvec(FTW,32);



p1=c(9:16);
x1=binvec2dec(p1);
p2=c(1:8);
x2=binvec2dec(p2);

p3=b(9:16);
x3=binvec2dec(p3);
p4=b(1:8);
x4=binvec2dec(p4);



p5=a(25:32);
x5=binvec2dec(p5)

p6=a(17:24);
x6=binvec2dec(p6);

p7=a(9: 16);
x7=binvec2dec(p7);

p8=a(1:8);
x8=binvec2dec(p8)



fwrite(obj.s,'s');

profile0=bin2dec('00001110');
%pause(1e-3);
fwrite(obj.s,profile0);

fwrite(obj.s,x1);

fwrite(obj.s,x2) ;

fwrite(obj.s,x3);

fwrite(obj.s,x4);

fwrite(obj.s,x5);

fwrite(obj.s,x6) ;

fwrite(obj.s,x7);

fwrite(obj.s,x8);

%
fclose(obj.s) ;

disp('DDS: Freq set success')


end

