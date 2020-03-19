function G2=makeDefaultG2Params()
G2.min_phot_cycl=0;
G2.max_phot_cycl=4000;
G2.neighbors_variation_phot_cycle=0.2;
G2.neighbor_range_phot_cycle=5;
G2.Ti_pulse=[3];
G2.Tf_pulse=[17]; %take out the spike on chan3
G2.bin=0.02; %binwidth
G2.taui=-0.1;
G2.tauf=0.1;
G2.tau2i=G2.taui;
G2.tau2f=G2.tauf;
G2.pairs=   {[1;2], [2;3], [1;3]};
G3.triplets= [1;2;3]; 
end

