function wlmReader(src,event,app)

    try
        
        dat=getWLMFreq();
        if all(app.WLMreadingLamp.Color==[0     1     0])
            app.WLMreadingLamp.Color=[0.94 0.94 0.94];
        else 
            app.WLMreadingLamp.Color='g';
        end
        app.Ch1EditField.Value=dat(1);
        app.Ch2EditField.Value=dat(2);
        app.Ch3EditField.Value=dat(3);
        app.Ch4EditField.Value=dat(4);
        app.Ch5EditField.Value=dat(5);
        app.Ch6EditField.Value=dat(6);
        app.Ch7EditField.Value=dat(7);
        app.Ch8EditField.Value=dat(8);
        app.masterlockedLamp.Color=[0.94 0.94 0.94];
        if app.masterlockalarmCheckBox.Value==1 && (dat(1)-384.22916)>2e-5
            app.masterlockedLamp.Color='r';
            sound(audioread('tng_red_alert1.wav'));
            pause(1)
            sound(audioread('tng_red_alert1.wav'));
            pause(1)
            sound(audioread('tng_red_alert1.wav'));
            
            app.masterlockalarmCheckBox.Value=0;  %to avoid an annoying endless repeat
            app.masteralarmLamp.Color='r';
            gui_logger(app,'MASTER LOST LOCK!');
        elseif app.masterlockalarmCheckBox.Value==1
            app.masterlockedLamp.Color='g';
        end
        
    catch err
        gui_logger(app,'WLM read error')
    end
    
        
end
