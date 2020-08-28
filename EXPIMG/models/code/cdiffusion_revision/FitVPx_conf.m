function [ll, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPx_conf(data, badix)
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%testing fitting continuous (VP) model to EXPIMG data
setopt;
%Starting parameters for P?)
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1, v2, eta, a, Ter, st, sa]
%          1    2   3   4   5   6   7


v1 = normrnd(1,0.25); % Drift norm, low imageability
v2 = 0;
eta = normrnd(0.5,0.25);
a = normrnd(1.6,0.4);   % Criterion (same for both low and high)
Ter = normrnd(0,0.05);     % Non decision time
st = abs(normrnd(0.05,0.01));   % Non decision time variability
sa = 0;     % Criterion variability

P = [v1, v2, eta, a, Ter, st, sa];
Sel = [1,0,1,1,1,1,0]; 

nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitdcircle4x_conf, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);

P(Sel== 1) = pest; 
[ll,bic,Pred,Gstuff, penalty, pest_penalty] = fitdcircle4x_conf(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix);
%fitplot(data, Pred);
end