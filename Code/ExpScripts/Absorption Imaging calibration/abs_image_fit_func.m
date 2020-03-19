function res = abs_image_fit_func(x,p,state)
%state selects between x and y cross
switch state
    case 1 %x
        res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(4)).^2/(2*p(5)^2)));
    case 0 %y
       res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(6)).^2/(2*p(7)^2)));
end 
end
