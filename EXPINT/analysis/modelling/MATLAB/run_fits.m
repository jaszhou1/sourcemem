%% Fit the fully parameterised intrusion model with different parameters across cond
% Read in data
load('EXPINT_data_recognised.mat')

n_participants = length(data);
n_runs = 1;
num_workers = maxNumCompThreads/2; % Maximum number of workers

%% Model without orthography component, just a difference between conditions in guess
%Spatiotemporal 
spatiotemp = cell(n_participants,4);

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
            spatiotemp(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

% Four Factor (Semantics & Orthography as well as spatiotemporal)
fourfactor = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_fourfactor_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
%             [ll_new, aic, pest, pest_penalty] = fit_fourfactor_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            fourfactor(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

% Spatiotemporal-Orthogrpahic (No role for semantics)
sto = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemp_ortho_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemp_ortho_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            sto(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

% Temporal-Orthogrpahic (No space no semantics)
temporal_ortho = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_temp_ortho_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_temp_ortho_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            temporal_ortho(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

% STO_criterion
sto_criterion = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_sto_criterion_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_sto_criterion_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            sto_criterion(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_sto_criterion'];
save(filename)

% STO_criterion
sto_gamma = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_sto_gamma_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_sto_gamma_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            sto_gamma(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_sto_gamma'];
save(filename)

% Gamma is different between orth/unrelated, and beta is different for sem/unrelated
sto_semantic_beta = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_sto_semantic_beta_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_sto_semantic_beta_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            sto_semantic_beta(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_semantic_beta'];
save(filename)

% Semantic_beta, with different chi weighting across conditions
sto_weight = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_sto_weight_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_sto_weight_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            sto_weight(i,:) = this_fit;
        end
    end
end
filename = [datestr(now,'yyyy_mm_dd_HH'),'_sto_weight'];
save(filename)

%%
filename = [datestr(now,'yyyy_mm_dd_HH'),'_fits'];
save(filename)

%% Simulation of the fitted models.
header_line = 'participant, model_name, AIC, v1_targ, v2_targ, v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int, a_targ, a_guess, beta1, beta2, gamma1, gamma2, chi1, chi2, phi1, phi2, psi1, psi2, tau1, tau2,  lambda_b1, lambda_f1, lambda_b2, lambda_f2, zeta1, zeta2, iota1, iota2, uspsilon1, upsilon2,  ter, st';

sim_spatiotemp = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), spatiotemp{i,3}, i, 1);
     sim_spatiotemp = vertcat(sim_spatiotemp, this_sim);
 end
 csvwrite('sim_spatiotemp.csv', sim_spatiotemp)

 sim_fourfactor = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), fourfactor{i,3}, i, 2);
     sim_fourfactor = vertcat(sim_fourfactor, this_sim);
 end
 csvwrite('sim_fourfactor.csv', sim_fourfactor)

 sim_sto = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), sto{i,3}, i, 3);
     sim_sto = vertcat(sim_sto, this_sim);
 end
 csvwrite('sim_spatiotemp_ortho.csv', sim_sto)

sim_temporal_ortho = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), temporal_ortho{i,3}, i, 4);
     sim_temporal_ortho = vertcat(sim_temporal_ortho, this_sim);
 end
 csvwrite('sim_temporal_ortho.csv', sim_temporal_ortho)

sim_sto_criterion = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), sto_criterion{i,3}, i, 5);
     sim_sto_criterion = vertcat(sim_sto_criterion, this_sim);
 end
 csvwrite('sim_sto_criterion.csv', sim_sto_criterion)

 sim_sto_gamma = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), sto_gamma{i,3}, i, 6);
     sim_sto_gamma = vertcat(sim_sto_gamma, this_sim);
 end
 csvwrite('sim_sto_gamma.csv', sim_sto_gamma)

sim_sto_semantic_beta = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), sto_semantic_beta{i,3}, i, 7);
     sim_sto_semantic_beta = vertcat(sim_sto_semantic_beta, this_sim);
 end
 csvwrite('sim_sto_semantic_beta.csv', sim_sto_semantic_beta)

 sim_sto_weight = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond(data(i,:), sto_weight{i,3}, i, 8);
     sim_sto_weight = vertcat(sim_sto_weight, this_sim);
 end
 csvwrite('sim_sto_weight.csv', sim_sto_weight)