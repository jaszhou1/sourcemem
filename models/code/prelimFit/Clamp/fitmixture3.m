function [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data, nlow, nhigh) %unsure what trace does
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
% Mixture of memory based and guessing based process with different 
% criteria. Assumes the eta components in the x and y directions are the
% same.
%    [ll,bic,Pred] = fitmixture3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a1, a2, pi1, pi2, Ter]
%          1    2    3    4    5      6    7   8   9   10    11
%    a1, a2 are criteria for memory and guessing process, pi1, pi2 are 
%    mixing proportions for long and short.
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITMIXTURE3: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 3.0; 
np = 11;
% nlow = 280;
% nhigh = 280;
epsx = 1e-9;
cden = 0.05;  % Contaminant density.
% These used by Matlab version of vdcircle by not the C version.
nw = 50;
h = tmax / 300; 
w = 2 * pi / nw; 
 

if nargin < 5
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

% Components of drift variability.
eta1a = eta1;
eta2a = eta1;
eta1b = eta2;
eta2b = eta2;

sigma = 1.0;

% Ensure etas, ter, and a are positive.
lowerbounderror = sum(min(P(5:length(P)) - zeros(1,length(P)-4), 0).^2);
if lowerbounderror > 0
   ll = 1e5 + 1e3 * lowerbounderror;
   bic = 0;
else
   % Parameters for long
   Pa = [v1a, v2a, eta1a, eta2a, sigma, a1];
   % Parameters for short
   Pb = [v1b, v2b, eta1b, eta2b, sigma, a1];

   % Parameters for guessing process - zero drift, different criterion
   Pc = [0, 0, 0, 0, sigma, a2];
   Pd = [0, 0, 0, 0, sigma, a2];

   % Slow code uses Matlab (Need C for vdcircle300) 
   [ta, gta, thetaa, pthetaa, mta] = vdcircle3(Pa, nw, h, tmax, 5);
   [tb, gtb, thetab, pthetab, mtb] = vdcircle3(Pb, nw, h, tmax, 5);
   [tc, gtc, thetac, pthetac, mtc] = vdcircle3(Pc, nw, h, tmax, 5);
   [td, gtd, thetad, pthetad, mtd] = vdcircle3(Pd, nw, h, tmax, 5);
 
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
   % Minimize sum of minus LL's across two conditions.
   ll = sum(-ll0a) + sum(-ll0b);
   bic = 2 * ll + sum(Sel) * log(nhigh + nlow);

   %What does this do? When i try to add more input arguments into this
   %function, it breaks because of trace, yet as far as I can tell, it was
   %never handed in the first place, but still worked in earlier versions
   %    if trace       
%       Vala = [Data{1}, l0a, ixa]
%       Valb = [Data{2}, l0b, ixb]
%    end

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
