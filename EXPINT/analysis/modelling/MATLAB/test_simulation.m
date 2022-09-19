% Simulated model fits from the estimated parameters do not show recentered
% intrusions as expected. Going to go back to what should have been the
% initial step and simulate the model with various parameter settings to
% determine if the model code itself is behaving unexpectedly


this_sim = simulate_gradient_model(data(i,:), saturated{i,3}, i);