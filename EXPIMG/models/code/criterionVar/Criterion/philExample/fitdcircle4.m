function [ll,bic,Pred] = fitdcircle4(Pvar, Pfix, Sel, Data, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task
% with across-trial variability in criterion
% Assumes the eta components in the x and y directions are the
% same.
%    [ll,bic,Pred] = fitdcircle3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter, sa]
%          1    2    3    4    5      6   7   8   9
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITDCIRCLE4: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 3.0;
nt = 300;
np = 9;
n_sz_step =  11; % Criterion variability.
nlong = 320;
nshort = 360;
epsx = 1e-9;
cden = 0.05;  % Contaminant density.
epsilon = 0.0001;
% These used by Matlab version of vdcircle by not the C version.
nw = 50;
h = tmax / nt; 
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
a= P(7);
ter = P(8);
sa = P(9);
sigma = 1.0;
eta1a = eta1;
eta2a = eta1;
eta1b = eta2;
eta2b = eta2;

% Ensure etas, ter, and a are positive.
lowerbounderror = sum(min(P(5:length(P)) - zeros(1,length(P)-4), 0).^2);
if lowerbounderror > 0
   ll = 1e5 + 1e3 * lowerbounderror;
   bic = 0;
   Pred = [];
else
    % Parameters for long.
    Pa = [v1a, v2a, eta1a, eta2a, sigma, a, ter];
    % Parameters for short.
    Pb = [v1b, v2b, eta1b, eta2b, sigma, a, ter];




   if sz < epsilon % No criterion variability
       % Parameters for long
       Pa = [v1a, v2a, eta1a, eta2a, sigma, a];
       % Parameters for short
       Pb = [v1b, v2b, eta1b, eta2b, sigma, a];
       [ta, gta, thetaa, pthetaa, mta] = vdcircle300cls(Pa, tmax, 5);
       [tb, gtb, thetab, pthetab, mtb] = vdcircle300cls(Pb, tmax, 5);
   else  % Criterion variability
       % Rectangular mass for starting point variability.
       U = ones(n_sz_step, 1); 
       Rmass = U / n_sz_step ; 
       Rstep = [-(n_sz_step-1)/2:(n_sz_step-1)/2]' / (n_sz_step-1); 
       A = a + Rstep * sz;
       gta = zeros(nw+1, nt);
       gtb = zeros(nw+1, nt);
       pthetaa = zeros(1, nw+1);
       pthetab = zeros(1, nw+1);
       mta = zeros(1, nw+1);
       mtb = zeros(1, nw+1);
       for i = 1:n_sz_step
           Pai = [v1a, v2a, eta1a, eta2a, sigma, A(i)];
           Pbi = [v1b, v2b, eta1b, eta2b, sigma, A(i)];
           [ta, gtai, thetaa, pthetaai, mtai] = vdcircle300cls(Pai, tmax, 5);
           [tb, gtbi, thetab, pthetabi, mtbi] = vdcircle300cls(Pbi, tmax, 5);         
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
   % Filter zeros
   gta = max(gta, epsx);
   gtb = max(gtb, epsx);
   %plot(ta, gta);
   % Add nondecision times
   ta = ta + ter;
   tb = tb + ter;
   % Create mesh for interpolation
   [anglea,timea]=meshgrid(ta, thetaa);
   [angleb,timeb]=meshgrid(tb, thetab);

   % Interpolate in joint density to get likelihoods of each data point.
   % 1 is long, 2 is short
   l0a = interp2(anglea, timea, gta, Data{1}(:,2),Data{1}(:,1), 'linear');
   l0b = interp2(angleb, timeb, gtb, Data{2}(:,2),Data{2}(:,1), 'linear');

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
   bic = 2 * ll + sum(Sel) * log(nshort + nlong);
   if trace
      Vala = [Data{1}, l0a, ixa]
      Valb = [Data{2}, l0b, ixb]
   end

   % Predictions for plot
   gtam = sum(gta) * w;
   gtbm = sum(gtb) * w;
   Pgta = [ta;gtam];
   Pgtb = [tb;gtbm];
   Ptha = [thetaa;pthetaa];
   Pthb = [thetab;pthetab];
   Pred{1} = Pgta;
   Pred{2} = Pgtb;
   Pred{3} = Ptha;
   Pred{4} = Pthb;

end