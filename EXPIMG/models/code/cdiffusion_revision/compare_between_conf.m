%%   Jointly fit the high and low confidence data 
% ========================================================================
%   Can the threshold-style models continue to match the data 
%   if they can only change the proportion of failed trials for 
%   the two different confidence ranges? A comparison between threshold
%   models under different constraints.
%   
%   Original does not allow the parameters to vary between high and low
%   confidence
%
%   Mixing allows the mixing proportion between positive and zero drift
%   processes to vary across the confidence levels
%
%   Mixing + Drift allows both the aforementioned mixing proportion as well
%   as mean drift to vary across the confidence levels
%
%   All parameters constrained between low and high recognition datasets
%   Except pi1 and pi2, the mixing proportions in the mixture models.
% ========================================================================
% in the Fit_Data structure, {:,1} is recognised, {:,2} is unrecognised
Data = conf_data;

% Select participants who have more than 20 observations in the low
% confidence recognised category (column 2)
participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
for i = participants
    n_lowconf = size(Data{i,1}{1,2});
    if n_lowconf < 20
       Data{i,1} = [];
    end
end

participants = find(~cellfun(@isempty,Data))';
badixs = 5*ones(20,1);

nruns = 20; %Number of times I want to run fits on each participant to find the best fit
 
% % %Empty array for Log Likelihoods and Predictions to live.

%% Fit Mixture Model (Threshold model)
% Original
original = cell(length(participants),8);
for i = participants
    original{i,1} = -1;
    original{i,2} = 0;
    badix = badixs(i);
    ll = 1e7;
    for j=1:nruns
        % _conf constrains all parameters to be the same across confidence
        % conditions except pi, the mixing parameter with the zero drift
        % process. _conf_drift allows mixing parameter and mean drift to
        % differ between the confidence conditions.
        [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix_pooled(Data{i},badix);
        if llnew < ll
            ll = llnew;
            original{i,1} = ll;
            original{i,2} = bic;
            original{i,3} = Pred;
            original{i,4} = pest;
            original{i,5} = Gstuff;
            original{i,6} = Data {i};
            original{i,7} = penalty;
            original{i,8} = pest_penalty;
       end
    end
end

% Mixing
% Empty array for Log Likelihoods and Predictions to live.
mixing = cell(length(participants),8);
for i = participants
    mixing{i,1} = -1;
    mixing{i,2} = 0;
    badix = badixs(i);
    ll = 1e7;
    for j=1:nruns
        % _conf constrains all parameters to be the same across confidence
        % conditions except pi, the mixing parameter with the zero drift
        % process. _conf_drift allows mixing parameter and mean drift to
        % differ between the confidence conditions.
        [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix_conf(Data{i},badix);
        if llnew < ll
            ll = llnew;
            mixing{i,1} = ll;
            mixing{i,2} = bic;
            mixing{i,3} = Pred;
            mixing{i,4} = pest;
            mixing{i,5} = Gstuff;
            mixing{i,6} = Data {i};
            mixing{i,7} = penalty;
            mixing{i,8} = pest_penalty;
       end
    end
end

% Mixing + Drift
% Empty array for Log Likelihoods and Predictions to live.
mixing_drift = cell(length(participants),8);
for i = participants
    mixing_drift{i,1} = -1;
    mixing_drift{i,2} = 0;
    badix = badixs(i);
    ll = 1e7;
    for j=1:nruns
        % _conf constrains all parameters to be the same across confidence
        % conditions except pi, the mixing parameter with the zero drift
        % process. _conf_drift allows mixing parameter and mean drift to
        % differ between the confidence conditions.
        
        [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix_conf_drift(Data{i},badix);
%         [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix_conf(Data{i},badix);
        if llnew < ll
            ll = llnew;
            mixing_drift{i,1} = ll;
            mixing_drift{i,2} = bic;
            mixing_drift{i,3} = Pred;
            mixing_drift{i,4} = pest;
            mixing_drift{i,5} = Gstuff;
            mixing_drift{i,6} = Data {i};
            mixing_drift{i,7} = penalty;
            mixing_drift{i,8} = pest_penalty;
       end
    end
end

%% Fit Hybrid Model 

% HY_LL_Preds = cell(length(participants),8);
% for i = participants
%     HY_LL_Preds{i,1} = -1;
%     HY_LL_Preds{i,2} = 0;
%     badix = badixs(i);
%     ll = 1e7;
%     for j = 1:nruns
%         [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix_conf_drift(Data{i},badix);
% %         [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix_conf(Data{i},badix);
%         if llnew < ll
%             ll = llnew;
%             HY_LL_Preds{i,1} = ll;
%             HY_LL_Preds{i,2} = bic;
%             HY_LL_Preds{i,3} = Pred;
%             HY_LL_Preds{i,4} = pest;
%             HY_LL_Preds{i,5} = Gstuff;
%             HY_LL_Preds{i,6} = Data {i};
%             HY_LL_Preds{i,7} = penalty;
%             HY_LL_Preds{i,8} = pest_penalty;
%         end
%      %   fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
%     end
%     
% end

%% Plot Fits superimposed on Data, and save.
% 
% for i = participants
%     
%    filename = ['Mixing_Drift_',num2str(i),'.png'];
%    fitplot(Data {i}, mixing_drift{i,3});
%    saveas(gcf,filename);
%     
% end
% 
% 
%close all


%% Save mat file 
save(datestr(now,'yyyy_mm_dd_HH_MM'));

%% Save parameter and fit statistic csv files

param_to_csv_compare(strcat(datestr(now,'yyyy_mm_dd_HH_MM'),'_individual','_confdrift','.csv'),...
   participants, original, mixing, mixing_drift)

%% Save csv files to use for plotting in R
%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_btwconf','_Marginal','.csv'];
%abs_marginal_mat_to_csv(filename, 'Cont', VP_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_btwconf','_Marginal','.csv'];
%abs_marginal_mat_to_csv(filename, 'Thresh', MX_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_btwconf','_Marginal','.csv'];
%abs_marginal_mat_to_csv(filename, 'Hybrid', HY_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_btwconf','_Joint','.csv'];
%abs_mat_to_csv(filename, 'Cont', VP_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_btwconf','_Joint','.csv'];
%abs_mat_to_csv(filename, 'Thresh', MX_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_btwconf','_Joint','.csv'];
%abs_mat_to_csv(filename, 'Hybrid', HY_LL_Preds);

%filename = [datestr(now,'yyyy-mm-dd-HH-MM'), '_param',sprintf('_badix_%d', k),'.csv'];
%param_to_csv(filename,participants,VP_LL_Preds,...
%    MX_LL_Preds,HY_LL_Preds);

