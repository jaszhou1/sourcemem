function [ll, bic, Pred, pest] = FitVPMix(data)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12
setopt;

v1a = normrnd(3,1);
v2a = normrnd(0.01,0.05);
v1b = normrnd(4,1);
v2b = normrnd(0.01,0.05);
eta1 = normrnd(1.5,1);
eta2 = normrnd(0.5,0.5);
a1 = normrnd(1.25,1);
a2 = normrnd(1,1);
pi1 = norm(0.5,0.25);
pi2 = normrnd(0.5,0.25);
Ter = normrnd(0.15,0.1);
sa = normrnd(1.25,1);


P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,sa];

Sel = [1,1,1,1,1,1,1,1,1,1,1,1];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
P(Sel==1) = pest;
[ll,bic,Pred] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh); %Criterion Range Error
%fitplot(D11, Pred);
end
