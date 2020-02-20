function [ll,bic,Pred,Gstuff] = fitmixture4wrap(Pvar, Pfix, Sel, Data)
  nlow = length(Data{1,1});
  nhigh = length(Data{1,2});
  [ll,bic,Pred,Gstuff] = fitmixture4x(Pvar, Pfix, Sel, Data, nlow, nhigh, 5);

end