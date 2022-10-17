%% Fit the fully parameterised intrusion model with different parameters across cond
% Read in data
load('EXPINT_data_recognised.mat')

n_participants = length(data);
n_runs = 5;
num_workers = maxNumCompThreads/2; % Maximum number of workers

%% Saturated (Full v2) Model
saturated = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_full_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_full_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            saturated(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)


%% Gamma-beta Model
gammabeta = cell(n_participants,4);
% Drift rates fixed across conditions, but gamma and beta allowed to vary
% across conditions

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_gammabeta_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_gammabeta_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            gammabeta(i,:) = this_fit;
        end
    end
end
save(filename)

%% Gamma Model
gamma = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_gamma_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_gamma_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            gamma(i,:) = this_fit;
        end
    end
end
save(filename)

%% Mix Cond Model
% Neither gamma nor beta (nor drift) vary across conditions, just the
% weight of different kinds of similarity for intrusions

% The MIXture depends on the CONdition, but that's all.
mix_cond = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_mix_cond_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_mix_cond_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            mix_cond(i,:) = this_fit;
        end
    end
end
save(filename)

%%%%%%%%%%%%%%%%%%%% Models not to be taken seriously, but check that
%%%%%%%%%%%%%%%%%%%% certain properties of the full model work in isolation

%% Spatiotemporal-Orthosem model
% Orthography and Semantics do matter, but they don't differ across
% conditions
spatiotemporal_orthosem = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_orthosem_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_orthosem_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemporal_orthosem(i,:) = this_fit;
        end
    end
end
save(filename)

%% Spatiotemporal Model
% No orthographic/semantic contribution in model, no difference between
% conditions
spatiotemporal = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemporal(i,:) = this_fit;
        end
    end
end
save(filename)

%% Pure Orthosem model
% Orthography and Semantics do matter, but they don't differ across
% conditions, and there is no spatiotemporal part to the model
pure_orthosem = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_pure_orthosem_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_pure_orthosem_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            pure_orthosem(i,:) = this_fit;
        end
    end
end
save(filename)

%% Simulation of the fitted models.

 sim_saturated = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), saturated{i,3}, i);
     sim_saturated = vertcat(sim_saturated, this_sim);
 end
 csvwrite('sim_saturated.csv', sim_saturated)

header_line = 'participant, model_name, AIC, v1t_1, v2t_1,  v1i_1,  v2i_1,  v1t_2, v2t_2,  v1i_2,  v2i_2, v1t_3, v2t_3,  v1i_3,  v2i_3,         eta_t, eta_i,       at,  ag,    beta1,  beta2,  beta3,      gamma1, gamma2,  gamma3,     tau,  l_b,   l_f,   zeta,  rho,   chi1,     chi2,      psi1,   psi2,    iota1,  iota2,  upsilon1,   upsilon2,     Ter,    st';
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_saturated.csv'];
param_to_csv(filename, 1:n_participants, saturated, 'Saturated', header_line);

 sim_gammabeta = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), gammabeta{i,3}, i);
     sim_gammabeta = vertcat(sim_gammabeta, this_sim);
 end
 csvwrite('sim_gammabeta.csv', sim_gammabeta)

filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_gammabeta.csv'];
param_to_csv(filename, 1:n_participants, gammabeta, 'gammabeta', header_line);

 sim_gamma = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), gamma{i,3}, i);
     sim_gamma = vertcat(sim_gamma, this_sim);
 end
 csvwrite('sim_gamma.csv', sim_gamma)
 
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_gamma.csv'];
param_to_csv(filename, 1:n_participants, gamma, 'gamma', header_line);

 sim_mix_cond = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), mix_cond{i,3}, i);
     sim_mix_cond = vertcat(sim_mix_cond, this_sim);
 end
 csvwrite('sim_mix_cond.csv', sim_mix_cond)
 
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_mix_cond.csv'];
param_to_csv(filename, 1:n_participants, mix_cond, 'mix_cond', header_line);

 sim_spatiotemporal_orthosem = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), spatiotemporal_orthosem{i,3}, i);
     sim_spatiotemporal_orthosem = vertcat(sim_spatiotemporal_orthosem, this_sim);
 end
 csvwrite('sim_spatiotemporal_orthosem.csv', sim_spatiotemporal_orthosem)
 
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_spatiotemporal_orthosem.csv'];
param_to_csv(filename, 1:n_participants, spatiotemporal_orthosem, 'spatiotemporal_orthosem', header_line);

 sim_spatiotemporal = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), spatiotemporal{i,3}, i);
     sim_spatiotemporal = vertcat(sim_spatiotemporal, this_sim);
 end
 csvwrite('sim_spatiotemporal.csv', sim_spatiotemporal)
 
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_spatiotemporal.csv'];
param_to_csv(filename, 1:n_participants, spatiotemporal, 'spatiotemporal', header_line);

 sim_pure_orthosem = [];
 for i = 1:10
     this_sim = simulate_full_model(data(i,:), pure_orthosem{i,3}, i);
     sim_pure_orthosem = vertcat(sim_pure_orthosem, this_sim);
 end
 csvwrite('sim_pure_orthosem.csv', sim_pure_orthosem)
 
filename = [datestr(now,'yyyy_mm_dd_HH'),'_pest_pure_orthosem.csv'];
param_to_csv(filename, 1:n_participants, pure_orthosem, 'pure_orthosem', header_line);
