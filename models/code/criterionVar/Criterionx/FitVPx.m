function [ll, bic, Pred, pest] = FitVPx(data)
%MEMORY_FIXATION Display a fixation cross for orienting the participant.
%   Data Treatment script to make EXPSOURCE model fitting code cooperate with
%   EXPIMG data
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%testing fitting continuous (VP) model to EXPIMG data
setopt;
%Starting parameters for P?)
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1a, eta2a, eta1b, eta2b, a, Ter]
%          1    2    3    4     5      6      7      8    9   10
v1a = normrnd(1,0.5);
v2a = normrnd(1,0.5);
v1b = normrnd(1,0.5);
v2b = normrnd(1,0.5);
eta1 = normrnd(2,1);
eta2 = normrnd(2,1);
a = normrnd(0.5,0.5);
Ter = normrnd(0.15,0.2);
sa = normrnd(1.25,1);


P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, sa];

nlow = length(data{1,1});
nhigh = length(data{1,2});
Sel = ones(1,9);
pest = fminsearch(@fitdcircle4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);

P(Sel== 1) = pest; 
[ll,bic,Pred] = fitdcircle4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);
%fitplot(data, Pred);
end
