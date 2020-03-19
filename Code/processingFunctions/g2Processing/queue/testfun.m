function testfun(data,q)
    % process the data here
    dataprocessed=mean(rand(1,data));
    
    send(q,dataprocessed)
end