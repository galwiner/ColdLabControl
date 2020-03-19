function PDReader(src,event,app)
    global p
    global inst
    historyLength=50;
%     if size(app.balancerDat,2)>10
%         app.balancerDat(:,1:end-1)=app.balancerDat(:,2:end);
        hold(app.balancerAxes,'off')
        
%     else
        reading=inst.com.readMemoryBlock(1101,3);
        app.balancerDat(:,historyLength)=reading';
        app.balancerDat(:,1:end-1)=app.balancerDat(:,2:end);
%     end
    plot(app.balancerAxes,app.balancerDat(1,:),'ko-');
    hold(app.balancerAxes,'on')
    plot(app.balancerAxes,app.balancerDat(2,:),'ro-');
    plot(app.balancerAxes,app.balancerDat(3,:),'go-');
    dat=[app.balancerDat(3,2:end) app.balancerDat(2,2:end) app.balancerDat(1,2:end)];
    minval=min(dat);
    if size(minval)>1
        minval=minval(1);
    end
    maxval=max(dat);
    if size(maxval)>1
        maxval=maxval(1);
    end
    if maxval==minval
        minval=0;
        maxval=100;
    end
    
    ylim(app.balancerAxes,[0.9*minval 1.1*maxval])
    app.powerwhiteEditField.Value=app.balancerDat(1,end);
    app.powerredEditField.Value=app.balancerDat(2,end);
    app.powergreenEditField.Value=app.balancerDat(3,end);
    
    
    
end
