function [ll,bic,Pred] = fitdcircle3(Pvar, Pfix, Sel, Data, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
% Assumes the eta components in the x and y directions are the
% same.
%    [ll,bic,Pred] = fitdcircle3(Pvar, Pfix, Sel, Data)
%    P = [v1a, v2a, v1b, v2b, eta1, eta2, a, Ter]
%          1    2    3    4    5      6   7   8
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITDCIRCLE3: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 3.0;
np = 8;
nlong = 320;
nshort = 360;
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
a= P(7);
ter = P(8);

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
   % Parameters for long
   Pa = [v1a, v2a, eta1a, eta2a, sigma, a];
   % Parameters for short
   Pb = [v1b, v2b, eta1b, eta2b, sigma, a];

   % Slow code uses Matlab. 
   [ta, gta, thetaa, pthetaa, mta] = vdcircle3(Pa, nw, h, tmax, 5);
   [tb, gtb, thetab, pthetab, mtb] = vdcircle3(Pb, nw, h, tmax, 5);

   % Fast code needs a C compiler and Gnu math library 
   %[ta, gta, thetaa, pthetaa, mta] = vdcircle300(Pa, tmax, 5);
   %[tb, gtb, thetab, pthetab, mtb] = vdcircle300(Pb, tmax, 5);
   % Filter zeros
   gta = max(gta, epsx);
   gtb = max(gtb, epsx);
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
