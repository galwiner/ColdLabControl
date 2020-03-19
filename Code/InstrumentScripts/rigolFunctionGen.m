classdef rigolFunctionGen < handle
    
    
    properties
        IP
        conn
    end
    
    methods
        function obj = rigolFunctionGen(ip)
            if nargin==0
                ip='10.10.10.123';
            end
            obj.IP=ip;
            obj.conn = visa('ni',['TCPIP0::' ip '::INSTR']);
            fopen(obj.conn);

        end
        function setOutput(obj,chan,state)
            if state==1
                state='ON';
            else 
                state='OFF';
            end
            fprintf(obj.conn,[':outp' num2str(chan) ' ' state]);
        end
        
        function setModulatedSinWave(obj,chan,DCval,modulationAmp,freq)
            fprintf(obj.conn,[':SOUR' num2str(chan) ':FUNC SIN']);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':FREQ ' num2str(freq)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':VOLT ' num2str(modulationAmp)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':VOLT:OFFS ' num2str(DCval)]);
            fprintf(obj.conn,[':outp' num2str(chan) ' ON']);
        end
        function setSinOutput(obj,chan,amp,offset,freq,phase)
            fprintf(obj.conn,[':SOUR' num2str(chan) ':FUNC SIN']);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':FREQ ' num2str(freq)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':VOLT ' num2str(amp)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':VOLT:OFFS ' num2str(offset)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':phase ' num2str(phase)]);
            fprintf(obj.conn,[':outp' num2str(chan) ' ON']);
        end
        function alignPhase(obj)
            fprintf(obj.conn,':SOUR1:PHASE:INIT');
            fprintf(obj.conn,':SOUR2:PHASE:INIT');
            fprintf(obj.conn,':SOUR1:PHASE:SYN');
            fprintf(obj.conn,':SOUR2:PHASE:SYN');
        end
        
        function setSinAntiphase(obj,amp,offset,freq)
           obj.setSinOutput(1,amp,offset,freq,0);
           pause(0.5);
           obj.setSinOutput(2,amp,offset,freq,180);   
           pause(0.5);
           obj.alignPhase
           
        end
        function setTTLSquareWave(obj,freq)
        
            fprintf(obj.conn,':SOUR1:FUNC SQU');
            fprintf(obj.conn,[':SOUR1:FREQ ' num2str(freq)]);
            fprintf(obj.conn,':SOUR1:VOLT 5');
            fprintf(obj.conn,':SOUR1:VOLT:OFFS 2.5');
            fprintf(obj.conn,':outp1 ON');
            
            
        end
        
        function applyDCTTL(obj,state)
            fprintf(obj.conn,[':SOUR1:APPL:DC 1,' num2str(state) ',5']);
            if state==1
            fprintf(obj.conn,':outp1 ON');
            else
                fprintf(obj.conn,':outp1 OFF');
            end
        end
        
        function applyDC(obj,chan,offset)
            fprintf(obj.conn,[':SOUR' num2str(chan) ':APPL:DC 1,1,' num2str(offset)]);
            fprintf(obj.conn,[':outp' num2str(chan) 'ON']);
        end
        function pol = getPolarity(obj,chan)
           %returns the polarity of the gate of channel chan
           if chan ~= 1 && chan ~= 2
               error('chan must be 1 or 2')
           end
           pol = query(obj.conn,[':OUTPut' num2str(chan) ':GAT:POL?']);
           pol(end) = [];
        end
        function pol = setPolarity(obj,chan,polarity)
            %sets the polarity of the gate of channel 'chan' to be
            %'polarity'
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            if strcmpi(polarity,'pos')~=1 && strcmpi(polarity,'POSitive')~=1 &&strcmpi(polarity,'neg')~=1 && strcmpi(polarity,'NEGative')~=1
                error('polarity must be ''pos'',''positive'', ''neg'', or ''negative''')
            end
            fprintf(obj.conn,[':OUTPut' num2str(chan) ':GAT:POL ' polarity]);
            pol = getPolarity(obj,chan);
        end
        function mode = getGateMode(obj,chan)
            %gets the gate mode of channel 'chan'. options are 'NORMAL' or 'GATED'. Normal means no gating.
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            mode = query(obj.conn,[':OUTPut' num2str(chan),':MODE?']);
            mode(end) = [];
        end
        function mode = setGateMode(obj,chan,mode)
            %sets the gate mode of channel 'chan'. options are 'NORMal' or 'GATed'.
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            if strcmpi(mode,'norm')~=1 && strcmpi(mode,'normal')~=1 &&strcmpi(mode,'gat')~=1 && strcmpi(mode,'gated')~=1
                error('mode must be ''norm'',''normal'', ''gat'', or ''gated''')
            end
            fprintf(obj.conn,[':OUTPut' num2str(chan),':MODE ',mode]);
            mode = getGateMode(obj,chan);
        end
        function mode = getBurstMode(obj,chan)
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            mode = query(obj.conn,[':SOUR',num2str(chan),':BURS:MODE?']);
            mode(end) = [];
        end
        function mode = setBurstMode(obj,chan,mode)
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            modeList = {'TRIG','triggered','INF','infinity','GAT','gated'};
            assert(any(strcmpi(mode,modeList)),...
                sprintf('Mode must be any of the following: %s, and you asked for %s.',strjoin(string(modeList),', '),mode))
            fprintf(obj.conn,[':SOUR',num2str(chan),':BURS:MODE ' mode]);
            mode = getBurstMode(obj,chan);
        end
        function state = getBurstState(obj,chan)
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            state=query(obj.conn,[':SOUR',num2str(chan),':BURS?']);
            state(end) = [];
        end
        function state = setBurstState(obj,chan,state)
            if chan ~= 1 && chan ~= 2
                error('chan must be 1 or 2')
            end
            if isnumeric(state)
                state = num2str(state);
            end
            stateList = {'on','off','1','0'};
            assert(any(strcmpi(state,stateList)),...
                sprintf('State must be any of the following: %s.',strjoin(string(stateList),', ')))
            fprintf(obj.conn,[':SOUR',num2str(chan),':BURS ' state]);
            state = getBurstState(obj,chan);
        end
        function configRampBurst(obj,chan,freq,amp,offset,phase,symmetry,cycleNum)
            fprintf(obj.conn,[':SOUR' num2str(chan) ':APPL:RAMP ' num2str(freq) ',' num2str(amp) ',' num2str(offset) ',' num2str(phase)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':FUNCtion:RAMP:SYMMetry ' num2str(symmetry)]);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS ON']); 
            fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:MODE INF']);
%             fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:NCYC ' num2str(cycleNum)]);
%             fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:INT:PER 0.1']);
%             fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:TRIG:SOUR INT']);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:TRIG:SOUR EXT']);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:TRIG:TRIGO POS']);
            fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:TDEL 0']);
            fprintf(obj.conn,[':outp' num2str(chan) 'ON']);
%             fprintf(obj.conn,[':SOUR' num2str(chan) ':BURS:TRIG']);
            fprintf('rigol ramp burst config complete\n');
        end
        
        function configBurstAntiPhaseSqu(obj,freq,amp)
%               
%             fprintf(obj.conn,':outp1 OFF');            
            fprintf(obj.conn,':SOUR1:BURS off');
            fprintf(obj.conn,':SOUR1:FUNC SQU');
            fprintf(obj.conn,[':SOUR1:FREQ ' num2str(freq)]);
            fprintf(obj.conn,[':SOUR1:VOLT ' num2str(amp)]);
            fprintf(obj.conn,[':SOUR1:VOLT:OFFS ' num2str(0)]);
            fprintf(obj.conn,[':SOUR1:PHASE ' num2str(0)]);          
            fprintf(obj.conn,':SOUR1:BURS:MODE GAT');
            fprintf(obj.conn,':SOUR1:PHASE:INIT');
            fprintf(obj.conn,':SOUR1:PHASE:SYN');
            fprintf(obj.conn,':SOUR1:BURS on'); 
            fprintf(obj.conn,':outp1 ON');
            
            pause(1)
            fprintf(obj.conn,':SOUR2:BURS off'); 
            fprintf(obj.conn,':SOUR2:FUNC SQU');    
            fprintf(obj.conn,[':SOUR2:FREQ ' num2str(freq)]);          
            fprintf(obj.conn,[':SOUR2:VOLT ' num2str(amp)]);         
            fprintf(obj.conn,[':SOUR2:PHASE ' num2str(180)]);          
            fprintf(obj.conn,[':SOUR2:VOLT:OFFS ' num2str(0)]);
            fprintf(obj.conn,':SOUR2:PHASE:INIT');
            fprintf(obj.conn,':SOUR2:PHASE:SYN');
            fprintf(obj.conn,':SOUR2:BURS:MODE GAT');
            fprintf(obj.conn,':outp2 ON');            
            fprintf(obj.conn,':SOUR2:BURS on'); 
%             obj.alignPhase
            fprintf('rigol ramp burst config complete\n');
        end
        
        function delete(obj)
           fclose(obj.conn);
        end
        
        
    end
end

