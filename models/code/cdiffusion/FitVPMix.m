function [ll, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix(data, badix)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, st, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12  13
setopt;
% 

v1a = normrnd(0,0.1);
v2a = 0;
v1b = normrnd(0,0.1);
v2b = 0;
eta1 = normrnd(0.1,0.1);
eta2 = normrnd(0.1,0.1);
a1 = normrnd(3,0.5);
a2 = normrnd(2,0.5);
pi1 = normrnd(0.1,0.2);
pi2 = normrnd(0.1,0.2);
Ter = normrnd(0,0.02);
st = abs(normrnd(0.03,0.05));
sa = 0;

P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,st,sa];
%P = [0.0034,0,0.0893,0,0.0048,0.0007,1.4763,0.6994,0.2203,0.1499,-0.0266,0];
% P =[0.9773,0,1.1281,0,0.0039,0.4812,1.3530,0.6573,0.3313,0.3566,-0.0433,0];

Sel = [1,0,1,0,1,1,1,1,1,1,1,1,0];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff, penalty, pest_penalty] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix); 
end
