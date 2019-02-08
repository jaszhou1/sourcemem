function [ll, bic, Pred, pest] = FitMixX(data)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
setopt;

v1a = normrnd(3,0.5);
v2a = normrnd(0.01,0.01);
v1b = normrnd(2,0.5);
v2b = normrnd(0.01,0.01);
eta1 = normrnd(0, 0.01);
eta2 = normrnd(0,0.01);
a1 = normrnd(2.8,0.3);
a2 = normrnd(1.5,0.5);
pi1 = norm(0.5,0.1);
pi2 = normrnd(0.67,0.1);
Ter = normrnd(0.05,0.03);
sa = normrnd(1.4,0.5);


P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,sa];

Sel = [1,1,1,1,1,1,1,1,1,1,1,1];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
P(Sel==1) = pest;
[ll,bic,Pred] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh); %Criterion Range Error
%fitplot(D11, Pred);
end
