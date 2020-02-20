function[ptheta,theta] = kernel_theta(data,cond)
 
%Participant i, thetas, low imageability
[ptheta,theta]= ksdensity(data{1, cond}(:, 1), 'Kernel', 'epanechnikov', 'Bandwidth', 0.1, 'Support',[-pi,pi]) ;

end