%I want to fit the VP and Mixture Circular Diffusion models to the data
%from EXPIMG.

%% Open Data

%Opens and organises the data into recognised/unrecognised and low/high imageability
Fit_Data = importR('stimulus.xlsx'); 
%Fit the data, generate predictions.
participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];
%% Fit Variable Precision (Continuous model)

%Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds = cell(length(participants),3);
for i = participants
[ll, bic, Pred] = FitVP(Fit_Data{i});
VP_LL_Preds{i,1} = ll;
VP_LL_Preds{i,2} = bic;
VP_LL_Preds{i,3} = Pred;
end

%% Fit Mixture Model (Threshold model)

%Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds = cell(length(participants),3);
for i = participants
[ll, bic, Pred] = FitMix(Fit_Data{i});
MX_LL_Preds{i,1} = ll;
MX_LL_Preds{i,2} = bic;
MX_LL_Preds{i,3} = Pred;
end

%% Plot Fits superimposed on Data, and save.
% Plot 
%fitplot(Recognised {1}, Pred);
% for i = participants
%     filename = ['VP_Recog',num2str(i),'.png'];
%     fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['VP_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['MX_Recog',num2str(i),'.png'];
%     fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['MX_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
% end    


%%
%%% The thing I want at the end is...
% full_data = open_data(filename)
% data = split_data(full_data)
% fit_data(data, starting_preds)
% plot_data_preds(plot_filename, data, preds)