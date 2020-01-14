function [ll, bic, Pred, pest, Gstuff, penalty] = FitVPx(data, badix)
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
    
v1a = normrnd(1,0.25);
v2a = 0;
v1b = normrnd(1,0.25);
v2b = 0;
eta1 = normrnd(0.5,0.25);
eta2 = normrnd(0.5,0.25);
a = normrnd(1.6,0.4);
Ter = normrnd(0,0.05);
st = abs(normrnd(0.05,0.01));
sa = 0;



P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, st, sa];
Sel = [1,0,1,0,1,1,1,1,1,0]; 

nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitdcircle4x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, badix);

P(Sel== 1) = pest; 
[ll,bic,Pred,Gstuff, penalty] = fitdcircle4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix);
%fitplot(data, Pred);
end
