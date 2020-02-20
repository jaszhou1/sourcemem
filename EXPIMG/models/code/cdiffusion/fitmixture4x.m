function [ll,bic,Pred, Gstuff, penalty, pest_penalty] = fitmixture4x(Pvar, Pfix, Sel, Data, nlow, nhigh, badix, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
% Across-trial variability in criterion.
% Mixture of memory based and guessing based process with different 
% criteria. Assumes the eta components in the x and y directions are the
% same.
%    [ll,bic,Pred] = fitmixture4x(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter  st sa]
%          1    2    3    4    5      6    7   8   9   10    11  12 13
%    a1, a2 are criteria for memory and guessing process, pi1, pi2 are 
%    mixing proportions for long and short.
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITMIXTURE4X: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 5.1; 
np = 13;
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
%This affects the leading edge of the model RT predictions. If criterion is
%high, then badix should increase to avoid big discontinuity at quick RT
%badix = 5; %default is 5


if nargin < 8 %putting badix in arguments to be handed in
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
st = P(12);
sa = P(13);


% Components of drift variability.
eta1a = eta1;
eta2a = eta1;
eta1b = eta2;
eta2b = eta2;
sigma = 1.0;

% Cleaned up penalty calculation, hard and soft bounds - 30/1/19
penalty = 0;
% ---------------------------------------------------------------------------
%   v1a, v2a, v1b, v2b, eta1, eta2,      a1, a2,       pi1, pi2,    Ter  st, sa]
% ---------------------------------------------------- ----------------------
 
Ub= [ 4.5*ones(1,4),  1*ones(1,2),  5*ones(1,2),    ones(1,2),   1.0, 0.8, 0]; 
Lb= [0*ones(1,4),  0*ones(1,2),  0.3*ones(1,2),    zeros(1,2),   -0.5, 0, 0];
Pub=[ 4.0*ones(1,4),  0.7*ones(1,2),  4.5*ones(1,2), 1*ones(1,2),  0.8, 0.7, 0]; 
Plb=[0*ones(1,4),  0*ones(1,2),  0.4*ones(1,2), 0.01*ones(1,2), -0.4, 0, 0];
Pred = cell(1,4);
if any(P - Ub > 0) | any(Lb - P > 0)
   ll = 1e7 + ...
        1e3 * (sum(max(P - Ub, 0).^2) + sum(max(Lb - P, 0).^2));
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
end   

% Saving the full vector of parameters and an indication of whether or not
% a penalty was applied.
pest_penalty(1,:) = P;
pest_penalty(2,:) = max(P - Pub, 0).^2 + max(Plb - P, 0).^2;
% Ensure etas, ter, and a are positive.
% Removed Ter from being considered as we are allowing Ter to be negative.
%lowerbounderror = sum(min(P(5:length(P)) - zeros(1,length(P)-4), 0).^2);
lowerbounderror = sum(min(P(5:10) - zeros(1,length(P)-7), 0).^2);
if lowerbounderror > 0
   ll = 1e5 + 1e3 * lowerbounderror;
   bic = 0;
   Gstuff = cell(3,2);
% elseif sa / 2 >= a1 Commented out as a1 == 0 for no criteria variability
%     disp('Criterion range error')
%     ll = 1e5;
%     bic = 0;
%     Gstuff = cell(3,2);
else
   if sa < epsilon % No criterion variability
       % Memory-based process
       % Parameters for long
       Pa = [v1a, v2a, eta1a, eta2a, sigma, a1];
       % Parameters for short
       Pb = [v1b, v2b, eta1b, eta2b, sigma, a1];
       [ta, gta, thetaa, pthetaa, mta] = vdcircle300cls(Pa, tmax, badix);
       [tb, gtb, thetab, pthetab, mtb] = vdcircle300cls(Pb, tmax, badix);
   else  % Criterion variability
       % Rectangular mass for starting point variability.
       U = ones(n_sz_step, 1); 
       Rmass = U / n_sz_step ; 
       Rstep = [-(n_sz_step-1)/2:(n_sz_step-1)/2]' / (n_sz_step-1); 
       A = a1 + Rstep * sa;
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
   
   % --------------------
   % Convolve with Ter(Added from fitgvm, 07/05)
   % --------------------
   h = ta(2) - ta(1);
   if st > 2 * h
       m = round(st/h);
       n = length(ta);
       fe = ones(1, m) / m;
       for i = 1:nw + 1
           gti = conv(gtlong(i, :), fe);
           gtlong(i,:) = gti(1:n);
           gti = conv(gtshort(i, :), fe);
           gtshort(i,:) = gti(1:n);
       end
   end
   
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
  
   
  % Pass out joint density for use in quantile plot 
   Gstuff = cell(3,2);
   Gstuff{1,1} = ta;
   Gstuff{2,1} = thetaa;
   Gstuff{3,1} = gtlong;
   Gstuff{1,2} = tb;
   Gstuff{2,2} = thetab;
   Gstuff{3,2} = gtshort;
  
   
   
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


