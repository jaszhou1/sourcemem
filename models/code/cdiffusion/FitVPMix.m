function [ll, bic, Pred, pest, Gstuff] = FitVPMix(data, badix)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, st, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12  13
setopt;

v1a = normrnd(5,1);
v2a = normrnd(0.1,0.05);
v1b = normrnd(4,1);
v2b = normrnd(0.1,0.05);
eta1 = normrnd(1,0.7);
eta2 = normrnd(1,0.7);
a1 = normrnd(2,1);
a2 = normrnd(2,1);
pi1 = norm(0.5,0.5);
pi2 = normrnd(0.5,0.5);
Ter = normrnd(0.10,0.20);
st = abs(normrnd(0.05,0.01));
sa = 0;



P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter,st,sa];

Sel = [1,1,1,1,1,1,1,1,1,1,1,1,0];  % Criterion variability set at zero
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitmixture4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix); %Criterion Range Error
%fitplot(D11, Pred);
end
