classdef IPG < handle
    %class to control the IPG amplifier
    
    properties
        conn
    end
    
    methods
        function obj = IPG()
            obj.conn = gpib('ADLINK', 0, 12);
            fopen(obj.conn);
        end
        function power = setPower(obj,pow)
            if pow>20 || pow<0
                error('IPG setPower not between 0 and 20 W!');
            end
            fprintf(obj.conn,sprintf('SOUR:POW %.2f',pow));
            %             power = obj.getPower; %TODO. check why get power dosent work
            power = pow;
        end
        
        function power=getPower(obj)
            power=query(obj.conn,'SOUR:POW?');
        end
        
        function state = setLaserState(obj,state)
            if state~=1 && state~=0
                error('state needs to be 1 or 0')
            end
            fprintf(obj.conn,sprintf('SOUR:POW:STAT %d',state));
            state = 1; %TODO get this from get state
        end
        function t=getLaserState(obj)

            state=str2double(query(obj.conn,sprintf('SOUR:POW:STAT?')));
            state=de2bi(state,32);
            emissionState=state(1);
            if state(16) temperatureState="OVER TEMP"; else temperatureState="OK";end
            if state(17) BackReflection="HIGH BACKREFLECTION"; else BackReflection="OK";end
            if state(19) emissionControl="UNEXPECTED EMISSION"; else emissionControl="OK";end
            if state(20) SEEDlaser="SEED FAILURE"; else SEEDlaser="OK";end
            
%             setPower=string(query(obj.conn,'SOUR:POW?'));
            t=table(emissionState,temperatureState,BackReflection,emissionControl,SEEDlaser);
            
        end
        
        
         function delete(obj)
            fclose(obj.conn);
            fprintf('IPG connection closed\n');
        end
        
    end
end

