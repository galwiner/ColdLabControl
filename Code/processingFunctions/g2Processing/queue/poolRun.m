%this script demonstrates the use of a parallel pool to run background
%tasks

% First define a parallel pool 
clear all
a=gcp('nocreate');
if ~a.Connected
    poolobj = parpool('local',4);
end
% then create a data queue
q = parallel.pool.DataQueue;
% create a listener on that queue
listener = afterEach(q, @testevent);

% and start the data processing (note that the queue must be passed)
% data=linspace(1,10);
for idx=1:10
f(idx)= parfeval(@testfun, 0, 1e9, q);
end

listener2=afterAll(f,@donefunc,0);

