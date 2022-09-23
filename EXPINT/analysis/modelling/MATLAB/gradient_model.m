function [ll, aic, P, pest_penalty] = gradient_model(Pvar, Pfix, Sel, Data, badix)

% Same as gradient condition model, but allowing 0 lowerbounds for
% irrelevant parameters.
%% Debugging
name = 'INTRUSION_MODEL: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Component weights do not sum to 1...';
errmg4 = 'Negative trial weight, exiting...';

%% Global variables

np = 25; % Number of parameters
epsx = 1e-9; % Small values to substitute for zeroes
cden = 0.05;  % Contaminant density.
tmax = 5.1; % Maximum response time
nt = 300; % Number of time steps
h = tmax/nt; % Size of a time step
nw = 50; % Number of angular steps on the circle.
% nw = 50 discretises the circle into 7.2 deg. steps
w = 2 * pi / nw; % size of the angular step
% Noise in the drift rate (infinitesimal standard deviation)
kmax = 50; %Maximum number of eigenvalues in dhamana
num_intrusions = 7;

%% Parameters

% Check to see if the parameter vector is of appropriate size
lp = length(Pvar) + length(Pfix);
if lp ~= np
    [name, errmg1], length(Pvar), length(Pfix), return;
end
if length(Sel) ~= np
    [name, errmg2], length(Sel), return;
end

% Assemble parameter vector.
P = zeros(1,np);
P(Sel==1) = Pvar;
P(Sel==0) = Pfix;

% Save on each iteration
% Ptemp = P;
% save Ptemp

% Drift norms
v1_targ = P(1);
v2_targ = P(2);
v1_int = P(3);
v2_int = P(4);
% Trial-trial drift variability
eta_targ = P(5);
eta_int = P(6);
% Decision Criteria
a_targ = P(7);
a_int = a_targ;
a_guess = P(8);
% Component Proportions
beta = P(9);
gamma = P(10);
% beta_primacy = P(11);
% beta_recency = P(12);
% Temporal Gradient
tau = P(11); %Weight forwards vs backwards intrusion decay slope
lambda_b = P(12); % Decay of the backwards slope
lambda_f = P(13); % Decay of the forwards slope
zeta = P(14); %precision for Shepard similarity function (perceived spatial distance)
rho = P(15); % Spatial component weight in intrusion probability calculation
chi1 = P(16); % Item v Context, Low
chi2 = P(17); % Item v Context, High
psi1 = P(18); % Semantic v Ortho, Low
psi2 = P(19); % Semantic v Ortho, High
iota1 = P(20); % Ortho decay, Low
iota2 = P(21); % Ortho decay, High
upsilon1 = P(22); % Semantic decay, Low
upsilon2 = P(23); % Semantic decay, High
% Nondecision Time
ter = P(24);
st = P(25);

% Check that the weights make sense for conditions
% i.e., I expect the weight for semantic similarity to be higher in the
% semantic condition, so I will constrain the psi2 > psi1.
if psi1 > psi2 || chi1 > chi2
    ll = 1e7;
    aic = 0;
    penalty = 1e7;
    pest_penalty(1,:) = P;
    [name, errmg3], return;
end

sigma = 1.0;

% Assume eta components in the x and y directions are the same
eta1_targ = eta_targ;
eta2_targ = eta_targ;
eta1_int = eta_int;
eta2_int = eta_int;
%% Parameter bounds
penalty = 0; % Set the penalty to an initial value of zero
pest_penalty(1,:) = P;
% ----------------------------------------------------------------------------
%      1   2     3      4      5      6        7   8        9     10      11    12     13     14     15     16         17        18      19       20       21      22           23          24     25    
%   [v1t, v2t,  v1i,  v2i,   eta_t, eta_i,    at,  ag,    beta,  gamma,  tau,  l_b,   l_f,   zeta,  rho,   chi1,     chi2,      psi1,   psi2,    iota1,  iota2,  upsilon1,   upsilon2,     Ter,    st]
% ----------------------------------------------------------------------------
Ub= [ 7,   0,    6,     0,     1,    1,       4.5, 4.5,    0.7,  0.4,    0.8,   2.5,  2.5,   0.7,   0.7,    0.8,      0.9,      0.8,     0.9,      5,     5,      5,          5,           0.5,    0.2];
Lb= [ 1,   0,    0.3,   0,     0.1,  0.1,     0.1, 0.5,    0.1,  0.05,   0.2,   0.3,  0.3,   0.1,   0.3,    0,        0,        0,       0,        0,     0,      0,          0,           0.1,    0];
Pub=[ 6.5, 0,    5.5,   0,     0.9,  0.9,     4.0, 4.0,    0.6,  0.3,    0.75,  2,    2,     0.6,   0.65,   0.75,     0.8,      0.75,    0.75,     4,     4,      4,          4,           0.45,   0.15];
Plb=[ 1.1, 0,    0.4,   0,     0.2,  0.2,     0.7, 0.7,    0.2,  0.1,    0.25,  0.4,  0.4,   0.2,   0.4,    0,        0,        0,       0,        0,     0,      0,          0,           0.2,    0];

if any(P - Ub > 0) || any(Lb - P > 0)
    ll = 1e7 + ...
        1e3 * (sum(max(P - Ub, 0).^2) + sum(max(Lb - P, 0).^2));
    aic = 0;
    return
else
    penalty =  1e3 * (sum(max(P - Pub, 0).^2) + sum(max(Plb - P, 0).^2));
end


pest_penalty(2,:) = max(P - Pub, 0).^2 + max(Plb - P, 0).^2;


%% On-target retrieval likelihoods
P_targ = [v1_targ, v2_targ, eta1_targ, eta2_targ, sigma, a_targ];
[t, Gt_target, theta] = vdcircle3x(P_targ, nw, h, tmax, badix);


P_guess = [0, 0, 0, 0, sigma, a_guess];
[T_guess, Gt_guess, theta_guess] = vdcircle3x(P_guess, nw, h, tmax, badix);

%% Intrusion weighting
% Construct a matrix of intrusion weights. Weights differ across
% conditions, and data from different conditions have been passed in
% separate cells, so I think it makes sense to fit each conditions' data
% separately and then just sum across conditions

% Empty vector to store likelihood for each condition
nLLs= zeros(1,3);

for cond = 1:3
    this_data = Data{1,cond}; % Get the data for the ith condition

    % Set the parameter values for intrusion component weights/decays
    if cond == 1 % All parameters base value
        chi = chi1; 
        psi = psi1;
        iota = iota1;
        upsilon = upsilon1;
    elseif cond == 2 % ORTHOGRAPHIC CONDITION
        chi = chi2; % Higher item than base
        psi = psi1; % Low semantic
        iota = iota2; % Different orth decay to base
        upsilon = upsilon1; % but same semantic decay
    elseif cond == 3 % SEMANTIC CONDITION
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

    % Check no weights are negative
    if any(weights(:) < 0)
        ll = 1e7;
        aic = 0;
        penalty = 1e7;
        pest_penalty(1,:) = P;
        [name, errmg4], return;
    end

    %% Intrusion processes

    % Zero-Drift component shared between intrusions
    % kmax controls truncation of series
    % badix is number of bad initial values in Gt to zero.
    P0 = [a_int, sigma];
    [~, Gt0] = dhamana(P0, kmax, h, tmax, badix);

    % Exponential term
    P_intrusion = [v1_int, v2_int, eta1_int, eta2_int, sigma, a_int];
    %Gt_targ is the exponential term for the (unshifted) target. This will
    %always be the same for each trial in this iteration because it is relative
    %to the target location

    % Empty structure to put likelihood of each data point
    like = zeros(length(this_data),1);
    for i = 1:length(this_data)
        % Get the serial position of this trial
        this_trial_pos = this_data(i, 5);

        % Find the intrusions for this trial
        this_trial_intrusions = this_data(i, 6:12);

        % Instead, get the vector of all weights from the matrix of weights across
        % all trials
        this_trial_weights = weights(i,:);
        this_target_weight = this_trial_weights(1);
        this_intrusion_weights = this_trial_weights(2:8);
        this_guess_weight = this_trial_weights(9);

        this_phi = this_data(i,1);
        this_rt = this_data(i,2);

        % Generate a canonically oriented distribution for the intrusion drift
        % rate, and then circularly shift the exponential term (Gt) by the number
        % of angular steps it takes to each the offset of the intrusion in question
        % and the target angle.
        intrusion_densities = cell(num_intrusions,1);
        for j = 1:num_intrusions
            % Find the number of angular steps to offset the exponential term by

            this_offset = this_trial_intrusions(j);
            num_steps_offset = round(this_offset/w);

            [this_intrusion_Gt, ~] = vdcircle3_shiftx(P_intrusion, t, Gt0, num_steps_offset);

            % Store in likelihood structure
            intrusion_densities{j} = this_intrusion_Gt;

        end
        % Weight each intrusion joint distribution with the matching normalised
        % temporal similarity
        Gt_int = (intrusion_densities{1} * this_intrusion_weights(1)...
            + intrusion_densities{2} * this_intrusion_weights(2)...
            + intrusion_densities{3} * this_intrusion_weights(3)...
            + intrusion_densities{4} * this_intrusion_weights(4)...
            + intrusion_densities{5} * this_intrusion_weights(5)...
            + intrusion_densities{6} * this_intrusion_weights(6)...
            + intrusion_densities{7} * this_intrusion_weights(7));

        % Mix the memory-based processes, intrusions, and guesses
        Gt =  (this_target_weight * Gt_target) ...
            + Gt_int + (this_guess_weight * Gt_guess);

        % Filter zeros
        Gt = max(Gt, epsx);
        % gtshort = max(gtshort, epsx);
        % Add nondecision times
        this_t = t + ter;

        % Convolve with Ter

        h = t(2) - t(1);
        if st > 2 * h
            m = round(st/h);
            n = length(t);
            fe = ones(1, m) / m;
            for k = 1:nw + 1
                gti = conv(Gt(k, :), fe);
                Gt(k,:) = gti(1:n);
            end
        end

        % Create mesh for interpolation
        [angle,time]=meshgrid(this_t, theta);
        like(i) = interp2(angle, time, Gt, this_rt, this_phi, 'linear');
    end

    % Out of range values returned as NaN's. Treat as contaminants - set small.
    idx = isnan(like);
    like(idx) = cden;

    % This condition log-likelihood (nLL).
    nLL = sum(-log(like));

    % Store the log likelihood of this condition
    nLLs(cond) = nLL;
end

% Minimize sum of minus LL's across conditions.
ll = sum(nLLs) + penalty; % + penalty

% Calculate the AIC
aic = 2 * ll + 2 * sum(Sel);
end

function [similarity] = shepard(distance, k)
similarity = exp(-k * distance);
end
