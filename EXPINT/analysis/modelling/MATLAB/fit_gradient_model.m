function [ll, aic, P, penalty] = fit_gradient_model(data, badix)
setopt;

% Default value for badix
if nargin < 2
    badix = 5;
end

v1_targ = normrnd(4, 0.1);
v2_targ = 0;
v1_int = abs(normrnd(0.1, 0.05));
v2_int = 0;
eta_targ = normrnd(0.2, 0.1);
eta_int = normrnd(0.01, 0.01);
a_targ = normrnd(1.7, 0.1);
a_guess = normrnd(0.5, 0.1);

beta = normrnd(0.3, 0.1);
gamma = normrnd(0.05, 0.1);
% Temporal Gradient
tau = normrnd(0.6, 0.1); %Weight forwards vs backwards intrusion decay slope
lambda_b = normrnd(0.8, 0.1); % Decay of the backwards slope
lambda_f = normrnd(0.6, 0.1); % Decay of the forwards slope
zeta = normrnd(0.5, 0.1); %precision for Shepard similarity function (perceived spatial distance)
rho = normrnd(0.3, 0.1); % Spatial component weight in intrusion probability calculation
chi1 = normrnd(0.1, 0.1); % Item v Context, Low
chi2 = normrnd(0.4, 0.1); % Item v Context, High
psi1 = normrnd(0.2, 0.1); % Semantic v Ortho, Low
psi2 = normrnd(0.4, 0.1); % Semantic v Ortho, High
iota1 = normrnd(1, 0.1); % Ortho decay, Low
iota2 = normrnd(1, 0.1); % Ortho decay, High
upsilon1 = normrnd(1, 0.1); % Semantic decay, Low
upsilon2 = normrnd(1, 0.1); % Semantic decay, High
% Nondecision Time
ter = normrnd(0.2, 0.05);
st = 0;

% P = [v1_targ, v2_targ, v1_int, v2_int, eta_targ, eta_int,  a_targ, a_guess,...
%     gamma, beta, kappa, lambda_b, lambda_f, zeta, rho, chi, psi, Ter, st, ...
%     iota];
% Sel = [1,        0,     1,       0,       1,        1,        1,       1,...
%     1,    1,     1,      1,        1,      1,    1,   1,  1,  1,   0, ...
%     1];   

P = [v1_targ, v2_targ, v1_int, v2_int, eta_targ, eta_int,  a_targ, a_guess,...
    beta, gamma, tau, lambda_b, lambda_f, zeta, rho, chi1, chi2, psi1, psi2...
    iota1, iota2, upsilon1, upsilon2, ter, st];

Sel = [1,        0,     1,       0,       1,        1,        1,       1,...
    1,    1,     1,      1,        1,      1,    1,   1,     1,    1,   1,...
    1,      1,      1,      1,          1,  0];   

pest = fminsearch(@gradient_condition_model, P(Sel==1), options, P(Sel==0), Sel, data, badix);
P(Sel==1) = pest;
[ll, aic, P, penalty] = gradient_condition_model(P(Sel==1), P(Sel==0), Sel, data, badix);

end
