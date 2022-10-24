function [ll, aic, P, penalty] = fit_spatiotemporal_model_eta(data, Pstart, badix)
setopt;

% Default value for badix
if nargin < 3
    badix = 5;
end

v1_targ = normrnd(4, 0.5);
v2_targ = 0;
v1_int = normrnd(1.3, 0.5);
v2_int = 0;
eta1_targ = normrnd(0.3, 0.1);
eta2_targ = normrnd(0.01, 0.001);
eta1_int = normrnd(0.3, 0.1);
eta2_int = normrnd(0.01, 0.001);
a_targ = normrnd(3, 0.5);
% a_int = normrnd(1.2, 0.1);
a_guess = normrnd(1.8, 0.2);
gamma = abs(normrnd(0.1, 0.01));
beta = abs(normrnd(0.1, 0.05));
kappa = normrnd(0.8, 0.05);
lambda_b = abs(normrnd(0.2, 0.2));
lambda_f = abs(normrnd(1, 0.2));
zeta = normrnd(0.9, 0.01);
rho = normrnd(0.75, 0.1);
Ter = normrnd(0.05, 0.05);
st = 0;


P = [v1_targ, v2_targ, v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int, a_targ, a_guess, gamma, beta, kappa, lambda_b, lambda_f, zeta, rho, Ter, st];
Sel = [1,        0,     1,       0,       1,        1,         1,         1,       1,       1,      1,    1,     1,      1,        1,      1,    1,   1,   0];  

pest = fminsearch(@spatiotemporal_model_eta, P(Sel==1), options, P(Sel==0), Sel, data, badix);
P(Sel==1) = pest;
[ll, aic, P, penalty] = spatiotemporal_model_eta(P(Sel==1), P(Sel==0), Sel, data, badix);

end
