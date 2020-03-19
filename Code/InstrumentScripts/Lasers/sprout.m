classdef sprout < handle
    %class to control the sprout pump
    
    properties
        conn
    end
    
    methods
        function obj = sprout()
            obj.conn = serial('COM21');
            obj.conn.BaudRate=19200;
            obj.conn.Terminator=char(13);
            fopen(obj.conn);
        end
        function reply=getWarnings(obj)
            flushinput(obj.conn);
            reply=query(obj.conn,'warning?');
        end
        function reply=getLaserMode(obj)
            flushinput(obj.conn);
            reply=query(obj.conn,'OPMODE?');
        end
        
        function setLaserPower(obj,power)
            flushinput(obj.conn);
            fprintf(obj.conn,sprintf('POWER SET=%.2f',power));
        end
        
        function reply=getLaserSetPower(obj)
            flushinput(obj.conn);
            reply=query(obj.conn,'POWER SET?');
        end        
        function reply=getLaserPower(obj)
            flushinput(obj.conn);
            reply=query(obj.conn,'POWER?');
        end        
        function reply=getShutterState(obj)
            flushinput(obj.conn);
            reply=query(obj.conn,'shutter?');
        end
        function setStandbyMode(obj)
            flushinput(obj.conn);
            fprintf(obj.conn,'OPMODE=IDLE');
        end
        function setLaserOn(obj)
            flushinput(obj.conn);
            fprintf(obj.conn,'OPMODE=ON');
        end
        function setLaserOff(obj)
            flushinput(obj.conn);
            fprintf(obj.conn,'OPMODE=OFF');
        end
        function setLaserWarmup(obj)
            flushinput(obj.conn);
            fprintf(obj.conn,'OPMODE=WARMUP');
        end
         function delete(obj)
            fclose(obj.conn);
            fprintf('sprout connection closed\n');
        end
        
    end
end

