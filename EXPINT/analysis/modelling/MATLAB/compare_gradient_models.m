% quick script to compare the old spatiotemporal model for equivalence with
% new gradient model code. When chi (and all other orth/sem related
% parameters) are fixed at zero, the two models should return the same LL.
badix = 5;
load('EXPINT_data_flat.mat')
flat_data = data;

load('EXPINT_data.mat')

v1_targ = 4;
v2_targ = 0;
v1_int = 2;
v2_int = 0;
eta_targ = 0.3;
eta_int = 0.1;
a_targ = 3;
a_guess = 1;
beta = 0.5;
gamma = 0.1;
tau = 0.8;
lambda_b = 0.2;
lambda_f = 0.1;
zeta = 1;
rho = 0.7;
Ter = 0.05;
st = 0;


P1 = [v1_targ, v2_targ, v1_int, v2_int, eta_targ, eta_int,  a_targ, a_guess, gamma, beta, tau, lambda_b, lambda_f, zeta, rho, Ter, st];
Sel1 = [1,        0,     1,       0,       1,        1,        1,       1,      1,    1,    1,      1,        1,      1,    1,   1,   0];  

[ll, aic, P, penalty] = spatiotemporal_model(P1(Sel1==1), P1(Sel1==0), Sel1, flat_data{1}, badix);

chi1 = 0; % Item v Context, Low
chi2 = 0; % Item v Context, High
psi1 = 0; % Semantic v Ortho, Low
psi2 = 0; % Semantic v Ortho, High
iota1 = 0; % Ortho decay, Low
iota2 = 0; % Ortho decay, High
upsilon1 = 0; % Semantic decay, Low
upsilon2 = 0; % Semantic decay, High

P2 = [v1_targ, v2_targ, v1_int, v2_int, eta_targ, eta_int,  a_targ, a_guess,...
    beta, gamma, tau, lambda_b, lambda_f, zeta, rho, chi1, chi2, psi1, psi2...
    iota1, iota2, upsilon1, upsilon2, Ter, st];

Sel2 = [1,        0,     1,       0,       1,        1,        1,       1,...
    1,    1,     1,      1,        1,      1,    1,   0,     0,    0,   0,...
    0,      0,      0,      0,          1,  0];   

[ll2, aic2, P2, penalty2] = gradient_condition_model(P2(Sel2==1), P2(Sel2==0), Sel2, data, badix);

% These two models are the same under this configuration. There is a small
% difference in ll, but this is due to the "soft penalty" imposed when
% setting some of the values in the more complex model to 0. The actual
% likelihood of the models prior to penalisation is the same.