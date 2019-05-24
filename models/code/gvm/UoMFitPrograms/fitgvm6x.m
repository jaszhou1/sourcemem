function [ll,bic,Pred, Gstuff] = fitgvm6x(Pvar, Pfix, Sel, Data, nlow, nhigh, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
% gvm with criterion variability and normal radial variability
%
%    [ll,bic,Pred, Gstuff] = fitgvm6x(Pvar, Pfix, Sel, Data)
%     P=[nunorm1, nunorm2, kappa1, kappa2, eta, rho, a, Ter, st, sa]
%          1        2        3        4     5    6   7   8   9   10
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITGVM4X: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 5.1; 
n_sa_step =  11; % Criterion variability.
np = 10;
nt = 300;
% nlow = 320;
% nhigh = 360;
epsx = 1e-9;
epsilon = 0.0001;
cden = 0.05;  % Contaminant density.

nw = 50;
w = 2 * pi / nw; 
%h = tmax / 300; 

% Set manually if needed - 30/1/19
badix = 2; 


if nargin < 7
    trace = 0;
end;
lp = length(Pvar) + length(Pfix);
if lp ~= np
     [name, errmg1], length(Pvar), length(Pfix), return;
end
if length(Sel) ~= np
     [name, errmg2], length(Sel), return;
end
if size(Data) ~= [1,2]
     [name, errmg3], size(Data), return;
end     
   
% Assemble parameter vector.
P = zeros(1,np);
P(Sel==1) = Pvar;
P(Sel==0) = Pfix;

% Save on each iteration - 30/1/19
Ptemp = P;
save Ptemp Ptemp


nunorm1 = P(1);
nunorm2 = P(2);
kappa1 = P(3);
kappa2 = P(4);
eta = P(5);
rho = P(6);
a = P(7);
ter = P(8);
st = P(9);
sa = P(10);
sigma = 1.0;
phi = 0; % Phase angle, all in canonical orientation.

% Cleaned up penalty calculation, hard and soft bounds - 30/1/19

% ----------------------------------------------------------------
%   nunorm1, nunorm2, kappa1, kappa2, eta rho, a,    ter, st     sa
% ----------------------------------------------------------------
 
Ub= [ 7.0*ones(1,2), 11.0*ones(1,2),  4.5,  1.5, 5.0,  1.0, 0.7,  2*a]; 
%Lb= [   0*ones(1,2),  0.0*ones(1,2),    0, 0.02, 0.5, -0.35,  0     0];
Lb= [   0*ones(1,2),  0.0*ones(1,2),    0, 0.01, 0.5, -0.35,  0     0];
Pub=[ 6.5*ones(1,2), 10.5*ones(1,2),  4.0, 1.3, 4.5,  0.8, 0.65, 2*a - .02];
Plb=[0.01*ones(1,2),  0.1*ones(1,2), 0.01, 0.03, 0.7,  -0.40, 0.01,  0];
Pred = cell(1,4);
if any(P - Ub > 0) | any(Lb - P > 0)
   ll = 1e7 + ...
        1e3 * (sum(max(P - Ub, 0).^2) + sum(max(Ub - P).^2));
   bic = 0;
   Gstuff = cell(3,2);
   if trace
       max(P - Ub, 0)
       max(Lb - P, 0)
   end
   return
else
    penalty =  1e3 * (sum(max(P - Pub, 0).^2) + sum(max(Plb - P, 0).^2));
    if trace
       max(P - Pub, 0)
       max(Plb - P, 0)
        penalty
    end
    if sa < epsilon
        Pa=[nunorm1, kappa1, eta, phi rho, sigma, a];
        % Parameters for long
        Pb=[nunorm2, kappa2, eta, phi, rho, sigma, a];
        % Parameters for short
        [ta, gta, thetaa, pthetaa, mta] = vgvm300(Pa, tmax,badix);
        [tb, gtb, thetab, pthetab, mtb] = vgvm300(Pb, tmax, badix);
    else
        % Rectangular mass for starting point variability.
        U = ones(n_sa_step, 1); 
        Rmass = U / n_sa_step ; 
        Rstep = [-(n_sa_step-1)/2:(n_sa_step-1)/2]' / (n_sa_step-1); 
        A = a + Rstep * sa - sa / 2;
        gta = zeros(nw+1, nt);
        gtb = zeros(nw+1, nt);
        pthetaa = zeros(1, nw+1);
        pthetab = zeros(1, nw+1);
        mta = zeros(1, nw+1);
        mtb = zeros(1, nw+1);
        for i = 1:n_sa_step
            Pai=[nunorm1, kappa1, eta, phi rho, sigma, A(i)];
            Pbi=[nunorm2, kappa2, eta, phi, rho, sigma, A(i)];
            [ta, gtai, thetaa, pthetaai, mtai] = vgvm300(Pai, tmax, badix);
            [tb, gtbi, thetab, pthetabi, mtbi] = vgvm300(Pbi, tmax, badix);         
            gta = gta + gtai;
            gtb = gtb + gtbi;
            pthetaa = pthetaa + pthetaai; 
            pthetab = pthetab + pthetabi;
            mta = mta + pthetaai .* mtai;
            mtb = mtb + pthetabi .* mtbi;
       end
       gta = gta / n_sa_step;
       gtb = gtb / n_sa_step;
       mta = mta ./ pthetaa;
       mtb = mtb ./ pthetab;
       pthetaa = pthetaa / n_sa_step;
       pthetab = pthetab / n_sa_step;
   end;
 
   % Filter zeros
   gta = max(gta, epsx);
   gtb = max(gtb, epsx);


   % Add nondecision times
   %ta = ta + ter + st / 2;
   %tb = tb + ter + st / 2;
   % Alt parameteriziation
   ta = ta + ter;
   tb = tb + ter;

   % --------------------
   % Convolve with Ter.
   % --------------------
   h = ta(2) - ta(1);
   if st > 2 * h
       m = round(st/h);
       n = length(ta);
       fe = ones(1, m) / m;
       for i = 1:nw + 1
           gti = conv(gta(i, :), fe);
           gta(i,:) = gti(1:n);
           gti = conv(gtb(i, :), fe);
           gtb(i,:) = gti(1:n);
       end
    end

  % Pass out joint density for use in quantile plot 
   Gstuff = cell(3,2);
   Gstuff{1,1} = ta;
   Gstuff{2,1} = thetaa;
   Gstuff{3,1} = gta;
   Gstuff{1,2} = tb;
   Gstuff{2,2} = thetab;
   Gstuff{3,2} = gtb;

   % Create mesh for interpolation
   [anglea,timea]=meshgrid(ta, thetaa);
   [angleb,timeb]=meshgrid(tb, thetab);
   % Interpolate in joint density to get likelihoods of each data point.
   % 1 is long, 2 is short
   l0a = interp2(anglea, timea, gta,  Data{1}(:,2),Data{1}(:,1), 'linear');
   l0b = interp2(angleb, timeb, gtb,  Data{2}(:,2),Data{2}(:,1), 'linear');

   % Out of range values returned as NaN's. Treat as contaminants - set small.
   ixa = isnan(l0a);
   l0a(ixa) = cden;
   ixb = isnan(l0b);
   l0b(ixb) = cden;
   % Log-likelihoods.
   ll0a = log(l0a);
   ll0b = log(l0b);
   % Minimize sum of minus LL's across two conditions. Added penalty term 30/1/19
   ll = sum(-ll0a) + sum(-ll0b) + penalty;
   bic = 2 * ll + sum(Sel) * log(nhigh + nlow);
   if trace > 1
      Vala = [Data{1}, l0a, ixa]
      Valb = [Data{2}, l0b, ixb]
   end

   % Predictions for plot
   gtam = sum(gta) * w;
   gtbm = sum(gtb) * w;
   Pgta = [ta;gtam];
   Pgtb = [tb;gtbm];
   Ptha = [thetaa;pthetaa];
   Pthb = [thetab;pthetaa];
   Pred{1} = Pgta;
   Pred{2} = Pgtb;
   Pred{3} = Ptha;
   Pred{4} = Pthb;
end


