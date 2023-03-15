function [ll, aic, P, penalty] = fit_sto_criterion_model(data, badix)
% Spatiotemporal-Orthographic model, with allowance for a different intrusion criterion
setopt;
% Default value for badix (Cuts off the leading edge of RT)
if nargin < 2
    badix = 5;
end

v1_targ = 8; %1
v2_targ = 0; %2
v1_int = 6; %3
v2_int = 0; %4

eta1_targ = 1; %5
eta2_targ = 0; %6
eta1_int = 1; %7
eta2_int = 0; %8

% Decision Criteria
a_targ = 2; %9
a_int = 2; %10
a_guess = 0.5; %11

% Component Proportions
beta1 = 0.4; % 11
beta2 = NaN; % 12
beta3 = NaN; %13

gamma1 = 0.2; % 15
gamma2 = NaN; % 16
gamma3 = NaN; % 17

% Intrusion similarity rating weights
chi1 = 0.4; % 18
chi2 = NaN; % 19
chi3 = NaN; % 20

phi1 = 0.2; % 21
phi2 = NaN; % 22
phi3 = NaN; %23

psi1 = 0.1; % 24
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
zeta1 = 2; % 36 precision for Shepard similarity function (perceived spatial distance)
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

P = [v1_targ, v2_targ v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int,...
    a_targ, a_int, a_guess, beta1, beta2, beta3, gamma1, gamma2, gamma3, chi1, chi2, chi3,... 
    phi1, phi2, phi3, psi1, psi2, psi3, tau1, tau2, tau3, lambda_b1, lambda_f1, ...
    lambda_b2, lambda_f2, lambda_b3, lambda_f3, zeta1, zeta2, zeta3, iota1, iota2, iota3, ...
    upsilon1, upsilon2, upsilon3, ter, st];

%% Parameter Boundaries

% --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%                 DRIFT RATES                                   DRIFT VAR                            CRITERION                    P(GUESS)                  INTRUSION SCALE           ITEM / CONTEXT      SPACE/TIME                SEM/ORTH                    TIME ASYM.                              TIME DECAY                                              SPACE DECAY           ORTH DECAY            SEM DECAY           NON-DEC TIME
%      1           2        3      4              5      6        7          8             9           10      11             12    13      14              15     16       17         18    19     20       21   22     23         24     25    26         27       28     29          30             31         32          33       34           35          36   37     38       39     40     41       42        43          44      45  46
% [v1_targ, v2_targ   v1_int, v2_int,     eta1_targ, eta2_targ, eta1_int, eta2_int,       a_targ,     a_int,   a_guess        beta1, beta2, beta3           gamma1, gamma2, gamma3     chi1, chi2,  chi3    phi1, phi2, phi3,       psi1, psi2,  psi3,      tau1,    tau2,  tau3        lambda_b1, lambda_f1, lambda_b2, lambda_f2,  lambda_b2, lambda_f2,   zeta1, zeta2, zeta3    iota1, iota2, iota3,  upsilon1, upsilon2, upsilon3,  ter, st]
% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Sel= [1,    0,      1,      0,                  1,      0,     1,     0,                     1,      1,         1,            1,       0,       0,          1,      0,      0,          1,     0,    0,     1,    0,     0,         1,      0,     0,       1,      0,       0          1,          1,        0,        0,            0,        0,            1,    0,      0,      1,      0,     0,       0,      0,         0,       1,     0];
Ub= [ 10,   0.5,    8,      0.5                 2,      2,     1,     0.5,                   6,      4,         4,            0.8,     0.8,     0.8,        0.85,   0.85,   0.85,       1,     1,    1,     1,    1,     1,         1,      1,     1,       0.8,    0.8,     0.8,       20,         20,       20,       20,           20,       20,           20,   20,     20,     20,     20,    20,      20,     20,        20,      0.4,   0];
Lb= [ 2.5,  0,      2,      0,                  0,      0,     0,     0,                     0.5,    0.2,       0.2,          0.05,    0.05,    0.05,       0.1,    0.1,    0.1,        0,     0,    0,     0,    0,     0,         0,      0,     0,       0.45,   0.45,    0.45,      0,          0,        0,        0,            0,        0,            0,    0,      0,      0,      0,     0,       0,      0,         0,       0,     0];
Pub=[ 9,    0.9,    7,      0.9,                1.5,    1,     1.5,   1,                     5.5,     3,        3,            0.75,    0.75,    0.75        0.8,    0.8,    0.8,        0.8,   0.8,  0.8,   0.75, 0.75,  0.75,      0.8,    0.8,   0.8,     0.75,   0.75,    0.75,      15,         15,       15,       15,           15,       15,           15,   15,     15,     15,    15,     15,      15,     15,        15,      0.35,  0];
Plb=[ 2,    0,      1.5,    0,                  0,      0,     0,     0,                     1,      0.5,       0.5,          0.1,     0.1,     0.1,        0.15,   0.15,   0.15,       0,     0,    0,     0.05, 0.05,  0.05,      0.05,   0.05,  0.05,    0.5,    0.5,     0.5,       0.1,        0.1,      0.2,      0.2,          0.2,      0.2,          0,    0,      0,      0,      0,     0,       0,      0,         0,       0.01,  0];

Pbounds = [Ub; Lb; Pub; Plb];

%% Call to model code
pest = fminsearch(@intrusion_cond_model, P(Sel==1), options, P(Sel==0), Pbounds, Sel, data, badix);
P(Sel==1) = pest;
[ll, aic, P, penalty] = intrusion_cond_model(P(Sel==1), P(Sel==0), Pbounds, Sel, data, badix);
end