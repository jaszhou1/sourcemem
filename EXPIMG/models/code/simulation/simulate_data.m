function [simdata_cont, simdata_thresh] = simulate_data()
%% simulate_data
% Generate sets of simulated data for each model using parameters that provided the best
% fit for each model for each participant. Each simulated dataset should be
% based on the same number of observations as the actual empirical
% dataset. Then, fit the simulated data with each model to see if model
% selection correctly identifies the model that generated that simulated
% data.
%% Load in the empirical data
data = Treatment_Simple();
% Participants
participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];

% Determine the number of observations per participant
nobvs_low = double.empty(20, 0);
for i = participants
    this_participant_nobvs_low = size(data{i,1}{1,1},1);
    nobvs_low(i) = this_participant_nobvs_low;
end

nobvs_high = double.empty(20, 0);
for i = participants
    this_participant_nobvs_high = size(data{i,1}{1,2},1);
    nobvs_high(i) = this_participant_nobvs_high;
end

%% Load in the best fitting parameters of each model to that data
load('2020_02_10_19_28_pooled_badix_5.mat')

% Arguments for the diffusion process simulation code
tmax = 5.1;
nt = 301;
h = tmax / nt;
nw = 50;
d_angle = 2*pi/nw; %Angle space
%% Simulate the continuous model
simdata_cont = cell(20,2);
for i = participants
    % For this participant:
    
    % Parameters of best fit of the continuous model to this participant
    %    P = [v1, v2, eta,  a, Ter, st, sa]
    %          1   2    3    4   5   6   7
    pest = VP_LL_Preds_Recognised{i,8}(1,:);
    
    % Get number of trials to simulate (same as empirical dataset for that
    % participant in the low imageability condition)
    ntrials = nobvs_low(i);
    
    % This is the data structure that will contain the simulated
    % observations for this participant
    this_sim_low = double.empty(0, 2);
    for j = 1:ntrials
        
        % Arrange input vector that contains the  parameter values for simulation
        
        % Determine a drift rate by drawing from a gaussian with mean as the mean
        % drift and with standard deviation eta (drift variability)
        mu1 = max(0,normrnd(pest(1), pest(3)));
        mu2 = pest(2);
        % This is always equal to zero, since there was no evidence of systematic
        % bias in response error in empirical data
        sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
        sigma2 = 1;
        a = pest(4);
        
        
        P = [mu1, mu2, sigma1, sigma2, a];
        % Simulate a trial directly using dirisim
        [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
        
        % Store response error and response time of this trial
        this_sim_low(j, 1) = theta;
        this_sim_low(j, 2) = Ta;
    end
    simdata_cont{i,1} = this_sim_low;
    
    ntrials = nobvs_high(i);
    
    % Repeat, for the high conditions
    
    this_sim_high = double.empty(0, 2);
    for j = 1:ntrials
        
        % Arrange input vector that contains the  parameter values for simulation
        
        % Determine a drift rate by drawing from a gaussian with mean as the mean
        % drift and with standard deviation eta (drift variability)
        mu1 = max(0,normrnd(pest(1), pest(3)));
        mu2 = pest(2);
        % This is always equal to zero, since there was no evidence of systematic
        % bias in response error in empirical data
        sigma1 = 1; % This is the diffusion coefficient, and is always set to 1.
        sigma2 = 1;
        a = pest(4);
        
        
        P = [mu1, mu2, sigma1, sigma2, a];
        % Simulate a trial directly using dirisim
        [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
        
        % Store response error and response time of this trial
        this_sim_high(j, 1) = theta;
        this_sim_high(j, 2) = Ta;
    end
    simdata_cont{i,2} = this_sim_high;
    
end

%% Simulate the threshold model
simdata_thresh = cell(20,2);
for i = participants
    % Parameters of best fit of the continuous model to this participant
    %    P = [v1, v2, eta,   a1, a2, pi, Ter  st, sa]
    %          1   2    3    4   5   6    7   8   9
    pest = MX_LL_Preds_Recognised{i,8}(1,:);
    
    % Get number of trials to simulate (same as empirical dataset for that
    % participant)
    ntrials = nobvs_low(i);
    
    % This is the data structure that will contain the simulated
    % observations for this participant
    this_sim_low = double.empty(0, 2);
    for j = 1:ntrials
        
        % Draw a random number and compare it to the mixing proportion (pi)
        % to determine if we sample from a positive drift or a zero drift
        % guessing process. pi, which is pest(6) represents the proportion
        % of trials that are driven by memory.
        
        if rand < pest(6) % Positive Drift
            
            % Arrange input vector that contains the  parameter values for simulation
            mu1 = pest(1);
            mu2 = pest(2);
            sigma1 = 1;
            sigma2 = 1;
            a = pest(4);
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial directly using dirisim
            [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
            
            % Store response error and response time of this trial
            this_sim_low(j, 1) = theta;
            this_sim_low(j, 2) = Ta;
            
        else % Zero Drift
            
            % Arrange input vector that contains the  parameter values for simulation
            mu1 = 0;
            mu2 = 0;
            sigma1 = 1;
            sigma2 = 1;
            a = pest(5);
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial directly using dirisim
            [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
            
            % Store response error and response time of this trial
            this_sim_low(j, 1) = theta;
            this_sim_low(j, 2) = Ta;
        end
    end
    simdata_thresh{i,1} = this_sim_low;
    
    
    % Repeat, for high condition
    ntrials = nobvs_high(i);
    % This is the data structure that will contain the simulated
    % observations for this participant
    this_sim_high = double.empty(0, 2);
    
    for j = 1:ntrials
        
        % Draw a random number and compare it to the mixing proportion (pi)
        % to determine if we sample from a positive drift or a zero drift
        % guessing process.
        
        if rand > pest(6) % Positive Drift
            
            % Arrange input vector that contains the  parameter values for simulation
            mu1 = pest(1);
            mu2 = pest(2);
            sigma1 = 1;
            sigma2 = 1;
            a = pest(4);
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial directly using dirisim
            [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
            
            % Store response error and response time of this trial
            this_sim_high(j, 1) = theta;
            this_sim_high(j, 2) = Ta;
            
        else % Zero Drift
            
            % Arrange input vector that contains the  parameter values for simulation
            mu1 = 0;
            mu2 = 0;
            sigma1 = 1;
            sigma2 = 1;
            a = pest(5);
            
            P = [mu1, mu2, sigma1, sigma2, a];
            % Simulate a trial directly using dirisim
            [T,Xt, Ta,theta,nonterm] = dirisim(P, h, tmax);
            
            % Store response error and response time of this trial
            this_sim_high(j, 1) = theta;
            this_sim_high(j, 2) = Ta;
        end
    end
    simdata_thresh{i,2} = this_sim_high;
end
end