function [ll, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix_pooled(data, badix)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, st, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12  13
setopt;
% 

v1 = normrnd(6,0.1);
v2 = 0;
eta = normrnd(0.1,0.1);
a1 = normrnd(4,0.5);
a2 = normrnd(1.4,0.5);
pi = normrnd(0.8,0.2);
Ter = normrnd(-.05,0.02);
st = abs(normrnd(0.03,0.05));
sa = 0;

P = [v1, v2, eta, a1, a2, pi, Ter,st,sa];
Sel = [1,0,1,1,1,1,1,1,0];  
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x_pooled, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff, penalty, pest_penalty] = fitmixture4x_pooled(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix);

end
