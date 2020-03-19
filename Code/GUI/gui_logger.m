function gui_logger(app,message)
      

    app.LogBox.Items = [app.LogBox.Items,sprintf([datestr(datetime('now')) '\t' message])]; 
    scroll(app.LogBox,'bottom');

    logfile = fopen([getTodaysFolder '\gui_log.log'],'a+');

    strings=app.LogBox.Items;
    fprintf(logfile,'%s\n',strings{:});
    fclose(logfile);
end
