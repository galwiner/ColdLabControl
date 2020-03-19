function setCircCurr(curr)
global p
p.s = sqncr;
p.s.addBlock({p.atomicActions.setCircCurrent,'value',curr,'duration',0});
p.s.runStep;

end
