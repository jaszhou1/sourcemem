function [ll, bic, Pred, pest,Gstuff] = fitGVM(data,i)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
setopt;
%% Normal Fit

nunorm1 = normrnd(3,0.7);
nunorm2 = normrnd(3,0.7);
kappa1 = normrnd(3,0.5);
kappa2 = normrnd(3,0.5);
eta = normrnd(1, 0.5);
rho = normrnd(0.1,0.2);
a = normrnd(3.5,0.75);
Ter = normrnd(-0.2,0.3);
st = abs(normrnd(0.05,0.01));
sa = 0;
%sa = abs(normrnd(1,0.5));

P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa];

Sel = [1,1,1,1,1,1,1,1,1,0];  % all parameters free except criterion variability
%Sel = [0,0,0,0,0,0,0,0,0,0]; 
nlow = length(data{1,1});
nhigh = length(data{1,2});

%% 
pest = fminsearch(@fitgvm6x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff] = fitgvm6x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);
end
