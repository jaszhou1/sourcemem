% Simulate the effect of having different decision criteria for different conditions
load('EXPINT_data_recognised.mat')

v1_targ = 3.5; %1
v2_targ = 0; %2
v1_int = 3; %3
v2_int = 0; %4

eta1_targ1 = 1.5; %5
eta2_targ1 = 0; %6
eta1_targ2 = 1.5; %5
eta2_targ2 = 0; %6
eta1_targ3 = 1.5; %5
eta2_targ3 = 0; %6

eta1_int = 0.5; %7
eta2_int = 0; %8

% Decision Criteria
a_targ_1 = 2.5; %9
a_targ_2 = 5; %9
a_targ_3 = 1; %9
a_int = NaN; %10
a_guess = 0.5; %11

% Component Proportions
beta1 = 0.3; % 11
beta2 = NaN; % 12
beta3 = NaN; %13

gamma1 = 0.2; % 15
gamma2 = NaN; % 16
gamma3 = NaN; % 17

% Intrusion similarity rating weights
chi1 = 0.4; % 18
chi2 = NaN; % 19
chi3 = NaN; % 20

phi1 = 0; % 21
phi2 = NaN; % 22
phi3 = NaN; %23

psi1 = 0; % 24
psi2 = NaN; % 25
psi3 = NaN; % 26

% Temporal Gradient
tau1 = 0.5; % 27 Weight forwards vs backwards intrusion decay slope
tau2 = NaN; % 28
tau3 = NaN; % 29

lambda_b1 = 1.74; % 30
lambda_f1 = 1.1; % 31

lambda_b2 = NaN; % 32
lambda_f2 = NaN; % 33

lambda_b3 = NaN; % 34
lambda_f3 = NaN; % 35

% Spatial gradient
zeta1 = 0; % 36 precision for Shepard similarity function (perceived spatial distance)
zeta2 = NaN; % 37
zeta3 = NaN; % 38

% Orthographic gradient 
iota1 = 10; % 39 Ortho decay, Low
iota2 = NaN; % 40 Ortho decay, High
iota3 = NaN; % 41

% Semantic gradient
upsilon1 = 0; % 42 Semantic decay, Low
upsilon2 = NaN; % 43 Semantic decay, High
upsilon3 = NaN; % 44

% Nondecision Time
ter = 0.15; % 45
st = 0; % 46

P = [v1_targ, v2_targ v1_int, v2_int, eta1_targ1, eta2_targ1, ...
    eta1_targ2, eta2_targ2, eta1_targ3, eta2_targ3, eta1_int, eta2_int,...
    a_targ_1, a_targ_2, a_targ_3, a_int, a_guess, beta1, beta2, beta3, gamma1, gamma2, gamma3, chi1, chi2, chi3,... 
    phi1, phi2, phi3, psi1, psi2, psi3, tau1, tau2, tau3, lambda_b1, lambda_f1, ...
    lambda_b2, lambda_f2, lambda_b3, lambda_f3, zeta1, zeta2, zeta3, iota1, iota2, iota3, ...
    upsilon1, upsilon2, upsilon3, ter, st];


group_data = {};
group_data{1,1} = cat(1,data{:,1});
group_data{1,2} = cat(1,data{:,2});
group_data{1,3} = cat(1,data{:,3});
sim_data = simulate_intrusion_cond_crit(group_data, P, 0, 1);
data = vertcat(data{:});
plot_simulation_cond(data, sim_data)