%% Fit the fully parameterised intrusion model with different parameters across cond
% Read in data
load('EXPINT_data_recognised.mat')

n_participants = length(data);
n_runs = 3;
num_workers = maxNumCompThreads/2; % Maximum number of workers

% Testing a subset of the possible models

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
filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp'];
save(filename)

%% Some models without orthography component, just a difference between conditions in guess
%Spatioemporal (Weight)
spatiotemp = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value, very large. 
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_weight_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            % Double fit, call fminsearch again, but use the best parameter
            % estimates as starting points
            [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_weight_model(this_participant_data, pest);
            ll = ll_new;
            this_fit{1} = ll;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemp(i,:) = this_fit;
        end
    end
end

filename = [datestr(now,'yyyy_mm_dd_HH'),'_fits'];
save(filename)

%% Simulation of the fitted models.
header_line = 'participant, model_name, AIC, v1_targ, v2_targ, v1_int, v2_int, eta1_targ, eta2_targ, eta1_int, eta2_int, a_targ, a_guess, beta1, beta2, gamma1, gamma2, chi1, chi2, phi1, phi2, psi1, psi2, tau1, tau2,  lambda_b1, lambda_f1, lambda_b2, lambda_f2, zeta1, zeta2, iota1, iota2, uspsilon1, upsilon2,  ter, st';

sim_ortho = [];
 for i = 1:10
     this_sim = simulate_intrusion_cond_x(data(i,:), ortho{i,3}, i);
     sim_ortho = vertcat(sim_ortho, this_sim);
 end
 csvwrite('sim_ortho.csv', sim_ortho)

