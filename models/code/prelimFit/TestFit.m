%testing fitting continuous (VP) model to EXPIMG data
setopt;
%Starting parameters for P?)
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1a, eta2a, eta1b, eta2b, a, Ter]
%          1    2    3    4     5      6      7      8    9   10
v1a = 1;
v2a = 0.01;
v1b = 1.5;
v2b = 0.01;
eta1a = 1.5;
eta2a = 0.5;
eta1b = 1.5;
eta2b = 0.1;
a = 1.25;
Ter = 0.15;



P = [v1a, v2a, v1b, v2b, eta1a, eta2a, eta1b, eta2b, a, Ter];

Sel = ones(1,10);
pest = fminsearch(@fitdcircle, P(Sel==1), options, P(Sel==0), Sel, D2);

P(Sel== 1) = pest; 
[ll,bic,Pred] = fitdcircle(P(Sel==1), P(Sel==0), Sel, D2);
fitplot(D2, Pred);
