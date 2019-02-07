load('groupData.mat');

VP_LL_Preds_Recognised = cell(1,4);
[ll, bic, Pred, pest] = FitVPx(Recognised {i});
VP_LL_Preds_Recognised{i,1} = ll;
VP_LL_Preds_Recognised{i,2} = bic;
VP_LL_Preds_Recognised{i,3} = Pred;
VP_LL_Preds_Recognised{i,4} = pest;


