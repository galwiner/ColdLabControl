function binFileToMatQueue(filename,queue)
    
    send(queue,binFileToMat(filename));
end
