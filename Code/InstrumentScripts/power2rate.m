function rate = power2rate(power)
%this function gets power (in pW) and returns it in terms of photons per
%micro second
%the incoming rate is: N = P*t/(h*c/lambda) where P is the power and t is
%1mus.
h = 6.6261e-34;
c = 299792458;
lambda = 780.24e-9;
t = 1e-6;
rate = power*1e-12*t*lambda/(h*c);
end
