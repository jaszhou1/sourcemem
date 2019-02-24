function [ll, bic, Pred, pest] = FitVP(data)
%MEMORY_FIXATION Display a fixation cross for orienting the participant.
%   Data Treatment script to make EXPSOURCE model fitting code cooperate with
%   EXPIMG data
%
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%testing fitting continuous (VP) model to EXPIMG data
setopt;

v1a = normrnd(1,1);
v2a = normrnd(0.01,0.1);
v1b = normrnd(1.5,1);
v2b = normrnd(0.01,0.1);
eta1 = normrnd(1.5,1);
eta2 = normrnd(0.5,0.5);
a = normrnd(1.25,1);
Ter = normrnd(0.15,0.1);


P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter];

nlow = length(data{1,1});
nhigh = length(data{1,2});
Sel = ones(1,8);
pest = fminsearch(@fitdcircle3, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);

P(Sel== 1) = pest; 
[ll,bic,Pred] = fitdcircle3(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);
%fitplot(data, Pred);
end
