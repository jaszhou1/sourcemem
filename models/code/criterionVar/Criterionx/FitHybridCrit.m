
%% Open Data

%Opens and organises the data into recognised/unrecognised and low/high imageability
Fit_Data = Treatment_Simple; 
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

badixs = [15,5,15,10,5,5,5,10,5,1,5,5,3,0,5,5,5,5,5,5];

% %% Fit Variable Precision (Continuous model)
% [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];\
% %% Fit Variable Precision (Continuous model)
%
% % %Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
    VP_LL_Preds_Recognised{i,1} = -1; %sometimes log likelihood goes negative. re-run if this happens
    VP_LL_Preds_Recognised{i,2} = 0; %make it automatically repeat if BIC is zero (fminsearch blew up)
    badix = badixs(i);
    while (VP_LL_Preds_Recognised{i,2} == 0 || VP_LL_Preds_Recognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = FitVPx(Recognised{i},badix);
        VP_LL_Preds_Recognised{i,1} = ll;
        VP_LL_Preds_Recognised{i,2} = bic;
        VP_LL_Preds_Recognised{i,3} = Pred;
        VP_LL_Preds_Recognised{i,4} = pest;
        VP_LL_Preds_Recognised{i,5} = Gstuff;
        VP_LL_Preds_Recognised{i,6} = Recognised {i};
      %  fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
    end
end

VP_LL_Preds_Unrecognised = cell(length(participants),6);
for i = participants
    VP_LL_Preds_Unrecognised{i,1} = -1;
    VP_LL_Preds_Unrecognised{i,2} = 0;
    badix = badixs(i);
    while (VP_LL_Preds_Unrecognised{i,2} == 0 || VP_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest,Gstuff] = FitVPx(Unrecognised{i},badix);
        VP_LL_Preds_Unrecognised{i,1} = ll;
        VP_LL_Preds_Unrecognised{i,2} = bic;
        VP_LL_Preds_Unrecognised{i,3} = Pred;
        VP_LL_Preds_Unrecognised{i,4} = pest;
        VP_LL_Preds_Unrecognised{i,5} = Gstuff;
        VP_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
    end
end
% %% Fit Mixture Model (Threshold model)
%
% %Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
    MX_LL_Preds_Recognised{i,1} = -1;
    MX_LL_Preds_Recognised{i,2} = 0;
    badix = badixs(i);
    while (MX_LL_Preds_Recognised{i,2} == 0 || MX_LL_Preds_Recognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = FitMix(Recognised{i},badix);
        MX_LL_Preds_Recognised{i,1} = ll;
        MX_LL_Preds_Recognised{i,2} = bic;
        MX_LL_Preds_Recognised{i,3} = Pred;
        MX_LL_Preds_Recognised{i,4} = pest;
        MX_LL_Preds_Recognised{i,5} = Gstuff;
        MX_LL_Preds_Recognised{i,6} = Recognised {i};
%        fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
    end
end

MX_LL_Preds_Unrecognised = cell(length(participants),6);
for i = participants
    MX_LL_Preds_Unrecognised{i,1} = -1;
    MX_LL_Preds_Unrecognised{i,2} = 0;
    badix = badixs(i);
    while (MX_LL_Preds_Unrecognised{i,2} == 0 || MX_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = FitMix(Unrecognised{i},badix);
        MX_LL_Preds_Unrecognised{i,1} = ll;
        MX_LL_Preds_Unrecognised{i,2} = bic;
        MX_LL_Preds_Unrecognised{i,3} = Pred;
        MX_LL_Preds_Unrecognised{i,4} = pest;
        MX_LL_Preds_Unrecognised{i,5} = Gstuff;
        MX_LL_Preds_Unrecognised{i,6} = Unrecognised {i};

    end
end

%% Fit VP + Mix Model

HY_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
    HY_LL_Preds_Recognised{i,1} = -1;
    HY_LL_Preds_Recognised{i,2} = 0;
    badix = badixs(i);
    while (HY_LL_Preds_Recognised{i,2} > 3000 || HY_LL_Preds_Recognised{i,2} == 0 || HY_LL_Preds_Recognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = FitVPMix(Recognised{i},badix);
        HY_LL_Preds_Recognised{i,1} = ll;
        HY_LL_Preds_Recognised{i,2} = bic;
        HY_LL_Preds_Recognised{i,3} = Pred;
        HY_LL_Preds_Recognised{i,4} = pest;
        HY_LL_Preds_Recognised{i,5} = Gstuff;
        HY_LL_Preds_Recognised{i,6} = Recognised {i};
%        fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
    end
   % fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
end

HY_LL_Preds_Unrecognised = cell(length(participants),6);
for i = participants
    HY_LL_Preds_Unrecognised{i,1} = -1;
    HY_LL_Preds_Unrecognised{i,2} = 0;
    badix = badixs(i);
    while (HY_LL_Preds_Unrecognised{i,2} == 0|| HY_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = FitVPMix(Unrecognised {i},badix);
        HY_LL_Preds_Unrecognised{i,1} = ll;
        HY_LL_Preds_Unrecognised{i,2} = bic;
        HY_LL_Preds_Unrecognised{i,3} = Pred;
        HY_LL_Preds_Unrecognised{i,4} = pest;
        HY_LL_Preds_Unrecognised{i,5} = Gstuff;
        HY_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
    end
end

save('NewCensored1')

%% Plot Fits superimposed on Data, and save.
% % Plot
for i = participants
   filename = ['_Cont_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
   saveas(gcf,filename);

   filename = ['Cont_Unrecog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
   saveas(gcf,filename);

   filename = ['Thresh_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
   saveas(gcf,filename);

   filename = ['Thresh_Unrecog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
   saveas(gcf,filename);

   filename = ['Hybrid_Recog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
   saveas(gcf,filename);

   filename = ['Hybrid_Unrecog',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
   fitplot(Unrecognised {i}, HY_LL_Preds_Unrecognised{i,3});
   saveas(gcf,filename);
end


%%
%%% The thing I want at the end is...
% full_data = open_data(filename)
% data = split_data(full_data)
% fit_data(data, starting_preds)
% plot_data_preds(plot_filename, data, preds)
