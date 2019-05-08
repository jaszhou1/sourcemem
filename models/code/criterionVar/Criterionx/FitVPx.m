function [ll, bic, Pred, pest, Gstuff] = FitVPx(data)
%MEMORY_FIXATION Display a fixation cross for orienting the participant.
%   Data Treatment script to make EXPSOURCE model fitting code cooperate with
%   EXPIMG data
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%testing fitting continuous (VP) model to EXPIMG data
setopt;
%Starting parameters for P?)
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, st, sa]
%          1    2    3    4     5      6  7   8    9   10 
    
v1a = normrnd(3,1);
v2a = normrnd(0.01,0.05);
v1b = normrnd(2,1);
v2b = normrnd(0.5,0.5);
eta1 = normrnd(2.5,1);
eta2 = normrnd(2.5,1);
a = normrnd(1.6,0.4);
Ter = normrnd(0.05,0.15);
st = normrnd(0.5,0.5);
sa = normrnd(1,1);


P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, st, sa];

nlow = length(data{1,1});
nhigh = length(data{1,2});
Sel = ones(1,9);
pest = fminsearch(@fitdcircle4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);

P(Sel== 1) = pest; 
[ll,bic,Pred,Gstuff] = fitdcircle4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);
%fitplot(data, Pred);
end
