classdef m2ctrl < handle
    %
    
    properties
        conn
    end
    
    methods
        function obj = m2ctrl()
            obj.conn= tcpip('10.10.10.105',5000);
            obj.conn.Timeout=0.01;
            fopen(obj.conn);
            fprintf('opened connection to m2 laser controller\n');
            resp=query(obj.conn,'{"message":{"transmission_id": [999] ,"op":"start_link","parameters" :{"ip_address": "10.10.10.1"}}}');
            r=jsondecode(resp);
            if ~strcmpi(r.message.parameters.status,'ok')
                warning('problem with connection to m2 laser!');
            end
            
        end
%         query(m2,'{"message":{"transmission_id": [999] ,"op":"start_link","parameters" :{"ip_address": "10.10.10.3"}}}')
        function setResonatorPercentage(obj,percentage)
            if ~isnumeric(percentage)
                error('must be numeric!');
            end
            if ~ (percentage<=100 && percentage>=0)
                error('must be 0-100');
            end
            fprintf(obj.conn,sprintf('{"message":{"transmission_id": [999] ,"op":"tune_resonator","parameters" :{"setting": [%.4f]}}}\n',percentage));
%             resp=query(obj.conn,sprintf('{"message":{"transmission_id": [999] ,"op":"tune_resonator","parameters" :{"setting": [%.4f]}}}',percentage));
%             try
%             r=jsondecode(resp);
%             if ~isfield(r.message.parameters,'status')
%                 warning('Setting m2 resonator tune value failed');
%             end
%             catch
%                 warning('Setting m2 resonator tune value failed');
%             end
%             
            
            
        end
        
        function setEtalonLock(obj,state)
            if ~ (strcmpi(state,'on') || strcmpi(state,'off'))
                error('state must be on or off')
            end
            state=lower(state);
            resp=query(obj.conn,sprintf('{"message":{"transmission_id": [999] ,"op":"etalon_lock","parameters":{"operation":"%s"}}}',state));
            r=jsondecode(resp);
            if ~isfield(r.message.parameters,'status')
                warning('cannot set etalon state!');
            end
        end
        function setECDLock(obj,state)
            if ~ (strcmpi(state,'on') || strcmpi(state,'off'))
                error('state must be on or off')
            end
            state=lower(state);
            if strcmpi(state,'on') && strcmpi(obj.getECDLock,'off')
                error('cannot lock ECD if etalon is not locked');
            end
            
            resp=query(obj.conn,sprintf('{"message":{"transmission_id": [999] ,"op":"ecd_lock","parameters":{"operation":"%s"}}}',state));
            r=jsondecode(resp);
            if ~isfield(r.message.parameters,'status')
                warning('cannot set ECD state!');
            end
        end
        function [status]=getECDLock(obj)
            resp=query(obj.conn,'{"message":{"transmission_id": [999] ,"op":"ecd_lock_status"}}');
            try
            r=jsondecode(resp);
            if ~isfield(r.message.parameters,'condition')
                warning('cannot get ECD state!');
                status='error';
            else
                status=r.message.parameters.condition;
%                 voltage=r.parameters.voltage;
            end
            catch
                    warning('cannot get ECD state!');
                    status='error';
            end
            
        end
        function [status,voltage]=getEtalonLock(obj)
            resp=query(obj.conn,'{"message":{"transmission_id": [999] ,"op":"etalon_lock_status"}}');
            r=jsondecode(resp);
            if ~isfield(r.message.parameters,'condition')
                warning('cannot get etalon state!');
                status='error';
            else
                status=r.message.parameters.condition;
                
            end
        end
        function delete(obj)
            fclose(obj.conn);
            fprintf('closed connection to m2 laser controller\n');
        end
        
            
    end
end

