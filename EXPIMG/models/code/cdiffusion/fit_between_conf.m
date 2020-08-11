%%   Jointly fit the high and low confidence data 
% ========================================================================
%   Can the threshold-style models continue to match the data 
%   if they can only change the proportion of failed trials for 
%   the two different confidence ranges?
% ========================================================================
% in the Fit_Data structure, {:,1} is recognised, {:,2} is unrecognised
Fit_Data = conf_data;

nruns = 10; %Number of times I want to run fits on each participant to find the best fit


% %% Fit Variable Precision (Continuous model)
 participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
 badixs = [5,5,5,10,5,5,5,10,5,5,5,5,3,5,5,5,5,5,5,5];
 
% % %Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds_Recognised = cell(length(participants),8);

for i = participants
    
    ll = 1e7;
    badix = badixs(i);
    % Multiple Starts
    for j = 1:nruns
        [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPx(Recognised{i},badix);
        disp(i);
        
        if llnew < ll
            ll = llnew;
            VP_LL_Preds_Recognised{i,1} = ll;
            VP_LL_Preds_Recognised{i,2} = bic;
            VP_LL_Preds_Recognised{i,3} = Pred;
            VP_LL_Preds_Recognised{i,4} = pest;
            VP_LL_Preds_Recognised{i,5} = Gstuff;
            VP_LL_Preds_Recognised{i,6} = Recognised {i};
            VP_LL_Preds_Recognised{i,7} = penalty;
            VP_LL_Preds_Recognised{i,8} = pest_penalty;
        end
    end
    
end

% %% Fit Mixture Model (Threshold model)
%
% %Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds_Recognised = cell(length(participants),8);
for i = participants
    MX_LL_Preds_Recognised{i,1} = -1;
    MX_LL_Preds_Recognised{i,2} = 0;
    badix = badixs(i);
    ll = 1e7;
    for j=1:nruns
        [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix(Recognised{i},badix);
       % if llnew < ll
            ll = llnew;
            MX_LL_Preds_Recognised{i,1} = ll;
            MX_LL_Preds_Recognised{i,2} = bic;
            MX_LL_Preds_Recognised{i,3} = Pred;
            MX_LL_Preds_Recognised{i,4} = pest;
            MX_LL_Preds_Recognised{i,5} = Gstuff;
            MX_LL_Preds_Recognised{i,6} = Recognised {i};
            MX_LL_Preds_Recognised{i,7} = penalty;
            MX_LL_Preds_Recognised{i,8} = pest_penalty;
        %end
    end
end

% Fit VP + Mix Model

HY_LL_Preds_Recognised = cell(length(participants),8);
for i = participants
    HY_LL_Preds_Recognised{i,1} = -1;
    HY_LL_Preds_Recognised{i,2} = 0;
    badix = badixs(i);
    ll = 1e7;
    for j = 1:nruns
        [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix(Recognised{i},badix);
       % if llnew < ll
            ll = llnew;
            HY_LL_Preds_Recognised{i,1} = ll;
            HY_LL_Preds_Recognised{i,2} = bic;
            HY_LL_Preds_Recognised{i,3} = Pred;
            HY_LL_Preds_Recognised{i,4} = pest;
            HY_LL_Preds_Recognised{i,5} = Gstuff;
            HY_LL_Preds_Recognised{i,6} = Recognised {i};
            HY_LL_Preds_Recognised{i,7} = penalty;
            HY_LL_Preds_Recognised{i,8} = pest_penalty;
     %   end
     %   fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
    end
    
end

%% Plot Fits superimposed on Data, and save.
% % Plot
 for i = participants
    filename = ['Cont_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
    fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
    
    filename = ['Thresh_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
    fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
    
     filename = ['Hybrid_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
     fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
     saveas(gcf,filename);
     close all 
 end

close all


%% Save mat file 

save(datestr(now,'yyyy_mm_dd_HH_MM'))
%% Save csv files to use for plotting in R
filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_Marginal','.csv'];
abs_marginal_mat_to_csv(filename, 'Cont', VP_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_Marginal','.csv'];
abs_marginal_mat_to_csv(filename, 'Thresh', MX_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_Marginal','.csv'];
abs_marginal_mat_to_csv(filename, 'Hybrid', HY_LL_Preds_Recognised);


filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_Joint','.csv'];
abs_mat_to_csv(filename, 'Cont', VP_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_Joint','.csv'];
abs_mat_to_csv(filename, 'Thresh', MX_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_Joint','.csv'];
abs_mat_to_csv(filename, 'Hybrid', HY_LL_Preds_Recognised);

