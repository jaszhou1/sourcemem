function [ll, bic, Pred, pest] = FitMix(data)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
setopt;

v1a = 3;
v2a = 0.01;
v1b = 4;
v2b = 0.01;
eta1 = 0;
eta2 = 0;
a1 = 1.25;
a2 = 1;
pi1 = 0.5;
pi2 = 0.5;
Ter = 0.15;

P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter];

Sel = [1,1,1,1,0,0,1,1,1,1,1];  % all parameters free

pest = fminsearch(@fitmixture3, P(Sel==1), options, P(Sel==0), Sel, data);
P(Sel==1) = pest;
[ll,bic,Pred] = fitmixture3(P(Sel==1), P(Sel==0), Sel, data);
%fitplot(D11, Pred);
end
