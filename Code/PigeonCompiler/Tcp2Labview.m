classdef Tcp2Labview <handle
    properties
      TcpID 
      UseOpenChannel
      computerip
      port
    end
    methods 
        function obj=Tcp2Labview(icomputerip,iport)
            % example how to open a communication with labview :
            % com=Tcp2Labview('localhost',6340);
            obj.computerip=icomputerip;
            obj.port=iport;
            obj.establishConnection;
        end
        
        function []=establishConnection(obj)
            needAnewObject=1;
            if (~isempty(instrfind('type','tcpip')))
                obj.TcpID=instrfind('type','tcpip');
                idx=find(strcmp(obj.TcpID.Name,'TCPIP-localhost'),1);
                if ~isempty(idx)
                    obj.TcpID=obj.TcpID(idx);
                    obj.UseOpenChannel=true;
                    if strcmp(obj.TcpID.status,'closed')||~isvalid(obj.TcpID)
                        needAnewObject=1;
                    else
                        needAnewObject=0;
                    end
                end
            end
            if needAnewObject
                UseOpenChannel=false;
                obj.TcpID=tcpip(obj.computerip,obj.port);
                set(obj.TcpID,'InputBufferSize',10*1024);
                set(obj.TcpID,'OutputBufferSize',10*1024);
                set(obj.TcpID,'Timeout',60); %60 seconds for receive
                fopen(obj.TcpID);
            end
        end
        
        function Delete(obj)
%             if (obj.UseOpenChannel==false)
%                 fclose(obj.TcpID);
%                 delete(obj.TcpID);
%             end
            fclose(obj.TcpID);
            delete(obj.TcpID);
            %release semaphore
%             TCPsem=Semaphore.me();
%             TCPsem.release;
        end 
        
        function intsend=UploadCode(obj,codeobj,dataBlock) 
            %lock semaphore
%             TCPsem=Semaphore.me();
%             TCPsem.lock;
            % ---------- write program to shared memory ------------
            % set the server to read from client
            try 
                fwrite(obj.TcpID,int8(0),'int8');
            catch FW
                disp(sprintf('Error:%s. Re-establishing TCP connection',FW.identifier));              
                establishConnection(obj);
            end
            % set [address  block size in int16 ]
            blocksize=codeobj.codenumoflines*3;
            fwrite(obj.TcpID,int16([100 blocksize]),'int16');
            % make the code array to 1D array
            newcode=codeobj.code(:,2:4); %only take 3 of the cols from the original code matrix
            % combine commnad and subcommand to single int16
            newcode(:,1)=typecast(int8(reshape(codeobj.code(:,1:2)',...
                                    1,codeobj.codenumoflines*2)),'int16');
            % reshape to 1D
            newcode=reshape(newcode',1,codeobj.codenumoflines*3);            
            fwrite(obj.TcpID,int16(newcode),'int16');
            intsend=size(newcode,2);  
            
            %---------------write data block to shared memory (starting from 2000)------------
            %zero the size of the dataBlock (tell the server)
            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  data size
            fwrite(obj.TcpID,int16([4 1 0]),'int16');
            if exist('dataBlock')
                if (length(dataBlock)>0)
                    %make sure dataBlock does not contain numbers<1
                    % since smallest time intervals allowed are 1=0.1\mu sec
                    dataBlock(find(dataBlock<1))=1;
                    % set the server to read from client
                    fwrite(obj.TcpID,int8(0),'int8');
                    % set size and base address of dataBlock inside shared
                    % memory. dataBlock should be an array of int32
                    %reshape dataBlock to an array of int16
                    shapedDataBlock=typecast(int32(dataBlock),'int16');
                    %send shaped data to server
                    fwrite(obj.TcpID,int16([2000 length(shapedDataBlock) shapedDataBlock]),'int16');
                    %tell the server what is the size of the dataBlock:
                    % set the server to read from client
                    fwrite(obj.TcpID,int8(0),'int8');
                    % set  data size
                    fwrite(obj.TcpID,int16([5 1 length(dataBlock)]),'int16');
                end
            end
            
            % ----------- update control parameters -------------- 
            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  program size
            fwrite(obj.TcpID,int16([1 1 codeobj.codenumoflines]),'int16');

            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  numofreadout
            fwrite(obj.TcpID,int16([3 1 codeobj.numofreadout]),'int16');
            
            
        end 
        
        function UpdateFpga(obj)
            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  host current operation to 'download program to FPGA'=1
            fwrite(obj.TcpID,int16([0 1 1]),'int16');
        end
        
        function Execute(obj,repeatnum)
            %------------- execute-----------------
            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  repeat program
            fwrite(obj.TcpID,int16([2 1 repeatnum]),'int16');
            pause(0.005); %  !!!!! originally 0.05! !!!!!!!
            % make sure repeat was updated!
            fwrite(obj.TcpID,int8(1),'int8'); %set server to write to client
            fwrite(obj.TcpID,[2 1],'int16'); %get one byte, address 2
            sanityRepeatNum=fread(obj.TcpID,1,'int16');
            if repeatnum~=sanityRepeatNum
                %emailFile([],'Tcp2Labview repeat program',sprintf('trying to run %d times, TCP server insists on %d times. Will try once more.',repeatnum,sanityRepeatNum));
                fprintf('trying to run %d times, TCP server insists on %d times. Will try once more.',repeatnum,sanityRepeatNum);
                % try again, check again
                pause(0.05);
                % set the server to read from client
                fwrite(obj.TcpID,int8(0),'int8');
                % set  repeat program
                fwrite(obj.TcpID,int16([2 1 repeatnum]),'int16');
                pause(0.05);
                % make sure repeat was updated!
                fwrite(obj.TcpID,int8(1),'int8'); %set server to write to client
                fwrite(obj.TcpID,[2 1],'int16'); %get one byte, address 2
                sanityRepeatNum=fread(obj.TcpID,1,'int16');
                if repeatnum~=sanityRepeatNum
                    emailFile([],'Tcp2Labview repeat program',sprintf('trying to run %d times, TCP server insists on %d times',repeatnum,sanityRepeatNum));
                    fprintf('trying to run %d times, TCP server insists on %d times\n. I will not continue!\n',repeatnum,sanityRepeatNum);
                    dbstack;
                    pause;
                    return;
                end
            end
            
            % set the server to read from client
            fwrite(obj.TcpID,int8(0),'int8');
            % set  host current operation to execute program=2
            fwrite(obj.TcpID,int16([0 1 2]),'int16');
            
        end 
        
        function output=ReadOut(obj,num)
            %------------ read output---------------
            %wait for host process idle 
            obj.WaitForHostIdle;
            if num>0 
                % set the server to write to client
                fwrite(obj.TcpID,int8(1),'int8');
                % set address to fifo out base address=1000 
                % size=num
                fwrite(obj.TcpID,int16([1001 num]),'int16');
                output=fread(obj.TcpID,num,'int16');
            else
                % set the server to write to client
                fwrite(obj.TcpID,int8(1),'int8');
                % set address to FIFo size base address=1000 
                fwrite(obj.TcpID,[int16(1000) 1],'int16');
                FIFOSize=fread(obj.TcpID,1,'int16'); 

                if(FIFOSize>0)
                    % set the server to write to client
                    fwrite(obj.TcpID,int8(1),'int8');
                    % set address to FIFo base address=1001 
                    fwrite(obj.TcpID,[int16(1001) FIFOSize],'int16');
                    output=fread(obj.TcpID,FIFOSize,'int16');
                else
                    output = [];
                end
            end 
            %unlock semaphore
%             TCPsem=Semaphore.me();
%             TCPsem.release;
        end 
        
        function data=readMemoryBlock(obj,startAddress,blockSize)
            %lock semaphore
%             TCPsem=Semaphore.me();
%             TCPsem.lock;
            % set the server to write to client
            fwrite(obj.TcpID,int8(1),'int8');
            % set address to Laser status  base address=4 
            fwrite(obj.TcpID,int16([startAddress blockSize]),'int16');
            data=fread(obj.TcpID,[1 blockSize],'int16');
            %release sem
%             TCPsem.release;
        end       
    

        function WaitForHostIdle(obj,timelimit)
            HostProcess=1;
            if ~exist('timelimit')
                timelimit=3; % 60 so time limit, in seconds
            end
            tich=tic;
            while (HostProcess~=0)&&(toc(tich)<timelimit)
                % set the server to write to client
                fwrite(obj.TcpID,int8(1),'int8');
                % set address to HostCurrentProcess 0 
                fwrite(obj.TcpID,[0 1],'int16');
                HostProcess=fread(obj.TcpID,1,'int16');
                %pause(0.01);
            end
            if toc(tich)>timelimit
                fprintf(['FPGA exceeded timelimit ' 'stuck in waitforhostidle. Waiting on your response!']);
%                 emailFile([],'FPGA exceeded timelimit','stuck in waitforhostidle. Waiting on your respeons!');
%                 pause;
            end
        end
        
    end
end