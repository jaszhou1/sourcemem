function [ll, bic, Pred, pest, Gstuff] = troubleshoot(data, inputcell)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter, st, sa]
%          1    2    3    4    5      6    7   8   9   10    11  12  13
badix = 5;
pest = inputcell{2,4};
P = pest;

Sel = [1,1,1,1,1,1,1,1,1,1,1,1,1];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

[ll,bic,Pred, Gstuff] = fitmixture4x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh, badix); %Criterion Range Error
%[tll, tbic, tPred, tpest, tGstuff] = troubleshoot(Recognised {2},HY_LL_Preds_Recognised);
end
