load('groupData3.mat');

VP_LL_Preds_Recognised = cell(1,4);
[ll, bic, Pred, pest] = FitVPx(groupRecognised);
VP_LL_Preds_Recognised{1,1} = ll;
VP_LL_Preds_Recognised{1,2} = bic;
VP_LL_Preds_Recognised{1,3} = Pred;
VP_LL_Preds_Recognised{1,4} = pest;

% 
% VP_LL_Preds_Unrecognised = cell(1,4);
% 
% [ll, bic, Pred, pest] = FitVPx(groupUnrecognised);
% VP_LL_Preds_Unrecognised{1,1} = ll;
% VP_LL_Preds_Unrecognised{1,2} = bic;
% VP_LL_Preds_Unrecognised{1,3} = Pred;
% VP_LL_Preds_Unrecognised{1,4} = pest;
%% Fit Mixture Model (Threshold model)

MX_LL_Preds_Recognised = cell(1,4);

[ll, bic, Pred, pest] = FitMixX(groupRecognised);
MX_LL_Preds_Recognised{1,1} = ll;
MX_LL_Preds_Recognised{1,2} = bic;
MX_LL_Preds_Recognised{1,3} = Pred;
MX_LL_Preds_Recognised{1,4} = pest;

% 
% MX_LL_Preds_Unrecognised = cell(1,4);
% 
% [ll, bic, Pred, pest] = FitMixX(groupUnrecognised);
% MX_LL_Preds_Unrecognised{1,1} = ll;
% MX_LL_Preds_Unrecognised{1,2} = bic;
% MX_LL_Preds_Unrecognised{1,3} = Pred;
% MX_LL_Preds_Unrecognised{1,4} = pest;
% 
