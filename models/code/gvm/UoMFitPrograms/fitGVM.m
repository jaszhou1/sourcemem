function [ll, bic, Pred, pest] = fitGVM(data)
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
setopt;

% nunorm1 = normrnd(2,1.5);
% nunorm2 = normrnd(2,1.5);
% kappa1 = normrnd(5,2);
% kappa2 = normrnd(5,2);
% eta = normrnd(0.5, 0.2);
% rho = normrnd(0.5,0.2);
% a = normrnd(3,0.5);
% Ter = normrnd(-0.2,0.3);
% st = normrnd(0.05,0.1);
% sa = 0;
%sa = normrnd(1,0.8);
P = [2.48635633531635,2.50657983082597,0.329211490420301,0.788896541814084,1.02507162664465,0.105044258602163,2.11612703760500,-0.271300468914334,0.0785703065442259,0.182082253457239];


%P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa];

Sel = [0,0,0,0,0,0,0,0,0,0];  % all parameters free
nlow = length(data{1,1});
nhigh = length(data{1,2});

pest = fminsearch(@fitgvm6x, P(Sel==1), options, P(Sel==0), Sel, data, nlow, nhigh);
P(Sel==1) = pest;
[ll,bic,Pred] = fitgvm6x(P(Sel==1), P(Sel==0), Sel, data, nlow, nhigh); %Criterion Range Error
%fitplot(D11, Pred);
end
