%Load Model Parameter Estimates
load ('gvmfit_nocrit6.mat');

%Load in data
Fit_Data = Treatment_Simple;

Recognised = Fit_Data(:,1);
Unrecognised = Fit_Data(:,2);
participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];


i = 2;
data = Recognised{i};
% for i = participants
P = GVM_LL_Preds_Recognised{i, 4};
% P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa];
P(1,10) = 0; %TURN THIS OFF 
Sel = [1,1,1,1,1,1,1,1,1,0];  % all parameters free
%Sel = [0,0,0,0,0,0,0,0,0,0]; %all parameters fixed
nlow = length(data{1,1});
nhigh = length(data{1,2});
%     
% end
qplotsrc(@fitgvm6x, P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh)