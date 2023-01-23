% Need to demonstrate more convincingly that the variable precision model wont' cut it

% "major reason for its failing is that it produces very long RTs for the trials with low
% (or even zero) drift rates. This would mean that a version of the “stochastic sampling” model,
% when implemented in your framework, could provide a good account of the error distribution
% (when given a sufficiently large variability of drift rate), but would fail drastically
% with the RT distribution." <- demonstrate this


load('exp1_data.mat')
close all
% Participant 2 is probably the best example of a case where the simple
% response error model does a good job of capturing the response error
% distribution, but the diffusion model just doesn't do a good job.

this_data = vertcat(data{:});

v1_targ = 2;
v2_targ = 0;
v1_int = 1;
v2_int = 0;
eta1_targ = 1;
eta2_targ = 0.01;
eta1_int = 0.5;
eta2_int = 0.01;
a_targ = 0.9;
a_guess = 1.06;
gamma = 0.05;
beta = 0;
kappa = 0.59;
lambda_b = 1.11;
lambda_f = 1.05;
zeta = 0.39;
rho = 0.28;
Ter = 0.15;
st = 0;


params = [v1_targ, v2_targ, v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int,...
    a_targ,	 a_guess, gamma, beta,  Ter, st];

sim_data = simulate_spatiotemporal_eta(this_data, params);

plot_simulation(this_data, sim_data)

function[simulated_data] = simulate_spatiotemporal_eta(data, pest)
%%
% Number of trials to simulate (should be the same as the actual dataset)
n_trials = length(data);

% Default number of simulations
n_sims = 50; % The number of times to simulate each trial

P = pest;
% Assign parameter values
% Drift norm
v1_targ = P(1);
v2_targ = P(2);
v1_int = P(3);
v2_int = P(4);
eta1_targ = P(5);
eta2_targ = P(6);
eta1_int = P(7);
eta2_int = P(8);
a_targ = P(9);
a_int = a_targ;
a_guess = P(10);
gamma = P(11);
beta = P(12);
ter = P(13);
st = P(14);

% Assemble vector of proportions of the three components
p = [(1-gamma-beta), gamma, beta];

% Arguments for the simulation function
tmax = 5.1;
nt = 301;
h = tmax / nt;
% Each trial must be simulated one by one, as there is a unique
% configuration of n-1 intrusions for each trial (where n = number of
% trials)

%% Simulate trials
% This is the data structure that will contain the simulated
% observations for this participant
simulated_data = zeros(n_trials*n_sims, 2);
idx = 1;
n_intrusion = 9;
for i = 1:n_trials
    this_intrusions = data(i,5:13);
    for j = 1:n_sims
        % Determine if this trial is an intrusion, and shift the theta by
        % a random offset from the set of possible non-targets for this
        % trial if so.
        trial_type = mnrnd(1,p);
        if trial_type(2)
            mu1 = max(0,normrnd(v1_int, eta1_int));
            mu2 = max(0,normrnd(v2_int, eta2_int));
            sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
            sigma2 = 1;
            a = a_int; 
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial using dirisim
            [~,~, T, theta,~] = dirisim(P, h, tmax);
            % Shift the generated theta by the offset between target and chosen non-target
            intrusion_idx = randi(n_intrusion);
            this_offset = this_intrusions(intrusion_idx);
            theta = theta + this_offset;
            
            % If this shift exceeds the range of -pi to pi, then convert it
            % to be within that range
            theta = wrapToPi(theta);
            
            % Add non-decision time to response time
            T = T + normrnd(ter, st);
            
            % Store response error and response time of this trial
            simulated_data(idx, 1) = theta;
            simulated_data(idx, 2) = T;
            
            % Add one to index
            idx = idx + 1;
        elseif trial_type(1)
            mu1 = max(0,normrnd(v1_targ, eta1_targ));
            mu2 = max(0,normrnd(v2_targ, eta2_targ));
            sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
            sigma2 = 1;
            a = a_targ; 
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial using dirisim
            [~, ~, T, theta, ~] = dirisim(P, h, tmax);
            
            % Add non-decision time to response time
            T = T + normrnd(ter, st);
            
            % Store response error and response time of this trial
            simulated_data(idx, 1) = theta;
            simulated_data(idx, 2) = T;
            
            % Add one to index
            idx = idx + 1;
        elseif trial_type(3)
            mu1 = 0;
            mu2 = 0;
            sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
            sigma2 = 1;
            a = a_guess; 
            
            P = [mu1, mu2, sigma1, sigma2, a_guess];
            % Simulate a trial using dirisim
            [~, ~, T, theta, ~] = dirisim(P, h, tmax);
            
            % Add non-decision time to response time
            T = T + normrnd(ter, st);
            
            % Store response error and response time of this trial
            simulated_data(idx, 1) = theta;
            simulated_data(idx, 2) = T;
            
            % Add one to index
            idx = idx + 1;
        end
    end
end
end

function [spatial_similarity] = shepard(distance, k)
spatial_similarity = exp(-k * distance);
end
