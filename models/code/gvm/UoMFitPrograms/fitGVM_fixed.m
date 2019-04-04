function [ll, bic, Pred, pest, Gstuff] = fitGVM_fixed(P,data, i)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
%setopt;Dont need when not fitting?

%load('gvmfit_nocrit7.mat'); %the problem with this is that it will overwrite i etc.
%moved to higher level script.


%P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa];
%P = GVM_LL_Preds_Recognised{i,4};
%P(1,10) = 0; %so the number of parameters is correct for Sel
Sel = [1,1,1,1,1,1,1,1,1,1];  % all parameters free
%Sel = [0,0,0,0,0,0,0,0,0,0]; %all parameters fixed
nlow = length(data{1,1});
nhigh = length(data{1,2});

%pest = fminsearch(@fitgvm6x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
%P(Sel==1) = pest;
pest = P;
[ll,bic,Pred, Gstuff] = fitgvm6x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh);

%    filename = ['GVM_QxQ',num2str(i),'.png'];
%    qplotsrc(@fitmixture6x, P(Sel==1), P(Sel==0), Sel, data)
%    saveas(gcf,filename);

end
