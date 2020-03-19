function updateICEStatus(app)
    global inst
    coolingTempLock=inst.Lasers('cooling').getTempLockStat;
    repumpTempLock=inst.Lasers('cooling').getTempLockStat;
    if coolingTempLock
        app.coolingtemplockLamp.Color='g';
        app.coolingemissionButton.Enable=true;
    else 
        app.coolingtemplockLamp.Color='r';
    end
    if repumpTempLock
        app.repumptemplockLamp.Color='g';
        app.repumpemissionButton.Enable=true;
    else 
        app.repumptemplockLamp.Color='r';
    end
       
    
    
end
