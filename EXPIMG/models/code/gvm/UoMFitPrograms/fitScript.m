
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

participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
%participants = [1,5,11,18];
%% Fit Variable Precision (Continuous model)

% %Empty array for Log Likelihoods and Predictions to live.

%Empty array for Log Likelihoods and Predictions to live.
GVM_LL_Preds_Recognised = cell(length(participants),4);
for i = participants
    GVM_LL_Preds_Recognised{i,1} = -1; %sometimes log likelihood goes negative. re-run if this happens
    GVM_LL_Preds_Recognised{i,2} = 0; %make it automatically repeat if BIC is zero (fminsearch blew up)
    while (GVM_LL_Preds_Recognised{i,2} == 0 || GVM_LL_Preds_Recognised{i,1} < 0)
        [ll, bic, Pred, pest, Gstuff] = fitGVM(Recognised {i},i);
        GVM_LL_Preds_Recognised{i,1} = ll;
        GVM_LL_Preds_Recognised{i,2} = bic;
        GVM_LL_Preds_Recognised{i,3} = Pred;
        GVM_LL_Preds_Recognised{i,4} = pest;
        GVM_LL_Preds_Recognised{i,5} = Gstuff;
        GVM_LL_Preds_Recognised{i,6} = Recognised {i};
        fitplot(Recognised {i}, GVM_LL_Preds_Recognised{i,3});
    end
end
    
    % %% Plot Fits superimposed on Data, and save.
    % % Plot
    % fitplot(Recognised {1}, Pred);
    
    
    %% Unrecognised
    
    GVM_LL_Preds_Unrecognised = cell(length(participants),6);
    for i = participants
        [ll, bic, Pred, pest, Gstuff] = fitGVM(Unrecognised {i},i);
        GVM_LL_Preds_Unrecognised{i,1} = ll;
        GVM_LL_Preds_Unrecognised{i,2} = bic;
        GVM_LL_Preds_Unrecognised{i,3} = Pred;
        GVM_LL_Preds_Unrecognised{i,4} = pest;
        GVM_LL_Preds_Unrecognised{i,5} = Gstuff;
        GVM_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
    end
       
    save('NoCritPVM')
    %% Plot
%     
    for i = participants
        
%         filename = ['GVM_UnrecogCrit',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
%         fitplot(Unrecognised {i}, GVM_LL_Preds_Unrecognised{i,3});
%         saveas(gcf,filename);
%         
        filename = ['PVM_NoCrit',num2str(i),'_',datestr(now,'dd_mm_yy_HH_MM'),'.png'];
        fitplot(Recognised {i}, GVM_LL_Preds_Recognised{i,3});
        saveas(gcf,filename);
        
    end
    
    save('NoCritPVM')
    close all
% %     
    %%
    %%% The thing I want at the end is...
    % full_data = open_data(filename)
    % data = split_data(full_data)
    % fit_data(data, starting_preds)
    % plot_data_preds(plot_filename, data, preds)
