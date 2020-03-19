function state = ChannelToggler(chan,state)
if isnumeric(state)
    if state == 1
        state = 'high';
    elseif state == 0
        state = 'low';
    else
        error('state is numeric, but ~= to 0 || 1')
    end
else
    if strcmpi(state,'high')
        state = 'high';
    elseif strcmpi(state,'low')
        state = low;
    else
        error('state must be ''high'', ''low'', 1, or 0')
    end
end
global inst
global p
origp = p;
initp
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
if ~exist('p') || ~isfield(p,'ct')
    initp
end
    
if ~any(strcmp(p.ct.Row,chan))
    error('%s is not in channle table!',chan)
end
D_A = p.ct.D_A(find(strcmpi(p.ct.Row,chan)));
if strcmpi(D_A,'A')
    error('%s is an analog channle. ChannleToggler works only for digital channles')
end

p.s  = sqncr;
p.s.addBlock({'setDigitalChannel','duration',0,'value',state,'channel',chan});
p.s.runStep;
p = origp;
end
	
