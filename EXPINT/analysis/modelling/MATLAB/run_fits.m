%% Fit the fully parameterised intrusion model with different parameters across cond
% Read in data
load('EXPINT_data_recognised.mat')

n_participants = length(data);
n_runs = 3;
num_workers = maxNumCompThreads/2; % Maximum number of workers

% Testing a subset of the possible models

% 1. Orthographic - no spatiotemporal component, no difference in
% conditions

% 2. Temporal Ortho Weight - no space, temporal and ortho weights vary

% 3. Temporal Ortho Decay, same as 2. but allows slope to vary as well

% 4. Spatiotemporal Weight, no ortho slope, but spatiotemporal weight
% varies by orthography condition

% 5. same as 4, but allow slope to vary

% 6. Spatiotemporal ortho weight

% 7. Spatiotemporal ortho decay

%% Ortho model
ortho = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_ortho_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_ortho_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            ortho(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

%% Temporal-Orthographic (Weight)
temp_ortho_w = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_temporal_ortho_weight_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_temporal_ortho_weight_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            temp_ortho_w(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

%% Temporal-Orthographic (Decay)
temp_ortho_d = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_temporal_ortho_decay_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_temporal_ortho_decay_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            temp_ortho_d(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

%% Spatioemporal-Orthographic (Weight)
spatiotemp_ortho_w = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_ortho_weight_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_ortho_weight_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemp_ortho_w(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

%% Spatioemporal-Orthographic (Decay)
spatiotemp_ortho_d = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_ortho_decay_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_ortho_decay_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemp_ortho_d(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_fits'];
save(filename)

%% Simulation of the fitted models.
header_line = 'participant, model_name, AIC, v1t_1, v2t_1,  v1i_1,  v2i_1,  v1t_2, v2t_2,  v1i_2,  v2i_2, v1t_3, v2t_3,  v1i_3,  v2i_3,         eta1_t, eta2_t, eta1_i, eta2_i,       at,  ag,    beta1,  beta2,  beta3,      gamma1, gamma2,  gamma3,     tau,  l_b,   l_f,   zeta,  rho,   chi1,     chi2,      psi1,   psi2,    iota1,  iota2,  upsilon1,   upsilon2,     Ter,    st';

sim_ortho = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), ortho{i,3}, i);
     sim_ortho = vertcat(sim_ortho, this_sim);
 end
 csvwrite('sim_ortho.csv', sim_ortho)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_ortho.csv'];
param_to_csv(filename, 1:n_participants, ortho, 'Orthographic', header_line);

sim_temp_ortho_w = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), temp_ortho_w{i,3}, i);
     sim_temp_ortho_w = vertcat(sim_temp_ortho_w, this_sim);
 end
 csvwrite('sim_temp_ortho_w.csv', sim_temp_ortho_w)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_temp_ortho_w.csv'];
param_to_csv(filename, 1:n_participants, temp_ortho_w, 'Temporal-Orthographic-Weight', header_line);

sim_temp_ortho_d = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), temp_ortho_d{i,3}, i);
     sim_temp_ortho_d = vertcat(sim_temp_ortho_d, this_sim);
 end
 csvwrite('sim_temp_ortho_d.csv', sim_temp_ortho_d)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_temp_ortho_d.csv'];
param_to_csv(filename, 1:n_participants, temp_ortho_d, 'Temporal-Orthographic-Decay', header_line);

sim_spatiotemp_ortho_w = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), spatiotemp_ortho_w{i,3}, i);
     sim_spatiotemp_ortho_w = vertcat(sim_spatiotemp_ortho_w, this_sim);
 end
 csvwrite('sim_spatiotemp_ortho_w.csv', sim_spatiotemp_ortho_w)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_spatiotemp_ortho_w.csv'];
param_to_csv(filename, 1:n_participants, spatiotemp_ortho_w, 'Spatiotemporal-Orthographic-Weight', header_line);

sim_spatiotemp_ortho_d = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), spatiotemp_ortho_d{i,3}, i);
     sim_spatiotemp_ortho_d = vertcat(sim_spatiotemp_ortho_d, this_sim);
 end
 csvwrite('sim_spatiotemp_ortho_d.csv', sim_spatiotemp_ortho_d)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_spatiotemp_ortho_d.csv'];
param_to_csv(filename, 1:n_participants, spatiotemp_ortho_d, 'Spatiotemporal-Orthographic-Decay', header_line);

