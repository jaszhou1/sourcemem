function[simulated_data] = simulate_intrusion_cond_crit(data, pest, participant, model_string)
%% Error Messages
name = 'SIMULATE_INTRUSION_COND_CRIT: ';
errmg1 = 'Incorrect number of parameters, exiting...';

% Arguments for the simulation function
tmax = 10;
nt = 301;
h = tmax / nt;

% Default number of simulations
n_sims = 5; % The number of times to simulate each trial

% Number of intrusions
num_intrusions = 7;

% Expected number of parameters
n_params = 48;
% Check the length of the parameter vector
if length(pest) ~= n_params
    [name, errmg1], length(pest), return;
end

P = pest;

% Save on each iteration
% Ptemp = P;
% save Ptemp

% Drift norms
v1_targ = P(1);
v2_targ = P(2);
v1_int = P(3);
v2_int = P(4);

% Trial-trial drift variability
eta1_targ = P(5);
eta2_targ = P(6);
eta1_int = P(7);
eta2_int = P(8);

% Decision Criteria
a_targ_1 = P(9);
a_targ_2 = P(10);
a_targ_3 = P(11);
a_int = P(12);
a_guess = P(13);

% Component Proportions
beta1 = P(14);
beta2 = P(15);
beta3 = P(16);

gamma1 = P(17);
gamma2 = P(18);
gamma3 = P(19);

% Intrusion similarity rating weights
chi1 = P(20);
chi2 = P(21);
chi3 = P(22);

phi1 = P(23);
phi2 = P(24);
phi3 = P(25);

psi1 = P(26);
psi2 = P(27);
psi3 = P(28);

% Temporal Gradient
tau1 = P(29); %Weight forwards vs backwards intrusion decay slope
tau2 = P(30);
tau3 = P(31);

lambda_b1 = P(32);
lambda_f1 = P(33);

lambda_b2 = P(34);
lambda_f2 = P(35);

lambda_b3 = P(36);
lambda_f3 = P(37);

% Spatial gradient
zeta1 = P(38); %precision for Shepard similarity function (perceived spatial distance)
zeta2 = P(39);
zeta3 = P(40);

% Orthographic gradient
iota1 = P(41); % Ortho decay, Low
iota2 = P(42); % Ortho decay, High
iota3 = P(43);

% Semantic gradient
upsilon1 = P(44); % Semantic decay, Low
upsilon2 = P(45); % Semantic decay, High
upsilon3 = P(46);

% Nondecision Time
ter = P(47);
st = P(48);


% If certain parameters are fed in as 0, assume I intend for them to be
% equal across conditions, instead of actually being 0.

% Making some assumptions about some pairs of parameters (e.g. chi & iota)
% and what the full model reduces down to when these parameters are equal
% to each other. This may not be the best way to implement this, but I
% can't be bothered writing 5+ versions of this code for the variants of
% the model I wish to test.

% The reason Pbound is passed in as an argument rather than being defined
% in the model code like Philip usually does is so I can set the lowerbound
% to 0 when I want parameters to be equal across conditions, but be higher
% in the freer version of the model.
if isnan(a_int)
    a_int = a_targ;
end

if isnan(beta2)
    beta2 = beta1;
    %beta3 = beta1;
end

if isnan(beta3)
    beta3 = beta1;
end

if isnan(gamma2)
    gamma2 = gamma1;
    %gamma3 = gamma1;
end

if isnan(gamma3)
    gamma3 = gamma1;
end


if isnan(chi2)
    chi2 = chi1;
end

if isnan(chi3)
    chi3 = chi1;
end

if isnan(phi2)
    phi2 = phi1;
end

if isnan(phi3)
    phi3 = phi1;
end

if isnan(psi2)
    psi2 = psi1;
end

if isnan(psi3)
    psi3 = psi1;
end

if isnan(tau2)
    tau2 = tau1;
end

if isnan(tau3)
    tau3 = tau1;
end

if isnan(lambda_f1)
    lambda_f1 = lambda_b1;
end

if isnan(lambda_b2)
    lambda_b2 = lambda_b1;
end

if isnan(lambda_f2)
    lambda_f2 = lambda_f1;
end

if isnan(lambda_b3)
    lambda_b3 = lambda_b1;
end

if isnan(lambda_f3)
    lambda_f3 = lambda_f1;
end

if isnan(zeta2)
    zeta2 = zeta1;
end

if isnan(zeta3)
    zeta3 = zeta1;
end

if isnan(iota2)
    iota2 = iota1;
end

if isnan(iota3)
    iota3 = iota1;
end

if isnan(upsilon2)
    upsilon2 = upsilon1;
end

if isnan(upsilon3)
    upsilon3 = upsilon1;
end

sigma = 1.0;

% Initialise empty dataset to store simulated data
simulated_data = [];

% Simulate data for each condition separately
for cond = 1:3
    this_data = data{cond};

    if cond == 1 % All parameters base value
        a_targ = a_targ_1;
        beta = beta1;
        gamma = gamma1;
        chi = chi1;
        phi = phi2;
        psi = psi1;
        tau = tau1;
        lambda_b = lambda_b1;
        lambda_f = lambda_f1;
        zeta = zeta1;
        iota = iota1;
        upsilon = upsilon1;
    elseif cond == 2 % ORTHOGRAPHIC CONDITION
        a_targ = a_targ_2;
        beta = beta2;
        gamma = gamma2;
        chi = chi2;
        phi = phi2;
        psi = psi2;
        tau = tau2;
        lambda_b = lambda_b2;
        lambda_f = lambda_f2;
        zeta = zeta2;
        iota = iota2;
        upsilon = upsilon2;
    elseif cond == 3 % SEMANTIC CONDITION <-  Assume this is the same as unrelated, based on response error models.
        a_targ = a_targ_3;
        beta = beta3;
        gamma = gamma3;
        chi = chi3;
        phi = phi3;
        psi = psi3;
        tau = tau3;
        lambda_b = lambda_b3;
        lambda_f = lambda_f3;
        zeta = zeta3;
        iota = iota3;
        upsilon = upsilon3;
    end

    % Raw temporal similarity values from the lags -9 to 9, skipping 0 (in a
    % list of 10)
    lags = this_data(:,13:19)/7;

    lags(lags > 0) = tau * shepard(lags(lags > 0), lambda_f);
    lags(lags < 0) = (1 - tau) * shepard(lags(lags < 0), lambda_b);

    temporal_similarities = lags;

    % Spatial similarity
    spatial_distances = this_data(:,20:26)./max(this_data(:,20:26));
    spatial_similarities = shepard(spatial_distances, zeta);

    % Orthographic similarity
    orthographic_distances = this_data(:, 27:33)./max(this_data(:,27:33));
    orthographic_similarities = shepard(orthographic_distances, iota);

    % Semantic similarity
    semantic_similarities = 1- this_data(:, 34:40);
    semantic_similarities = shepard(semantic_similarities, upsilon);

    % Normalise all components
    temporal_similarities = temporal_similarities./(max(temporal_similarities(:)));
    spatial_similarities = spatial_similarities./(max(spatial_similarities(:)));
    orthographic_similarities = orthographic_similarities./(max(orthographic_similarities(:)));
    semantic_similarities = semantic_similarities./(max(semantic_similarities(:)));

    intrusion_similarities = ((temporal_similarities.^(1-phi)) .* (spatial_similarities.^phi)).^(1-chi)...
        .* ((orthographic_similarities.^(1-psi)) .* (semantic_similarities.^psi)).^chi;


    % Scale spatiotemporal similarity values by gamma, the overall intrusion
    % scaling parameter
    intrusion_similarities = intrusion_similarities * gamma;

    weights = horzcat(ones(length(intrusion_similarities),1), intrusion_similarities);
    target_weights = (weights ./ sum(weights, 2)) .* (1-beta);
    guess_weights = 1- sum(target_weights,2);
    weights = horzcat(target_weights, guess_weights);

    % Now that weights are done, simulate each trial n times
    n_trials = size(this_data, 1);

    % This is the data structure that will contain the simulated
    % observations for this participant
    this_cond_data = zeros(n_trials*n_sims, 50);
    idx = 1;

    for i = 1:n_trials
        this_intrusions = this_data(i, 6:12);
        this_weights = weights(i, :);
        for j = 1:n_sims
            % Determine if this trial is an intrusion, memory, or guess
            trial_type = mnrnd(1,this_weights);

            if trial_type(1) % This is the target
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
                this_cond_data(idx, 1) = theta;
                this_cond_data(idx, 2) = T;

            elseif trial_type(length(trial_type)) % This is a guess
                mu1 = 0;
                mu2 = 0;
                sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
                sigma2 = 1;
                a = a_guess;

                P = [mu1, mu2, sigma1, sigma2, a];
                % Simulate a trial using dirisim
                [~, ~, T, theta, ~] = dirisim(P, h, tmax);

                % Add non-decision time to response time
                T = T + normrnd(ter, st);

                % Store response error and response time of this trial
                this_cond_data(idx, 1) = theta;
                this_cond_data(idx, 2) = T;

            else % This is an intrusion
                mu1 = max(0,normrnd(v1_int, eta1_int));
                mu2 = max(0,normrnd(v2_int, eta2_int));
                sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
                sigma2 = 1;
                a = a_int;

                P = [mu1, mu2, sigma1, sigma2, a];
                % Simulate a trial using dirisim
                [~,~, T, theta,~] = dirisim(P, h, tmax);
                % Shift the generated theta by the offset between target and chosen non-target
                intrusion_idx = trial_type(2:end-1);
                this_offset = this_intrusions(intrusion_idx == 1);
                theta = theta + this_offset;

                % If this shift exceeds the range of -pi to pi, then convert it
                % to be within that range
                theta = wrapToPi(theta);

                % Add non-decision time to response time
                T = T + normrnd(ter, st);

                % Store response error and response time of this trial
                this_cond_data(idx, 1) = theta;
                this_cond_data(idx, 2) = T;

            end
            % Add the rest of the data structure to the simulated data
            this_cond_data(idx, 3) = this_data(i, 3); % response angle
            this_cond_data(idx, 4) = this_data(i, 4); % target angle
            this_cond_data(idx, 5) = this_data(i, 5); % trial number (in block)
            this_cond_data(idx, 6:12) = this_data(i, 6:12); % intrusion offsets
            this_cond_data(idx, 13:19) = this_data(i, 13:19); % intrusion lags
            this_cond_data(idx, 20:26) = this_data(i, 20:26); % intrusion spatial distances
            this_cond_data(idx, 27:33) = this_data(i, 27:33); % Orthographic
            this_cond_data(idx, 34:40) = this_data(i, 34:40); % Semantic
            this_cond_data(idx, 41:47) = this_data(i, 41:47); % Intrusion Angles
            this_cond_data(idx, 48) = cond;
            this_cond_data(idx, 49) = participant;
            this_cond_data(idx, 50) = model_string;
            % Add one to index
            idx = idx + 1;
        end
    end
    simulated_data = vertcat(simulated_data, this_cond_data);
end
end
function [similarity] = shepard(distance, k)
similarity = exp(-k * abs(distance));
end
