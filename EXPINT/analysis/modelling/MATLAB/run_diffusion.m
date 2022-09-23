%% Fit Gradient Models
% Fit the saturated model

% Read in data
load('EXPINT_data.mat')

n_participants = length(data);
n_runs = 3;
num_workers = maxNumCompThreads/2; % Maximum number of workers

%% Saturated Model
saturated = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_saturated_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            this_fit{1} = ll_new;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            saturated(i,:) = this_fit;
        end
    end
end
% filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp_saturated'];
% save(filename)

%% Spatiotemporal Model
spatiotemporal = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_spatiotemporal_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            this_fit{1} = ll_new;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            spatiotemporal(i,:) = this_fit;
        end
    end
end
% filename = [datestr(now,'yyyy_mm_dd_HH'),'_temp_saturated'];
% save(filename)

%% Orthosem model with no difference across conditions
orthosem = cell(n_participants,4);

parfor (i = 1:n_participants, num_workers)
    % Initial log likelihood value
    ll = 1e7;
    % Run each participant nrun times
    this_fit = cell(1,4);
    for j = 1:n_runs
        this_participant_data = data(i,:);
        [ll_new, aic, pest, pest_penalty] = fit_orthosem_model(this_participant_data);
        % If this ll is better than the last one, replace it in the saved
        % structure
        if (ll_new < ll)
            this_fit{1} = ll_new;
            this_fit{2} = aic;
            this_fit{3} = pest;
            this_fit{4} = pest_penalty;
            orthosem(i,:) = this_fit;
        end
    end
end
% filename = [datestr(now,'yyyy_mm_dd_HH')];
% save(filename)
% 
% 
% %% Simulate some datasets
% sim_gradient = [];
% for i = 1:10
%     this_sim = simulate_gradient_model(data(i,:), saturated{i,3}, i);
%     sim_gradient = vertcat(sim_gradient, this_sim);
% end
% csvwrite('sim_saturated.csv', sim_gradient)
% 
% sim_spatiotemporal = [];
% for i = 1:10
%     this_sim = simulate_gradient_model(data(i,:), spatiotemporal{i,3}, i);
%     sim_spatiotemporal = vertcat(sim_spatiotemporal, this_sim);
% end
% csvwrite('sim_spatiotemporal.csv', sim_spatiotemporal)
