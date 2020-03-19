classdef BiasPSU < handle
    %BIASPSU keysight psu driving the mot bias coils (Agilent B2962A)
    
    
    properties
        conn
        resourcename
        easyname %human readble name
    end
    
    methods
        function obj = BiasPSU(resourcename,easyname)
            
            if nargin==1
                obj.easyname=resourcename;
            else
                obj.easyname=easyname;
            end
            
            
            obj.resourcename=resourcename;
            obj.conn = visa('agilent',obj.resourcename);
            if strcmp(resourcename,'TCPIP::10.10.10.106::inst0::INSTR')
                visaname='VISA-TCPIP-0-10.10.10.106-inst0';
            elseif strcmp(resourcename,'TCPIP::10.10.10.107::inst0::INSTR')
                visaname='VISA-TCPIP-0-10.10.10.107-inst0';
            else
                visaname=resourcename;
            end
            devices=instrfind('Name',visaname); %This gets all the serial objects with the correct name
            if isempty(devices)
                obj.conn = visa('agilent',obj.resourcename);
                obj.conn.OutputBufferSize=2^18;
                fopen(obj.conn);
                %                 devices=instrfind('Name',visaname); %This gets all the serial objects with correct name
                
            else
                fopen(obj.conn);
            end
            
            %             if ~any(strcmpi(devices.Status,'open')) %Check if there is an open serial connection for comport.
            %                 try
            %                     obj.conn=visa('agilent',obj.resourcename);
            %                     fopen(obj.conn);
            %                 catch err
            %                     error(err.identifier,'Error while opening connection to bias PSU.\n %s,',err.message);
            %                 end
            %             else %if there is an open serial connection, set the serial object to be that of the open one.
            %                obj.conn=devices(find(strcmpi(devices.Status,'open')));
            %             end
            
            fprintf(obj.conn, sprintf(':SOURce1:FUNCtion:MODE %s', 'CURRent'));
            fprintf(obj.conn, sprintf(':SOURce2:FUNCtion:MODE %s', 'CURRent'));
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', 1,20));
            %             fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', 2,200));
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', 2,20));
        end
        
        function setVoltage(obj,chan,volt)
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,'volt'));
            fprintf(obj.conn, sprintf(':SOURce%d:volt:LEVel:IMMediate:AMPLitude %g',chan,volt));
        end
        
        function setCurrent(obj,chan,current)
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,'CURRent'));
            fprintf(obj.conn, sprintf(':SOURce%d:CURRent:LEVel:IMMediate:AMPLitude %g',chan,current));
        end
        function res=getCurrent(obj,chan)
            res=query(obj.conn,sprintf(':SOURce%d:CURRent?',chan));
            res=str2double(res);
        end
        function resetPSU(obj)
            fprintf(obj.conn, sprintf('*RST'));
        end
        
        function setOutput(obj,chan,mode)
            %turns output on/off
            if ~mode==1 && ~mode==0
                error('mode should only be 1 or 0');
            end
            fprintf(obj.conn, sprintf(':OUTPut%d:STATe %d',chan,mode));
        end
        
        function setVoltageLimit(obj,chan,limit)
            fprintf(obj.conn, sprintf(':SENSe%d:VOLTage:DC:PROTection:LEVel:BOTH %g', chan,limit));
        end
        function setHWPinAsTrigger(obj,pin)
            fprintf(obj.conn, sprintf(':SOURCE:DIG:EXT%d:FUNC TINP',pin));
            fprintf(obj.conn, sprintf(':SOURCE:DIG:EXT%d:POL POS'));
        end
        
        function setSquare(obj,chan,voltOrCurr,params)
            %voltOtCurr is a string. either volt or curr. 
            %parms =[startLevel,topLevel,topTime,endTime,repetitions]
            %startLevel [V], topLevel[V],topTime [uS] - delay before start
            %of box. endTime [uS] duration after the box
            %param(5) - repetition number
            fprintf(obj.conn, ':abort:all (@1,2)');
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,voltOrCurr));
%             fprintf(obj.conn, sprintf(':SENS%d:%s:PROT %f',chan,voltOrCurr,params(2)));
            fprintf(obj.conn, sprintf(':sour%d:%s:mode arb',chan,voltOrCurr));
            fprintf(obj.conn, sprintf(':sour%d:arb:func squ',chan));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:squ:STAR %f',chan,voltOrCurr,params(1)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:squ:TOP %f',chan,voltOrCurr,params(2)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:squ:TOP:TIME %f',chan,voltOrCurr,params(3)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:squ:END:TIME %f',chan,voltOrCurr,params(4)));
%             fprintf(obj.conn, sprintf(':sour%d:arb:%s:squ:end:time %f',chan,voltOrCurr,params(5)));
            if isnumeric(params(5))
            fprintf(obj.conn, sprintf(':sour%d:arb:count %d',chan,params(5)));
            elseif strcmpi(params(5),'inf')
                fprintf(obj.conn, sprintf(':sour%d:arb:count inf',chan));
            else 
                error('bad option in B2961 set trigger count');
            end
        end        
        function setRamp(obj,chan,voltOrCurr,params)
            %voltOtCurr is a string. either volt or curr. 
            %parms =[startLevel,endLevel,startTime,rampTime,endTime,repetitions]
            %startLevel [V], endLevel[V],startTime [s] - delay before start
            %of ramp. rampTime [s] duration of the ramp itself
            fprintf(obj.conn, ':abort:all (@1,2)');
            pause(0.5);
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,voltOrCurr));
%             fprintf(obj.conn, sprintf(':SENS%d:%s:PROT %f',chan,voltOrCurr,params(2)));
            fprintf(obj.conn, sprintf(':sour%d:%s:mode arb',chan,voltOrCurr));
            fprintf(obj.conn, sprintf(':sour%d:arb:func ramp',chan));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:ramp:STAR %f',chan,voltOrCurr,params(1)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:ramp:END %f',chan,voltOrCurr,params(2)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:ramp:STAR:TIME %f',chan,voltOrCurr,params(3)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:ramp:rtim %f',chan,voltOrCurr,params(4)));
            fprintf(obj.conn, sprintf(':sour%d:arb:%s:ramp:end:time %f',chan,voltOrCurr,params(5)));
            if isnumeric(params(6))
            fprintf(obj.conn, sprintf(':sour%d:arb:count %d',chan,params(6)));
            elseif strcmpi(params(6),'inf')
                fprintf(obj.conn, sprintf(':sour%d:arb:count inf',chan));
            else 
                error('bad option in B2961 set trigger count');
            end
        end      
        function abortTrigger(obj)
        %this function aborts the currently set trigger. if this is not
        %done before a change, the change may fail. Because I don't check
        %errors on the device, we should call this function before each
        %change. 
            fprintf(obj.conn, ':abort:all (@1,2)');
        end   
        function setTriggerSource(obj,chan,source)
            %'aint' - auto 'ext1','ext2','ext3' - for external pins
            obj.abortTrigger()
            fprintf(obj.conn, sprintf(':trig%d:tran:sour %s',chan,source));
        end      
        function setTriggerCount(obj,chan,count)
            obj.abortTrigger()
            if isnumeric(count)
            fprintf(obj.conn, sprintf(':trig%d:tran:coun %d',chan,count));
            elseif strcmpi(count,'inf')
                fprintf(obj.conn, sprintf(':trig%d:tran:coun inf',chan));
            else 
                error('bad option in B2961 set trigger count');
            end
        end
        function setTriggerPeriod(obj,chan,period)
            obj.abortTrigger()
            %period in seconds
            fprintf(obj.conn, sprintf(':trig%d:tran:tim %f',chan,period));
        end
        function sendTrigger(obj)
            fprintf(obj.conn,':Trig:all:IMM (@1,2)');
        end        
        function initTrigger(obj,chan)
            %chan is 1 or 2 (if we don't want to trigger both for some
            %reason
            obj.abortTrigger()
            if nargin==1
                fprintf(obj.conn,':init:all (@1,2)\n');
            else
                fprintf(obj.conn,sprintf(':init:all (@%d)',chan));
            end
            pauseTime = 2e-1;
            pause(pauseTime);
           fprintf('BiasPSU: pausing for %0.2d S to init trigger\n',pauseTime);
        end    
        function setUserDefinedSignal(obj,chan,voltOrCurr,signal,timePerPoint)
            signal=num2str(signal,',%.5f');
            signal=signal(2:end);
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,voltOrCurr));
            fprintf(obj.conn, sprintf(':sour%d:%s:mode arb',chan,voltOrCurr));
            fprintf(obj.conn, sprintf(':sour%d:arb:func udef',chan));
            fprintf(obj.conn, sprintf(':source%d:arb:%s:UDEF:LEV %s',chan,voltOrCurr,signal));
            fprintf(obj.conn,sprintf(':source%d:arb:%s:UDEF:TIME %f',chan,voltOrCurr,timePerPoint));
        end     
        function configTriggedPulse(obj,startLevel,topLevel,duration)
            %this configures a pulse of the give duration with the given
            %level. it returns to the pre-pulse level when it completes.
            %it is triggered from Digital input 1
            
            fprintf(obj.conn,sprintf('ABORt:ALL'));
            fprintf(obj.conn,sprintf('sour:func:mode curr'));
            %             fprintf(obj.conn,sprintf('sour:func:mode volt'));
            %             fprintf(obj.conn,sprintf('sour:func:shap puls'));
            fprintf(obj.conn, sprintf(':sour%d:arb:count %d',1,1));

            fprintf(obj.conn,sprintf('sour:curr:mode arb'));
            fprintf(obj.conn,sprintf('sour:arb:func squ'));
            fprintf(obj.conn,sprintf('sour:arb:curr:SQUare:TOP:LEVel %f',topLevel));
            fprintf(obj.conn,sprintf('sour:arb:curr:SQUare:start:LEVel %f',startLevel));
            fprintf(obj.conn,sprintf('sour:arb:curr:SQUare:start:time 0.01'));
            fprintf(obj.conn,sprintf('sour:arb:curr:SQUare:end:time 0'));
            fprintf(obj.conn,sprintf('sour:arb:curr:SQUare:TOP:TIME %f',duration*1e-6));
            fprintf(obj.conn,sprintf('SOURce:CURRent:RANGe MAX'));
            fprintf(obj.conn,sprintf(':SOUR:WAIT OFF'));
            %             fprintf(obj.conn,sprintf('sour:curr:mode list'));
            %             fprintf(obj.conn,sprintf('sour:curr:mode arb'));
            %             fprintf(obj.conn,sprintf('sour:arb:func sin'));
            %             fprintf(obj.conn,sprintf('sour:arb:curr:sin:ampl %f',level));
            %             fprintf(obj.conn,sprintf('sour:arb:curr:sin:freq %f',freq));
            
            %             fprintf(obj.conn,sprintf('sour:list:curr %f',level));
            %             fprintf(obj.conn,sprintf('sour:puls:del 0')); %no delay from the trigger edge
            %             fprintf(obj.conn,sprintf('sour:puls:widt %f',duration*1e-6));
            %
            fprintf(obj.conn,sprintf('trig:tran:coun INF')); %digital input 1
            fprintf(obj.conn,sprintf('trig:tran:sour ext1')); %digital input 1
            %             fprintf(obj.conn,sprintf('trig:cout 1')); %trig one event on high level
            %             fprintf(obj.conn,sprintf('trig:cout 1'));
            
            fprintf(obj.conn,sprintf('init (@1)')); %initialize the trigger
            
        end
        function configTriggedDoublePulse(obj,chan,startLevel,topLevel,FirstDuration,SecondDuration)
            %this configures a double pulse with levels startLevel and
            %topLevel and durations FirstDuration SecondDuration
            %level. it returns to the pre-pulse level when it completes.
            %it is triggered from Digital input 1
            
            fprintf(obj.conn,sprintf(':abort:all (@1,2)'));
            fprintf(obj.conn,sprintf('sour%d:func:mode curr',chan));
            fprintf(obj.conn, sprintf(':sour%d:arb:count %d',chan,1));
            fprintf(obj.conn,sprintf('sour%d:curr:mode arb',chan));
            fprintf(obj.conn,sprintf('sour%d:arb:func squ',chan));
            fprintf(obj.conn,sprintf('sour%d:arb:curr:SQUare:TOP:LEVel %f',chan,topLevel));
            fprintf(obj.conn,sprintf('sour%d:arb:curr:SQUare:start:LEVel %f',chan,startLevel));
            fprintf(obj.conn,sprintf('sour%d:arb:curr:SQUare:start:time %f',chan,FirstDuration*1e-6));
            fprintf(obj.conn,sprintf('sour%d:arb:curr:SQUare:end:time 0',chan));
            fprintf(obj.conn,sprintf('sour%d:arb:curr:SQUare:TOP:TIME %f',chan,SecondDuration*1e-6));
            fprintf(obj.conn,sprintf('SOURce%d:CURRent:RANGe MAX',chan));
            fprintf(obj.conn,sprintf(':SOUR%d:WAIT OFF',chan));
%             fprintf(obj.conn,sprintf('trig:tran:coun INF')); %digital input 1
%             fprintf(obj.conn,sprintf('trig:tran:sour ext1')); %digital input 1
%             fprintf(obj.conn,sprintf('init (@1)')); %initialize the trigger
            
        end
        function configTriggedPulse2(obj,chan,currOrVolt,startLevel,topLevel,duration)
            %this configures a pulse of the give duration with the given
            %level. it returns to the pre-pulse level when it completes.
            %it is triggered from Digital input 1
%             fprintf(obj.conn,sprintf('ABORt:ALL'));
            fprintf(obj.conn, sprintf(':SOURce%d:FUNCtion:MODE %s',chan,currOrVolt))
%             fprintf(obj.conn,sprintf(':sour%d:func:mode %s',chan,currOrVolt));
%             fprintf(obj.conn,sprintf('sour%d:%s:mode arb',currOrVolt));
%             fprintf(obj.conn,sprintf('sour%d:arb:func squ',chan));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:start 0.01',chan,currOrVolt));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:TOP %f',chan,topLevel));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:start:LEVel %f',chan,currOrVolt,startLevel));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:start:time 0.01',chan,currOrVolt));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:end:time 0',chan,currOrVolt));
%             fprintf(obj.conn,sprintf('sour%d:arb:%s:SQUare:TOP:TIME %f',chan,currOrVolt,duration*1e-6));
%             fprintf(obj.conn,sprintf('SOURce%d:%s:RANGe MAX',chan,currOrVolt));
%             fprintf(obj.conn,sprintf(':SOUR%d:WAIT OFF',chan));
            %             fprintf(obj.conn,sprintf('sour:curr:mode list'));
            %             fprintf(obj.conn,sprintf('sour:curr:mode arb'));
            %             fprintf(obj.conn,sprintf('sour:arb:func sin'));
            %             fprintf(obj.conn,sprintf('sour:arb:curr:sin:ampl %f',level));
            %             fprintf(obj.conn,sprintf('sour:arb:curr:sin:freq %f',freq));
            
            %             fprintf(obj.conn,sprintf('sour:list:curr %f',level));
            %             fprintf(obj.conn,sprintf('sour:puls:del 0')); %no delay from the trigger edge
            %             fprintf(obj.conn,sprintf('sour:puls:widt %f',duration*1e-6));
            %
%             fprintf(obj.conn,sprintf('trig:tran:coun INF')); %digital input 1
%             fprintf(obj.conn,sprintf('trig:tran:sour ext1')); %digital input 1
            %             fprintf(obj.conn,sprintf('trig:cout 1')); %trig one event on high level
            %             fprintf(obj.conn,sprintf('trig:cout 1'));
            
%             fprintf(obj.conn,sprintf('init (@1)')); %initialize the trigger
            
        end
        function setTriggedRamp(obj,chan,startVoltage,endVoltage,rampTime)
            fprintf(obj.conn,sprintf(':sour1:volt:mode:arb'));
            fprintf(obj.conn,sprintf(':sour1:func:func sin'));
            fprintf(obj.conn,sprintf(':sour1:arb:volt:sin:ampl 5'));
            fprintf(obj.conn,sprintf(':sour1:arb:volt:sin:offs 0'));
            fprintf(obj.conn,sprintf(':sour1:arb:volt:sin:freq 100'));
            fprintf(obj.conn,sprintf(':outp1 on'));
            %
            %             fprintf(obj.conn,sprintf('ABORt:ALL'));
            %             fprintf(obj.conn,sprintf('sour:func:mode curr'));
            %             fprintf(obj.conn,sprintf('sour:curr:mode arb'));
            %             fprintf(obj.conn,sprintf('trig:tran:coun INF')); %digital input 1
            %             fprintf(obj.conn,sprintf('trig:tran:sour ext1')); %digital input 1
            %             fprintf(obj.conn,sprintf('init (@1)')); %initialize the trigger
        end       
        function delete(obj)
%             obj.resetPSU
            fclose(obj.conn);
            fprintf('connection closed %s \n',obj.resourcename);
        end
        
        
        
    end
end

