function[simulated_data] = simulate_full_model(data, pest, participant)
%% Error Messages
name = 'SIMULATE_FULL_MODEL: ';
errmg1 = 'Incorrect number of parameters, exiting...';

% Arguments for the simulation function
tmax = 10;
nt = 301;
h = tmax / nt;

% Default number of simulations
n_sims = 1; % The number of times to simulate each trial

% Number of intrusions
num_intrusions = 7;

% Expected number of parameters
n_params = 37;
% Check the length of the parameter vector
if length(pest) ~= n_params
    [name, errmg1], length(pest), return;
end

% Drift norms
v1_targ_1 = pest(1);
v2_targ_1 = pest(2);
v1_int_1 = pest(3);
v2_int_1 = pest(4);

v1_targ_2 = pest(5);
v2_targ_2 = pest(6);
v1_int_2 = pest(7);
v2_int_2 = pest(8);

v1_targ_3 = pest(9);
v2_targ_3 = pest(10);
v1_int_3 = pest(11);
v2_int_3 = pest(12);
% Trial-trial drift variability
eta1_targ = pest(13);
eta2_targ = pest(14);
eta1_int = pest(15);
eta2_int = pest(16);
% Decision Criteria
a_targ = pest(17);
a_int = a_targ;
a_guess = pest(18);
% Component Proportions
beta1 = pest(19);
beta2 = pest(20);
beta3 = pest(21);
gamma1 = pest(22);
gamma2 = pest(23);
gamma3 = pest(24);
% beta_primacy = P(11);
% beta_recency = P(12);
% Temporal Gradient
tau = pest(25); %Weight forwards vs backwards intrusion decay slope
lambda_b = pest(26); % Decay of the backwards slope
lambda_f = pest(27); % Decay of the forwards slope
zeta = pest(28); %precision for Shepard similarity function (perceived spatial distance)
rho = pest(29); % Spatial component weight in intrusion probability calculation
chi1 = pest(30); % Item v Context, Low
chi2 = pest(31); % Item v Context, High
psi1 = pest(32); % Semantic v Ortho, Low
psi2 = pest(33); % Semantic v Ortho, High
iota1 = pest(34); % Ortho decay, Low
iota2 = pest(35); % Ortho decay, High
upsilon1 = pest(36); % Semantic decay, Low
upsilon2 = pest(37); % Semantic decay, High
% Nondecision Time
ter = pest(38);
st = pest(9);

% If certain parameters are fed in as 0, assume I intend for them to be
% equal across conditions, instead of actually being 0.
if v1_targ_2 == 0
    v1_targ_2 = v1_targ_1;
    v1_targ_3 = v1_targ_1;
end

if v2_targ_2 == 0
    v2_targ_2 = v2_targ_1;
    v2_targ_3 = v2_targ_1;
end

if v1_int_2 == 0
    v1_int_2 = v1_int_1;
    v1_int_3 = v1_int_1;
end

if v2_int_2 == 0
    v2_int_2 = v2_int_1;
    v2_int_3 = v2_int_1;
end

if beta2 == 0
    beta2 = beta1;
    beta3 = beta1;
end

if gamma2 == 0
    gamma2 = gamma1;
    gamma3 = gamma1;
end

if chi2 == 0
    chi2 = chi1;
    iota2 = iota1;
end

if psi2 == 0
    psi2 = psi1;
    upsilon2 = upsilon1;
end

% Initialise empty dataset to store simulated data
simulated_data = [];

% Simulate data for each condition separately
for cond = 1:3
    this_data = data{cond};

    if cond == 1 % All parameters base value
        v1_targ = v1_targ_1;
        v2_targ = v2_targ_1;
        v1_int = v1_int_1;
        v2_int = v2_int_1;
        beta = beta1;
        gamma = gamma1;
        chi = chi1;
        psi = psi1;
        iota = iota1;
        upsilon = upsilon1;
    elseif cond == 2 % ORTHOGRAPHIC CONDITION
        v1_targ = v1_targ_2;
        v2_targ = v2_targ_2;
        v1_int = v1_int_2;
        v2_int = v2_int_2;
        beta = beta2;
        gamma = gamma2;
        chi = chi2; % Higher item than base
        psi = psi1; % Low semantic
        iota = iota2; % Different orth decay to base
        upsilon = upsilon1; % but same semantic decay
    elseif cond == 3 % SEMANTIC CONDITION
        v1_targ = v1_targ_3;
        v2_targ = v2_targ_3;
        v1_int = v1_int_3;
        v2_int = v2_int_3;
        beta = beta3;
        gamma = gamma3;
        chi = chi2; % Higher item than base
        psi = psi2; % High semantic
        iota = iota1; % Same orth decay as base
        upsilon = upsilon2; % different semantic decay
    end

    % Raw temporal similarity values from the lags -9 to 9, skipping 0 (in a
    % list of 10)
    backwards_similarity = (1-tau)*exp(-lambda_b*(abs(-num_intrusions:-1)));
    forwards_similarity = tau*exp(-lambda_f*(abs(1:num_intrusions)));

    % Concatenate, and normalise
    temporal_similarity_values = [backwards_similarity, forwards_similarity];
    temporal_similarity_values = (temporal_similarity_values/sum(temporal_similarity_values))';

    % Replace all raw lags with the corresponding normalised temporal
    % similarity
    lags = this_data(:,13:19);
    [lag_val, ~, lag_index] = unique(lags);

    temporal_similarities = temporal_similarity_values(lag_index);
    temporal_similarities = reshape(temporal_similarities, size(lags));

    % Spatial similarity
    spatial_distances = this_data(:,20:26);
    spatial_similarities = shepard(spatial_distances, zeta);

    % Orthographic similarity
    orthographic_distances = this_data(:, 27:33);
    orthographic_similarities = shepard(orthographic_distances, iota);

    % Semantic similarity
    semantic_similarities = 1- this_data(:, 34:40);
    semantic_similarities = shepard(semantic_similarities, upsilon);

    % Normalise all components
    temporal_similarities = temporal_similarities./(max(temporal_similarities(:)));
    spatial_similarities = spatial_similarities./(max(spatial_similarities(:)));
    orthographic_similarities = orthographic_similarities./(max(orthographic_similarities(:)));
    semantic_similarities = semantic_similarities./(max(semantic_similarities(:)));

    intrusion_similarities = ((temporal_similarities.^(1-rho)) .* (spatial_similarities.^rho)).^(1-chi)...
        .* ((orthographic_similarities.^(1-psi)) .* (semantic_similarities.^psi)).^chi;

    % Scale spatiotemporal similarity values by gamma, the overall intrusion
    % scaling parameter
    intrusion_similarities = intrusion_similarities * gamma;

    target_weights = 1- sum(intrusion_similarities,2);
    weights = horzcat(target_weights, intrusion_similarities) * (1-beta);
    guess_weights = 1- sum(weights,2);
    weights = horzcat(weights, guess_weights);

    % Now that weights are done, simulate each trial n times
    n_trials = size(this_data, 1);

    % This is the data structure that will contain the simulated
    % observations for this participant
    this_cond_data = zeros(n_trials*n_sims, 49);
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
            % Add one to index
            idx = idx + 1;
        end
    end
    simulated_data = vertcat(simulated_data, this_cond_data);
end
end

function [similarity] = shepard(distance, k)
similarity = exp(-k * distance);
end
