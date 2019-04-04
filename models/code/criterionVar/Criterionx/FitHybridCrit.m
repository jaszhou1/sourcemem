
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
% %% Fit Variable Precision (Continuous model)
% 
% % %Empty array for Log Likelihoods and Predictions to live.
VP_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
[ll, bic, Pred, pest, Gstuff] = FitVPx(Recognised {i});
VP_LL_Preds_Recognised{i,1} = ll;
VP_LL_Preds_Recognised{i,2} = bic;
VP_LL_Preds_Recognised{i,3} = Pred;
VP_LL_Preds_Recognised{i,4} = pest;
VP_LL_Preds_Recognised{i,5} = Gstuff;
VP_LL_Preds_Recognised{i,6} = Recognised {i};
end

VP_LL_Preds_Unrecognised = cell(length(participants),6);
for i = participants
[ll, bic, Pred, pest,Gstuff] = FitVPx(Unrecognised {i});
VP_LL_Preds_Unrecognised{i,1} = ll;
VP_LL_Preds_Unrecognised{i,2} = bic;
VP_LL_Preds_Unrecognised{i,3} = Pred;
VP_LL_Preds_Unrecognised{i,4} = pest;
VP_LL_Preds_Unrecognised{i,5} = Gstuff;
VP_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
end
% %% Fit Mixture Model (Threshold model)
% 
% %Empty array for Log Likelihoods and Predictions to live.
MX_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
[ll, bic, Pred, pest,Gstuff] = FitMix(Recognised {i});
MX_LL_Preds_Recognised{i,1} = ll;
MX_LL_Preds_Recognised{i,2} = bic;
MX_LL_Preds_Recognised{i,3} = Pred;
MX_LL_Preds_Recognised{i,4} = pest;
MX_LL_Preds_Recognised{i,5} = Gstuff;
MX_LL_Preds_Recognised{i,6} = Recognised {i};
end

MX_LL_Preds_Unrecognised = cell(length(participants),4);
for i = participants
[ll, bic, Pred, pest,Gstuff] = FitMix(Unrecognised {i});
MX_LL_Preds_Unrecognised{i,1} = ll;
MX_LL_Preds_Unrecognised{i,2} = bic;
MX_LL_Preds_Unrecognised{i,3} = Pred;
MX_LL_Preds_Unrecognised{i,4} = pest;
MX_LL_Preds_Unrecognised{i,5} = Gstuff;
MX_LL_Preds_Unrecognised{i,6} = Unrecognised {i};
end

%% Fit VP + Mix Model

HY_LL_Preds_Recognised = cell(length(participants),6);
for i = participants
[ll, bic, Pred, pest,Gstuff] = FitVPMix(Recognised {i});
HY_LL_Preds_Recognised{i,1} = ll;
HY_LL_Preds_Recognised{i,2} = bic;
HY_LL_Preds_Recognised{i,3} = Pred;
HY_LL_Preds_Recognised{i,4} = pest;
HY_LL_Preds_Recognised{i,5} = Gstuff;
HY_LL_Preds_Recognised{i,6} = Recognised {i};
end

HY_LL_Preds_Unrecognised = cell(length(participants),4);
for i = participants
[ll, bic, Pred, pest,Gstuff] = FitVPMix(Unrecognised {i});
HY_LL_Preds_Unrecognised{i,1} = ll;
HY_LL_Preds_Unrecognised{i,2} = bic;
HY_LL_Preds_Unrecognised{i,3} = Pred;
HY_LL_Preds_Unrecognised{i,4} = pest;
HY_LL_Preds_Recognised{i,5} = Gstuff;
HY_LL_Preds_Recognised{i,6} = Unrecognised {i};
end

%% Plot Fits superimposed on Data, and save.
% % Plot 
% for i = participants
%     filename = ['Cont_Recog',num2str(i),'.png'];
%     fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['Cont_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['Thresh_Recog',num2str(i),'.png'];
%     fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['Thresh_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
%
%     filename = ['Hybrid_Recog',num2str(i),'.png'];
%     fitplot(Recognised {i}, HY_LL_Preds_Recognised{i,3});
%     saveas(gcf,filename);
%     
%     filename = ['Hybrid_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, HY_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
% end    
% 

%%
%%% The thing I want at the end is...
% full_data = open_data(filename)
% data = split_data(full_data)
% fit_data(data, starting_preds)
% plot_data_preds(plot_filename, data, preds)