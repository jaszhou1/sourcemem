
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
%% Fit Variable Precision (Continuous model)

% %Empty array for Log Likelihoods and Predictions to live.

%Empty array for Log Likelihoods and Predictions to live.
Fixed_Preds = cell(length(participants),5);
for i = participants
[ll, bic, Pred, pest, Gstuff] = fitGVM_fixed(Recognised {i}, i);
Fixed_Preds{i,1} = ll;
Fixed_Preds{i,2} = bic;
Fixed_Preds{i,3} = Pred;
Fixed_Preds{i,4} = pest;
Fixed_Preds{i,5} = Gstuff;
Fixed_Preds{i,6} = Recognised{i,1}; %the data
end

save("gvmHigh_GSTUFF")


%%
%%% The thing I want at the end is...
% full_data = open_data(filename)
% data = split_data(full_data)
% fit_data(data, starting_preds)
% plot_data_preds(plot_filename, data, preds)