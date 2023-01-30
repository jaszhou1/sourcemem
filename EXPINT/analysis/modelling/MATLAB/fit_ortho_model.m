function [ll, aic, P, penalty] = fit_ortho_model(data, badix)
% Same intrusion scaling and guessing across conditions, just change the
% relative distribution of weight across the different kinds of similarity
% when calculating intrusion likelihood

setopt;
% Default value for badix (Cuts off the leading edge of RT)
if nargin < 2
    badix = 5;
end

v1_targ = 5; %1
v2_targ = 0; %2
v1_int = 2; %3
v2_int = 0; %4

eta1_targ = 1; %5
eta2_targ = 0; %6
eta1_int = 1; %7
eta2_int = 0; %8

% Decision Criteria
a_targ = 2; %9
a_guess = 0.5; %10

% Component Proportions
beta1 = 0.4; % 11
beta2 = NaN; % 12

gamma1 = 0.2; % 13
gamma2 = 0.3; % 14

% Intrusion similarity rating weights
chi1 = 1; % 15
chi2 = NaN; % 16

phi1 = 0; % 17
phi2 = NaN; % 18

psi1 = 0; % 19
psi2 = NaN; % 20

% Temporal Gradient
tau1 = 0.5; % 21 Weight forwards vs backwards intrusion decay slope
tau2 = NaN; % 22

lambda_b1 = 0; % 23
lambda_f1 = NaN; % 24

lambda_b2 = NaN; % 25
lambda_f2 = NaN; % 26

% Spatial gradient
zeta1 = 0; % 27 precision for Shepard similarity function (perceived spatial distance)
zeta2 = NaN; % 28

% Orthographic gradient 
iota1 = 6; % 29 Ortho decay, Low
iota2 = NaN; % 30 Ortho decay, High

% Semantic gradient
upsilon1 = 0; % 31 Semantic decay, Low
upsilon2 = NaN; %32 Semantic decay, High

% Nondecision Time
ter = 0.15; % 33
st = 0; % 34

P = [v1_targ, v2_targ v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int,...
    a_targ, a_guess, beta1, beta2, gamma1, gamma2, chi1, chi2, phi1, phi2, psi1, psi2,...
    tau1, tau2, lambda_b1, lambda_f1, lambda_b2, lambda_f2, zeta1, zeta2, iota1, iota2,...
    upsilon1, upsilon2, ter, st];

%% Parameter Boundaries

% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%                 DRIFT RATES                                   DRIFT VAR                        CRITERION          P(GUESS)              INTRUSION SCALE           ITEM / CONTEXT      SPACE/TIME      SEM/ORTH               TIME ASYM.      TIME DECAY                                  SPACE DECAY    ORTH DECAY        SEM DECAY           NON-DEC TIME
%      1           2        3      4              5             6        7          8             9     10          11    12              13     14                   15    16          17   18           19    20            21      22     23         24           25       26           27     28       29      30         31          32      33  34
% [v1_targ, v2_targ   v1_int, v2_int,     eta1_targ, eta2_targ, eta1_int, eta2_int,       a_targ, a_guess,   beta1, beta2,            gamma1, gamma2,            chi1, chi2,        phi1, phi2,       psi1, psi2,        tau1,    tau2,  lambda_b1, lambda_f1, lambda_b2, lambda_f2,     zeta1, zeta2,    iota1, iota2,      upsilon1, upsilon2,  ter, st]
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Sel= [1,    0,      1,      0,                  1,      0,     1,     0,                     1,      1,        1,       1,              1,      1,                  0,     0,        0,    0,         0,      0,          0,      0,      0,          0,        0,        0,               0,     0,         1,      0,          0,      0,         1,     0];
Ub= [ 10,   0.5,    8,    0.5,                  2,      2,     1,     0.5,                   8,      4,        1,       1,              1,      1,                  1,     1,        1,    1,         1,      1,          0.8,    0.8,    4,          4,        4,        4,               4,     4,         10,     10,         5,      5,         0.4,   0];
Lb= [ 1,    0,      0.2,    0,                  0,      0,     0,     0,                     0,      0,        0,       0,              0,      0,                  0,     0,        0,    0,         0,      0,          0.45,   0.45,   0,          0,        0,        0,               0,     0,         1,      1,          0,      0,         0,     0];
Pub=[ 9,    0.9,    7,      0.9,                1.5,    1,     1.5,   1,                     7,      3,        0.75,    0.75,           0.9,    0.9,                1,     1,      0.75, 0.75,      0.8,    0.8,          0.75,   0.75,   3.5,        3.5,      3,        3,               3.5,   3.5,       9.5,    9.5,        4.5,    4.5,       0.35,  0];
Plb=[ 1.1,  0,      0.5,    0,                  0,      0,     0,     0,                     0,      0,        0,       0.05,           0.02,   0.02,               0.05,  0.05,     0,    0,         0,     0,           0.5,    0.5,    0.1,        0.1,      0.2,      0.2,             0,     0,         1.5,    1.5,        0,      0,         0.01,  0];

Pbounds = [Ub; Lb; Pub; Plb];

%% Call to model code
pest = fminsearch(@intrusion_cond_model_x, P(Sel==1), options, P(Sel==0), Pbounds, Sel, data, badix);
P(Sel==1) = pest;
[ll, aic, P, penalty] = intrusion_cond_model_x(P(Sel==1), P(Sel==0), Pbounds, Sel, data, badix);
end