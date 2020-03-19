function ToggleDispenser(state)
global p
global inst

if isempty(inst)
    init
end

p.s = sqncr;
% p.s.addBlock({
    end