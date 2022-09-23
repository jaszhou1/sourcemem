% Simulated model fits from the estimated parameters do not show recentered
% intrusions as expected. Going to go back to what should have been the
% initial step and simulate the model with various parameter settings to
% determine if the model code itself is behaving unexpectedly
load('group_data.mat');

% Define parameters
v1_targ = 5;
v2_targ = 0;
v1_int = 5;
v2_int = 0;
% Trial-trial drift variability
eta_targ = 0.03;
eta_int = 0.01;
% Decision Criteria
a_targ = 1.5;
a_int = 1.5;
a_guess = 0.7;
% Component Proportions
beta = 0.2;
gamma = 0.1;
% beta_primacy = pest(11);
% beta_recency = pest(12);
% Temporal Gradient
tau = 0.6; %Weight forwards vs backwards intrusion decay slope
lambda_b = 0.5; % Decay of the backwards slope
lambda_f = 0.5; % Decay of the forwards slope
zeta = 0.3; %precision for Shepard similarity function (perceived spatial distance)
rho = 0.5; % Spatial component weight in intrusion probability calculation
chi1 = 0.2; % Item v Context, Low
chi2 = 0.8; % Item v Context, High
psi1 = 0.2; % Semantic v Ortho, Low
psi2 = 0.8; % Semantic v Ortho, High
iota1 = 0.5; % Ortho decay, Low
iota2 = 0.5; % Ortho decay, High
upsilon1 = 0.4; % Semantic decay, Low
upsilon2 = 0.4; % Semantic decay, High
% Nondecision Time
ter = 0.3;
st = 0;

P_saturated = [v1_targ, v2_targ, v1_int, v2_int, eta_targ, eta_int,  a_targ, a_guess,...
    beta, gamma, tau, lambda_b, lambda_f, zeta, rho, chi1, chi2, psi1, psi2...
    iota1, iota2, upsilon1, upsilon2, ter, st];

sim_saturated = simulate_gradient_model(data, P_saturated, 99);