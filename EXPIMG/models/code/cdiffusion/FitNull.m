function [ll, bic, Pred, pest, Gstuff] = FitNull(data, badix)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, st, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12  13
setopt;
% 
v1a = 0;
v2a = 0;
v1b = 0;
v2b = 0;
eta1 = 0;
eta2 = 0;
a1 = normrnd(2,0.5);
a2 = normrnd(2,0.5);
pi1 = 1;
pi2 = 1;
Ter = normrnd(-0.15,0.05);
st = abs(normrnd(0.05,0.01));
sa = 0;


P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,st,sa];

Sel = [0,0,0,0,0,0,1,1,0,0,1,1,0];  
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix); %Criterion Range Error
%fitplot(D11, Pred);
end