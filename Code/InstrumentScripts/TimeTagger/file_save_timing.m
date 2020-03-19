sizes=[1e3,1e6,1e7];
bytes=[];
% sizes=[1e3,1e4];
t=[];
for ind=1:length(sizes)
    dat=rand(2,sizes(ind));
    
    for jnd=1:1
    fname=['temp' num2str(ind) '.mat'];

    tic
    save(fname,'dat');
    t(ind)=toc;
    s=dir(fname)
    bytes(ind)=s.bytes;
    delete(fname);
    end
end

figure;
yyaxis left
plot(sizes,t)
yyaxis right
plot(sizes,bytes/1e6)

delete('myfile.h5')
h5create('myfile.h5','/tt',[2,Inf],'ChunkSize',[2,1e6])
dat=rand(2,8e6);
start=[1 1];
count=[2 8e6];
tic
h5write('myfile.h5','/tt',dat,start,count)
h5write('myfile.h5','/tt',dat,[1 8e6+1],count)
toc
h5disp('myfile.h5');
tic
data = h5read('myfile.h5','/tt');
toc
