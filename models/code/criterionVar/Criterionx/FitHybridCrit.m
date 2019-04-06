
%% Open Data

%Opens and organises the data into recognised/unrecognised and low/high imageability
%Fit_Data = Treatment_Simple('stimulus.xlsx');
%This is real slow, so I
%have Jindiv_simple for my data set. For future use, switch this on, and
%the following line off. You will need to do this in Treatment_Simple as
%well.
Fit_Data = Treatment_Simple;

Recognised = Fit_Data(:,1);
Unrecognised = Fit_Data(:,2);

%Fit the data, generate predictions.

%participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];

participants = [1,3,4,6,7,9,10,11,12,13,15,17,19,20];

% %% Fit Variable Precision (Continuous model)
%
% % %Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds_Recognised = cell(length(participants),4);
for i = participants
    VP_LL_Preds_Recognised{i,1} = -1; %sometimes log likelihood goes negative. re-run if this happens
    VP_LL_Preds_Recognised{i,2} = 0; %make it automatically repeat if BIC is zero (fminsearch blew up)
    while (VP_LL_Preds_Recognised{i,2} == 0 || VP_LL_Preds_Recognised{i,1} < 0)
	disp('VP')
	disp(i)
        [ll, bic, Pred, pest] = FitVPx(Recognised {i});
        VP_LL_Preds_Recognised{i,1} = ll;
        VP_LL_Preds_Recognised{i,2} = bic;
        VP_LL_Preds_Recognised{i,3} = Pred;
        VP_LL_Preds_Recognised{i,4} = pest;
        % VP_LL_Preds_Recognised{i,5} = Gstuff;
        % VP_LL_Preds_Recognised{i,6} = Recognised {i};
    end
end

VP_LL_Preds_Unrecognised = cell(length(participants),4);
for i = participants
    VP_LL_Preds_Unrecognised{i,1} = -1;
    VP_LL_Preds_Unrecognised{i,2} = 0;
    while (VP_LL_Preds_Unrecognised{i,2} == 0 || VP_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest] = FitVPx(Unrecognised {i});
        VP_LL_Preds_Unrecognised{i,1} = ll;
        VP_LL_Preds_Unrecognised{i,2} = bic;
        VP_LL_Preds_Unrecognised{i,3} = Pred;
        VP_LL_Preds_Unrecognised{i,4} = pest;
        % VP_LL_Preds_Unrecognised{i,5} = Gstuff;
        % VP_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
    end
end
% %% Fit Mixture Model (Threshold model)
%
% %Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds_Recognised = cell(length(participants),4);
for i = participants
    MX_LL_Preds_Recognised{i,1} = -1;
    MX_LL_Preds_Recognised{i,2} = 0;
    while (MX_LL_Preds_Recognised{i,2} == 0 || MX_LL_Preds_Recognised{i,1} < 0)
	disp('MX')
	disp(i)
        [ll, bic, Pred, pest] = FitMix(Recognised {i});
        MX_LL_Preds_Recognised{i,1} = ll;
        MX_LL_Preds_Recognised{i,2} = bic;
        MX_LL_Preds_Recognised{i,3} = Pred;
        MX_LL_Preds_Recognised{i,4} = pest;
        % MX_LL_Preds_Recognised{i,5} = Gstuff;
        % MX_LL_Preds_Recognised{i,6} = Recognised {i};
    end
end

MX_LL_Preds_Unrecognised = cell(length(participants),4);
for i = participants
    MX_LL_Preds_Unrecognised{i,1} = -1;
    MX_LL_Preds_Unrecognised{i,2} = 0;
    while (MX_LL_Preds_Unrecognised{i,2} == 0 || MX_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest] = FitMix(Unrecognised {i});
        MX_LL_Preds_Unrecognised{i,1} = ll;
        MX_LL_Preds_Unrecognised{i,2} = bic;
        MX_LL_Preds_Unrecognised{i,3} = Pred;
        MX_LL_Preds_Unrecognised{i,4} = pest;
        % MX_LL_Preds_Unrecognised{i,5} = Gstuff;
        % MX_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
    end
end

%% Fit VP + Mix Model

HY_LL_Preds_Recognised = cell(length(participants),4);
for i = participants
    HY_LL_Preds_Recognised{i,1} = -1;
    HY_LL_Preds_Recognised{i,2} = 0;
    while (HY_LL_Preds_Recognised{i,2} == 0 || HY_LL_Preds_Recognised{i,1} < 0)
	disp('Hybrid')
	disp(i)
        [ll, bic, Pred, pest] = FitVPMix(Recognised {i});
        HY_LL_Preds_Recognised{i,1} = ll;
        HY_LL_Preds_Recognised{i,2} = bic;
        HY_LL_Preds_Recognised{i,3} = Pred;
        HY_LL_Preds_Recognised{i,4} = pest;
        % HY_LL_Preds_Recognised{i,5} = Gstuff;
        % HY_LL_Preds_Recognised{i,6} = Recognised {i};
    end
end

HY_LL_Preds_Unrecognised = cell(length(participants),4);
for i = participants
    HY_LL_Preds_Unrecognised{i,1} = -1;
    HY_LL_Preds_Unrecognised{i,2} = 0;
    while (HY_LL_Preds_Unrecognised{i,2} == 0|| HY_LL_Preds_Unrecognised{i,1} < 0)
        [ll, bic, Pred, pest] = FitVPMix(Unrecognised {i});
        HY_LL_Preds_Unrecognised{i,1} = ll;
        HY_LL_Preds_Unrecognised{i,2} = bic;
        HY_LL_Preds_Unrecognised{i,3} = Pred;
        HY_LL_Preds_Unrecognised{i,4} = pest;
        % HY_LL_Preds_Recognised{i,5} = Gstuff;
        % HY_LL_Preds_Recognised{i,6} = Unrecognised {i};
    end
end

save('CritVarFits')

%% Plot Fits superimposed on Data, and save.
% % Plot
for i = participants
    filename = ['Cont_Recog',num2str(i),'.png'];
    fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);

    filename = ['Cont_Unrecog',num2str(i),'.png'];
    fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
    saveas(gcf,filename);

    filename = ['Thresh_Recog',num2str(i),'.png'];
    fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);

    filename = ['Thresh_Unrecog',num2str(i),'.png'];
    fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
    saveas(gcf,filename);

    filename = ['Hybrid_Recog',num2str(i),'.png'];
    fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);

    filename = ['Hybrid_Unrecog',num2str(i),'.png'];
    fitplot(Unrecognised {i}, HY_LL_Preds_Unrecognised{i,3});
    saveas(gcf,filename);
end


%%
%%% The thing I want at the end is...
% full_data = open_data(filename)
% data = split_data(full_data)
% fit_data(data, starting_preds)
% plot_data_preds(plot_filename, data, preds)
