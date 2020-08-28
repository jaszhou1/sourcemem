function [ll, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitMix_conf_drift(data, badix)
%    [ll,bic,Pred] = fitmixture4x_conf(Pvar, Pfix, Sel, Data)
%    P = [v1, v2, eta, a, pi1, pi2, Ter, st, sa]
%          1   2   3   4   5    6    7   8   9 
%    Parameters should be the same across the confidence levels, except
%    mean drift and mixing proportion parameters
setopt;

v1a = normrnd(3,0.5);
v2a = 0;
v1b = normrnd(1,0.5);
v2b = 0;
eta = 0;
a1 = normrnd(4,0.5);
a2 = normrnd(1,0.5);
pi1 = normrnd(0.5,0.2);
pi2 = normrnd(0.5,0.2);
Ter = normrnd(0,0.2);
st = abs(normrnd(0.05,0.01));
sa = 0;


P = [v1a, v2a, v1b, v2b, eta, a1, a2, pi1, pi2, Ter, st, sa];

Sel = [1,0,1,0,0,1,1,1,1,1,1,0];  
n_recog = length(data{1,1});
n_unrecog = length(data{1,2});
pest = fminsearch(@fitmixture4x_conf_drift, P(Sel==1), options, P(Sel==0), Sel, data, n_recog, n_unrecog, badix);
P(Sel==1) = pest;
[ll,bic,Pred, Gstuff, penalty, pest_penalty] = fitmixture4x_conf_drift(P(Sel==1), P(Sel==0), Sel, data, n_recog, n_unrecog, badix); 
end