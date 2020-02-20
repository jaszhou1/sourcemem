function[prt,rt] = kernel_rt(data,cond)
 
%Participant i, thetas, low imageability
[prt,rt]= ksdensity(data{1,cond}(:, 2), 'Kernel', 'epanechnikov', 'Bandwidth', 0.1, 'Support','positive') ;

end