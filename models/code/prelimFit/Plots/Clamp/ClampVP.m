function [ll, bic, Pred, pest] = ClampVP(data, Sel)

% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

%testing fitting continuous (VP) model to EXPIMG data
setopt;
%Starting parameters for P?)
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1a, eta2a, eta1b, eta2b, a, Ter]
%          1    2    3    4     5      6      7      8    9   10

%% Raw Parameter Settings

v1a = normrnd(1,1);
v2a = normrnd(0.01,0.1);
v1b = normrnd(1.5,1);
v2b = normrnd(0.01,0.1);
eta1a = normrnd(1.5,1);
eta2a = normrnd(0.5,0.5);
eta1b = normrnd(1.5,1);
eta2b = normrnd(0.1,0.1);
a = normrnd(1.25,1);
Ter = normrnd(0.15,0.1);


%% Set Parameter upper and lower bounds
% 
% v1aMin = 0;
% v1aMax = 5;
% 
% v2aMin = 0;
% v2aMax = 5;
% 
% v1bMin = 0;
% v1bMax = 5;
% 
% v2bMin = 0;
% v2bMax = 5;
% 
% eta1aMin = 0;
% eta1aMax = 5;
% 
% eta2aMin
% eta2aMax
% 
% eta1bMin
% eta1bMax
% 
% eta2bMin
% eta2bMax = 
% 
% aMin = 0;
% aMax = 2;
% 
% TerMin = 0;
% TerMax = .15;

%% Calculate Summed Distance from Boundaries

%Shouldn't this be applied to the LL within fminsearch? Clarify w Lilburn

%% Clamp the parameter values
% 
% v1a = min(v1a,v1aMax);
% v1a = max(v1a,v1aMin);
% 
% v2a = min(v2a,v2aMax);
% v2a = max(v2a,v2aMin);
% 
% v1b = min(v1b,v1bMax);
% v1b = max(v1b,v1bMin);
% 
% v2b = min(v2b,v2bMax);
% v2b = max(v2b,v2bMin);
% 
% eta1a = min(eta1a,eta1aMax);
% eta1a = max(eta1a,eta1aMin);
% 
% eta2a = min(eta2a,eta2aMax);
% eta2a = max(eta2a,eta2aMin);
% 
% eta1b = min(eta1b,eta1bMax);
% eta1b = max(eta1b,eta1bMin);
% 
% eta2b = min(eta2b,eta1aMax);
% eta2b = max(eta2b,eta1aMin);
% 
% a = min(a,aMax);
% a = max(a,aMin);
% 
% Ter = min(Ter,TerMax);
% Ter = max(Ter,TerMin);

%% Summed Distance Penalty
% Sum up all the distances for parameter estimates that 


%% Hand into fminsearch
P = [v1a, v2a, v1b, v2b, eta1a, eta2a, eta1b, eta2b, a, Ter];
nlow = length(data{1,1});
nhigh = length(data{1,2});
%Sel = ones(1,10); This has been commented for clamping test
pest = fminsearch(@fitdcircle, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh, false);

P(Sel== 1) = pest; 
[ll,bic,Pred] = fitdcircle(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);
%fitplot(data, Pred);
end
