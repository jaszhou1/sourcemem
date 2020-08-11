%% Fit the model

%% Open Data

% Opens and organises the data into recognised/unrecognised (based on conf)
% and low/high imageability (condition, labelled cond)
Fit_Data = Treatment_Simple(conf);
%Loading in dataset with RTs longer than 5s and greater than 3 sds above median after that, filtered out

Recognised = Fit_Data(:,1);
Unrecognised = Fit_Data(:,2);

%Fit the data, generate predictions.

participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];

%%% BADIX CHANGE, 21/05 %%%
% badix (appears in lower level fit functions, e.g. fitdcircle4x.m)
% controls for model's early RT predictions. It has a default value of 5,
% but needs to be higher for participants who have a high value for
% parameter sa, criterion variability, otherwise sharp discontinuities
% appear in the RT predictions. This needs to vary between participants,
% and so I have brought it up through the function levels to here, where
% a badix value specific to the individual is passed down through to the
% fitting procedure.


nruns = 10; %Number of times I want to run fits on each participant to find the best fit
%for k = 3:15
k = 5;
% %% Fit Variable Precision (Continuous model)
% [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];\
% %% Fit Variable Precision (Continuous model)
%
% % %Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds_Recognised = cell(length(participants),8);
for i = participants
    
    ll = 1e7;
    badix = k;
    % Multiple Starts
    for j = 1:nruns
        [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPx_pooled(Recognised{i},badix);
        disp(i);
        
        if (llnew < ll && llnew > 0)
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

% VP_LL_Preds_Unrecognised = cell(length(participants),8);
% for i = participants
%     VP_LL_Preds_Unrecognised{i,1} = -1;
%     VP_LL_Preds_Unrecognised{i,2} = 0;
%     badix = badixs(i);
%     while (VP_LL_Preds_Unrecognised{i,2} == 0 || VP_LL_Preds_Unrecognised{i,1} < 0)
%         [ll, bic, Pred, pest,Gstuff,penalty, pest_penalty] = FitVPx_pooled(Unrecognised{i},badix);
%         VP_LL_Preds_Unrecognised{i,1} = ll;
%         VP_LL_Preds_Unrecognised{i,2} = bic;
%         VP_LL_Preds_Unrecognised{i,3} = Pred;
%         VP_LL_Preds_Unrecognised{i,4} = pest;
%         VP_LL_Preds_Unrecognised{i,5} = Gstuff;
%         VP_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
%         VP_LL_Preds_Unrecognised{i,7} = penalty;
%         VP_LL_Preds_Unrecognised{i,8} = pest_penalty;
%     end
% end
% %% Fit Mixture Model (Threshold model)
%
% %Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds_Recognised = cell(length(participants),8);
for i = participants
    MX_LL_Preds_Recognised{i,1} = -1;
    MX_LL_Preds_Recognised{i,2} = 0;
    badix = k;
    
    ll = 1e7;
    for j=1:nruns
        [llnew, bic, Pred, pest, Gstuff,penalty, pest_penalty] = FitMix(Recognised{i},badix);
        if (llnew < ll && llnew > 0)
            ll = llnew;
            MX_LL_Preds_Recognised{i,1} = ll;
            MX_LL_Preds_Recognised{i,2} = bic;
            MX_LL_Preds_Recognised{i,3} = Pred;
            MX_LL_Preds_Recognised{i,4} = pest;
            MX_LL_Preds_Recognised{i,5} = Gstuff;
            MX_LL_Preds_Recognised{i,6} = Recognised {i};
            MX_LL_Preds_Recognised{i,7} = penalty;
            MX_LL_Preds_Recognised{i,8} = pest_penalty;
        end
    end
end

% Fit VP + Mix Model

HY_LL_Preds_Recognised = cell(length(participants),8);
for i = participants
    HY_LL_Preds_Recognised{i,1} = -1;
    HY_LL_Preds_Recognised{i,2} = 0;
    badix = k;
    ll = 1e7;
    for j = 1:nruns
        [llnew, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix_pooled(Recognised{i},badix);
        if (llnew < ll && llnew > 0)
            ll = llnew;
            HY_LL_Preds_Recognised{i,1} = ll;
            HY_LL_Preds_Recognised{i,2} = bic;
            HY_LL_Preds_Recognised{i,3} = Pred;
            HY_LL_Preds_Recognised{i,4} = pest;
            HY_LL_Preds_Recognised{i,5} = Gstuff;
            HY_LL_Preds_Recognised{i,6} = Recognised {i};
            HY_LL_Preds_Recognised{i,7} = penalty;
            HY_LL_Preds_Recognised{i,8} = pest_penalty;
        end
%        fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
    end
    
end

% HY_LL_Preds_Unrecognised = cell(length(participants),8);
% for i = participants
%     HY_LL_Preds_Unrecognised{i,1} = -1;
%     HY_LL_Preds_Unrecognised{i,2} = 0;
%     badix = badixs(i);
%     
%     while (HY_LL_Preds_Unrecognised{i,2} == 0|| HY_LL_Preds_Unrecognised{i,1} < 0)
%         [ll, bic, Pred, pest, Gstuff, penalty, pest_penalty] = FitVPMix_pooled(Unrecognised {i},badix);
%         HY_LL_Preds_Unrecognised{i,1} = ll;
%         HY_LL_Preds_Unrecognised{i,2} = bic;
%         HY_LL_Preds_Unrecognised{i,3} = Pred;
%         HY_LL_Preds_Unrecognised{i,4} = pest;
%         HY_LL_Preds_Unrecognised{i,5} = Gstuff;
%         HY_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
%         HY_LL_Preds_Unrecognised{i,7} = penalty;
%         HY_LL_Preds_Unrecognised{i,8} = pest_penalty;
%     end
% end

% NL_LL_Preds_Recognised = cell(length(participants),6);
%
% for i = participants
% %    filename = ['_Cont_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
% %    fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
% %    saveas(gcf,filename);
%
% %    filename = ['Cont_Unrecog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
% %    fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
% %    saveas(gcf,filename);
%     [ll, bic, Pred, pest, Gstuff] = FitNull(Recognised{i},badix);
%     NL_LL_Preds_Recognised{i,1} = ll;
%     NL_LL_Preds_Recognised{i,2} = bic;
%     NL_LL_Preds_Recognised{i,3} = Pred;
%     NL_LL_Preds_Recognised{i,4} = pest;
%     NL_LL_Preds_Recognised{i,5} = Gstuff;
%     NL_LL_Preds_Recognised{i,6} = Recognised {i};
%     fitplot(Recognised {i}, NL_LL_Preds_Recognised{i,3});
% end
%
% NL_LL_Preds_Unrecognised = cell(length(participants),6);
% for i = participants
%     [ll, bic, Pred, pest, Gstuff] = FitNull(Recognised{i},badix);
%     NL_LL_Preds_Unrecognised{i,1} = ll;
%     NL_LL_Preds_Unrecognised{i,2} = bic;
%     NL_LL_Preds_Unrecognised{i,3} = Pred;
%     NL_LL_Preds_Unrecognised{i,4} = pest;
%     NL_LL_Preds_Unrecognised{i,5} = Gstuff;
%     NL_LL_Preds_Unrecognised{i,6} = Recognised {i};
% end

%% Plot Fits superimposed on Data, and save.
% % Plot
 for i = participants
    filename = ['Cont_Recog_pooled',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
    fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
    
    filename = ['Thresh_Recog_pooled',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
    fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
    
     filename = ['Hybrid_Recog_pooled',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
     fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
     saveas(gcf,filename);
     close all     
 end

%close all


%% Save mat file 
filename = [datestr(now,'yyyy_mm_dd_HH_MM'),'_pooled',sprintf('_badix_%d', k)];
save(filename)
%% Save csv files to use for plotting in R
filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_Marginal',sprintf('_badix_%d', k),'.csv'];
abs_marginal_mat_to_csv(filename, 'Cont', VP_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_Marginal',sprintf('_badix_%d', k),'.csv'];
abs_marginal_mat_to_csv(filename, 'Thresh', MX_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_Marginal',sprintf('_badix_%d', k),'.csv'];
abs_marginal_mat_to_csv(filename, 'Hybrid', HY_LL_Preds_Recognised);


filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Cont','_Joint',sprintf('_badix_%d', k),'.csv'];
abs_mat_to_csv(filename, 'Cont', VP_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Thresh','_Joint',sprintf('_badix_%d', k),'.csv'];
abs_mat_to_csv(filename, 'Thresh', MX_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'),'_Hybrid','_Joint',sprintf('_badix_%d', k),'.csv'];
abs_mat_to_csv(filename, 'Hybrid', HY_LL_Preds_Recognised);

filename = [datestr(now,'yyyy-mm-dd-HH-MM'), '_param',sprintf('_badix_%d', k),'.csv'];
param_to_csv(filename,participants,VP_LL_Preds_Recognised,...
    MX_LL_Preds_Recognised,HY_LL_Preds_Recognised);

%end