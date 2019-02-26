function [ll, bic, Pred, pest] = fitGVM(data)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
setopt;

nunorm1 = normrnd(2,1);
nunorm2 = normrnd(2,1);
kappa1 = normrnd(5,1);
kappa2 = normrnd(5,1);
eta = normrnd(0.5, 0.05);
rho = normrnd(0.05,0.01);
a = normrnd(2.8,0.3);
Ter = normrnd(-0.2,0.03);
st = normrnd(0.05,0.01);
sa = normrnd(1,0.3);

P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa];

Sel = [1,1,1,1,1,1,1,1,1,1];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitgvm6x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
P(Sel==1) = pest;
[ll,bic,Pred] = fitgvm6x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh); %Criterion Range Error
%fitplot(D11, Pred);
end