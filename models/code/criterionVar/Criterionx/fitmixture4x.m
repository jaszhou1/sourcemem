function [ll,bic,Pred] = fitmixture4x(Pvar, Pfix, Sel, Data, nlow, nhigh, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
% Across-trial variability in criterion.
% Mixture of memory based and guessing based process with different 
% criteria. Assumes the eta components in the x and y directions are the
% same.
%    [ll,bic,Pred] = fitmixture4x(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter  sa]
%          1    2    3    4    5      6    7   8   9   10    11  12
%    a1, a2 are criteria for memory and guessing process, pi1, pi2 are 
%    mixing proportions for long and short.
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITMIXTURE4X: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 3.0; 
np = 12;
nt = 300;
%nshort and n long changed to nlow and nhigh, values now handed in rather than
%being fixed

n_sz_step =  11; % Criterion variability.
epsx = 1e-9;
epsilon = 0.0001;
cden = 0.05;  % Contaminant density.

nw = 50;
w = 2 * pi / nw; 
%h = tmax / 300; 

% Set manually if needed - 30/1/19
badix = 5; 


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

v1a = P(1);
v2a = P(2);
v1b = P(3);
v2b = P(4);
eta1 = P(5);
eta2 = P(6);
a1 = P(7);
a2 = P(8);
pi1 = P(9);
pi2 = P(10); 
ter = P(11);
sz = P(12);


% Components of drift variability.
eta1a = eta1;
eta2a = eta1;
eta1b = eta2;
eta2b = eta2;
sigma = 1.0;

% Cleaned up penalty calculation, hard and soft bounds - 30/1/19

% ---------------------------------------------------------------------------
%   v1a, v2a, v1b, v2b, eta1, eta2,      a1, a2,       pi1, pi2,    Ter  sa]
% ---------------------------------------------------- ----------------------
 
Ub= [ 7.0*ones(1,4),  4.0*ones(1,2),  5.0*ones(1,2),    ones(1,2),   1.0,  3.0]; 
Lb= [-7.0*ones(1,4),  0.0*ones(1,2),  0.5*ones(1,2),    zeros(1,2),   0,     0];
Pub=[ 6.5*ones(1,4),  3.5*ones(1,2),  4.5*ones(1,2), 0.9*ones(1,2),  0.8,  2.8]; 
Plb=[-6.5*ones(1,4),  0.0*ones(1,2),  0.7*ones(1,2), 0.05*ones(1,2), 0.01, 0.1];
Pred = cell(1,4);
if any(P - Ub > 0) | any(Lb - P > 0)
   ll = 1e7 + ...
        1e3 * (sum(max(P - Ub, 0).^2) + sum(max(Ub - P).^2));
   bic = 0;
   return
   if trace
       max(P - Ub, 0)
       max(Lb - P, 0)
   end
else
   penalty =  1e3 * (sum(max(P - Pub, 0).^2) + sum(max(Plb - P, 0).^2));
   if trace
       max(P - Pub, 0)
       max(Plb - P, 0)
        penalty
   end
end   

% Ensure etas, ter, and a are positive.
lowerbounderror = sum(min(P(5:length(P)) - zeros(1,length(P)-4), 0).^2);
if lowerbounderror > 0
   ll = 1e5 + 1e3 * lowerbounderror;
   bic = 0;
elseif sz / 2 >= a1
    disp('Criterion range error')
    ll = 1e5;
    bic = 0;
else
   if sz < epsilon % No criterion variability
       % Memory-based process
       % Parameters for long
       Pa = [v1a, v2a, eta1a, eta2a, sigma, a1];
       % Parameters for short
       Pb = [v1b, v2b, eta1b, eta2b, sigma, a1];
       [ta, gta, thetaa, pthetaa, mta] = vdcircle300cls(Pa, tmax, 5);
       [tb, gtb, thetab, pthetab, mtb] = vdcircle300cls(Pb, tmax, 5);
   else  % Criterion variability
       % Rectangular mass for starting point variability.
       U = ones(n_sz_step, 1); 
       Rmass = U / n_sz_step ; 
       Rstep = [-(n_sz_step-1)/2:(n_sz_step-1)/2]' / (n_sz_step-1); 
       A = a1 + Rstep * sz;
       gta = zeros(nw+1, nt+1);
       gtb = zeros(nw+1, nt+1);
       pthetaa = zeros(1, nw+1);
       pthetab = zeros(1, nw+1);
       mta = zeros(1, nw+1);
       mtb = zeros(1, nw+1);
       for i = 1:n_sz_step
           Pai = [v1a, v2a, eta1a, eta2a, sigma, A(i)];
           Pbi = [v1b, v2b, eta1b, eta2b, sigma, A(i)];
           [ta, gtai, thetaa, pthetaai, mtai] = vdcircle300cls(Pai, tmax, badix);
           [tb, gtbi, thetab, pthetabi, mtbi] = vdcircle300cls(Pbi, tmax, badix);         
           gta = gta + gtai;
           gtb = gtb + gtbi;
           pthetaa = pthetaa + pthetaai; 
           pthetab = pthetab + pthetabi;
           mta = mta + pthetaai .* mtai;
           mtb = mtb + pthetabi .* mtbi;
      end
      gta = gta / n_sz_step;
      gtb = gtb / n_sz_step;
      mta = mta ./ pthetaa;
      mtb = mtb ./ pthetab;
      pthetaa = pthetaa / n_sz_step;
      pthetab = pthetab / n_sz_step;
   end;
   % Parameters for guessing process - zero drift, different criterion
   Pc = [0, 0, 0, 0, sigma, a2];
   Pd = [0, 0, 0, 0, sigma, a2];
   [tc, gtc, thetac, pthetac, mtc] = vdcircle300cls(Pc, tmax, badix);
   [td, gtd, thetad, pthetad, mtd] = vdcircle300cls(Pd, tmax, badix);
 
  % Mixture of memory-based processes and guesses
   gtlong =  pi1 * gta + (1 - pi1) * gtc;
   gtshort = pi2 * gtb + (1 - pi2) * gtd;
   pthetalong =  pi1 * pthetaa + (1 - pi1) * pthetac;
   pthetashort = pi2 * pthetab + (1 - pi2) * pthetad;

   % Filter zeros
   gtlong = max(gtlong, epsx);
   gtshort = max(gtshort, epsx);
   % Add nondecision times
   ta = ta + ter;
   tb = tb + ter;
   % Create mesh for interpolation
   [anglea,timea]=meshgrid(ta, thetaa);
   [angleb,timeb]=meshgrid(tb, thetab);
   % Interpolate in joint density to get likelihoods of each data point.
   % 1 is long, 2 is short
   l0a = interp2(anglea, timea, gtlong,  Data{1}(:,2),Data{1}(:,1), 'linear');
   l0b = interp2(angleb, timeb, gtshort, Data{2}(:,2),Data{2}(:,1), 'linear');

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
   gtam = sum(gtlong) * w;
   gtbm = sum(gtshort) * w;
   Pgta = [ta;gtam];
   Pgtb = [tb;gtbm];
   Ptha = [thetaa;pthetalong];
   Pthb = [thetab;pthetashort];
   Pred{1} = Pgta;
   Pred{2} = Pgtb;
   Pred{3} = Ptha;
   Pred{4} = Pthb;
end


