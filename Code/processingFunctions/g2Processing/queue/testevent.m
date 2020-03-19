function testevent(dataprocessed)
	fprintf('%.2f\n',dataprocessed);
    filename=['name' num2str(ceil(rand(1)*100000)) '.mat'];
    save(filename,'dataprocessed');
    
    