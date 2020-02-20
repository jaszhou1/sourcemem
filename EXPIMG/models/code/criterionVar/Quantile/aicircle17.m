function [ll,qaic,Pred,Gstuff] = aicircle17(Pvar, Pfix, Sel, Data, trace)
% ==========================================================================
% Circular diffusion with drift anisotropies for Saam's colour circle task.
% 5-category version (subject JM) with free diffusion coefficient.
%
%   [ll,qaic,Pred,Gstuff] =  aicircle17(Pvar, Pfix, Sel, Data, trace)
%    P = [v1...v3b, eta1a....eta3b, a, Ter, b1...b5, alpha, a1...a5, sigma1...sigma2]
%          1...6         7...12     13  14, 15..19     20   21...25, 26..27
%    'Data' is a 3-element cell array modified form <readtrialdata>
%    a1...a3 are bias angles (raw bias) [0..2*pi]
%  23 Jan 2018: fixed labelling in meshgrid calls.
%  27 Jan 2018 : eta1, eta2 interpreted as radial and tangential components 
%  of drift rate variability.
%  21 Feb 2018:  Separate biases for the 3 categories
%  28 Feb 2018:  Gaussian decay of bias with distance, just sum all biases.
%  7 Mar 2018:   Parameterized bias angles (as well as magnitudes)
% ===========================================================================

   name = 'AICIRCLE17: ';
   errmg1 = 'Incorrect number of parameters for model, exiting...';
   errmg2 = 'Incorrect length selector vector, exiting...';
   errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';


   np = 27;
   Overdispersion = [2.76, 1.45, 1.38, 1.14]; % AK, JM, MN, SB   - error x time
   tau2 = Overdispersion(2);

   % Number of trials in each discriminability condition. (SB a bit unbalanced).
   nlow = length(Data{1});
   nmed = length(Data{2});
   nhi = length(Data{3});

   epsx = 1e-9;

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
   Ptemp = P;
   save Ptemp Ptemp   


   % Allow for stimulus bias in nonzero second drift component.
   v1a = P(1);
   v1b = P(2);
   v2a = P(3);
   v2b = P(4);
   v3a = P(5);
   v3b = P(6);
   eta1a = P(7);
   eta1b = P(8);
   eta2a = P(9);
   eta2b = P(10);
   eta3a = P(11);
   eta3b = P(12);
   a= P(13);
   ter = P(14);
   B = P(15:19);
   alpha = P(20);
   RawBias = P(21:25);   % a
   Sigma =[P(26:27), 1.0]; 

   % Equal etas constraint
   %if Sel(8) == 0
   %    eta1b = eta1a;
   %end
   %if Sel(10) == 0
   %    eta2b = eta2a;
   %end
   %if Sel(12) == 0
   %    eta3b = eta3a;
   %end
  
   % -------------------------------------------------------------------------
   %    v1a...v3b,     eta1a....eta3b,    a,   Ter,  b1...b5, alpha, a1..a5, sigma1...2]
   % ---------------------------------------------------- ---------------------

    Ub= [ 7.0*ones(1,6),  4.0*ones(1,6),  5.0,  1.0,  5.0*ones(1,6)  2*pi*ones(1,5),  1.5, 1.5]; 
    Lb= [-7.0*ones(1,6),  0.0*ones(1,6),  0.5,  0.1,    0*ones(1,6)  0*ones(1,5), 0.7, 0.7];
    Pub=[ 6.5*ones(1,6),  3.5*ones(1,6),  4.8,  0.8   4.5*ones(1,6)  (2*pi-eps)*ones(1,5) 1.3, 1.3];
    Plb=[-6.5*ones(1,6),  0.0*ones(1,6),  0.7,  0.15  0.02*ones(1,6)  eps*ones(1,5), 0.75, 0.75];
    Pred = cell(3,3);
    if any(P - Ub > 0) | any(Lb - P > 0)
       ll = 1e7 + ...
            1e3 * (sum(max(P - Ub, 0).^2) + sum(max(Ub - P).^2));
       bic = 0;
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
      end;   
      Pa = [v1a, v1b, B, eta1a, eta1b, Sigma(1), a, ter, alpha];
      % Parameters for med
      Pb = [v2a, v2b, B, eta2a, eta2b, Sigma(2), a, ter, alpha];
      % Parameters for hi
      Pc = [v3a, v3b, B, eta3a, eta3b, Sigma(3), a, ter, alpha];

      [ta, gtma, ftma, thetaa, pthetaa, mthetaa, mdthetaa, ethetaa, lla] = aicircle12j(Pa, Data{1}, RawBias);
      [tb, gtmb, ftmb, thetab, pthetab, mthetab, mdthetab, ethetab, llb] = aicircle12j(Pb, Data{2}, RawBias);
      [tc, gtmc, ftmc, thetac, pthetac, mthetac, mdthetac, ethetac, llc] = aicircle12j(Pc, Data{3}, RawBias);
     % Pass out the raw densities for the quantile-probability plot.
      Gstuff = cell(3,3);
      Gstuff{1,1} = ta;
      Gstuff{2,1} = thetaa;
      Gstuff{3,1} = gtma;
      Gstuff{1,2} = tb;
      Gstuff{2,2} = thetab;
      Gstuff{3,2} = gtmb;
      Gstuff{1,3} = tc;
      Gstuff{2,3} = thetac;
      Gstuff{3,3} = gtmc;
      % Minimize sum of minus LL's across two conditions.
     ll = sum(lla) + sum(llb) + sum(llc);
     qaic = 2 * ll /tau2  + 2 * sum(Sel); 
     %bic = 2 * ll/tau2 + sum(Sel) * log(nlow + nmed + nhi);
     
     % ftm is a double marginalization across w and v.
     Pgta = [ta; ftma];
     Pgtb = [tb; ftmb];
     Pgtc = [tc; ftmc];
     
     Ptha = [thetaa; pthetaa'];
     Pthb = [thetab; pthetab'];
     Pthc = [thetac; pthetac'];
  
     Rtha = [thetaa; ethetaa; mthetaa; mdthetaa];
     Rthb = [thetab; ethetab; mthetab; mdthetab];
     Rthc = [thetac; ethetac; mthetac; mdthetac];

     Pred{1,1} = Pgta;
     Pred{1,2} = Pgtb;
     Pred{1,3} = Pgtc;
     Pred{2,1} = Ptha;
     Pred{2,2} = Pthb;
     Pred{2,3} = Pthb;
     Pred{3,1} = Rtha;
     Pred{3,2} = Rthb;
     Pred{3,3} = Rthc;
    % Penalize log-likelihood quadratically.
     ll = abs(ll) + penalty;
  end
end

function [t, gtm, ftm, theta, pthetam, mtheta, mdtheta, etheta, ll0] = aicircle12j(Pj, Dataj, RawBias)
% ===============================================================================================
% Compute predictions and log-likelihoods for one condition.
% Initially return predictions marginalized across stimulus angle.
% Now puts everything into canonical orientation to avoid the etas problem
%      [t, gtm, ftm, theta, pthetam, mtheta, etheta, ll0] = aicircle12j(Pj, Dataj, RawBias, sz, nw, nv)
%      P = [v1, v2, b1, b2, b3, eta1, eta2, sigma, a, ter, alpha]
%  Calculate components of likelihood for one discriminability condition.
%  b is the amplitute of the bias vectors; currently hardwired 
% ===============================================================================================
   tmax = 4.0;  % Set from histograms by eye (see FikeKey.txt)  
   nw = 50; 
   nv = 50; 
   sz = 300; 
   h = tmax / sz; 
   w = 2 * pi / nw;
   nvm = fix(nv / 2);
   np = 13;
   nw1 = nw + 1;
   nv1 = nv + 1;
   BiasAngle = sort(signed_angle(RawBias)); % SB peaks (radians unsigned);
   %BiasAngle = [-2.2832, -0.6832, 2.000];
   %BiasAngle = [-2.2832, -0.500, 2.200];  % NEW ###

   %BiasAngle = [-2.09, 0, 2.09]; 
   epsx = 1e-9;
   contamden = 0.05;  % Contaminant density.
   tmax = 4.0;
   ter = Pj(length(Pj) - 1);

   ld = size(Dataj);
   if ld(2) ~= 3
      disp('AICIRCLE300J: Wrong size data matrix, returning...')
      size(Dataj)
      return
   end
   if length(Pj) ~= np
      disp('Wrong length parameter vector, returning...');
      np
      return
   end
   [t, gt, thetas, theta, ptheta, mtheta] = joint5density([Pj(1:11), Pj(13)], BiasAngle, tmax, nw1, nv1);
   % Filter zeros  
   gt = max(gt, epsx); % [51, 300, 51] % with wrap-around.
   % Add nondecision times
   t = t + ter;
   mtheta = mtheta + ter;

   [anglerr, time, angles]=ndgrid(theta, t, thetas);

   % Interpolate in joint density to get likelihoods of each data point
   l0 = interpn(anglerr, time, angles, gt, Dataj(:,2), Dataj(:,3), Dataj(:,1), 'linear');
   Cx = isnan(l0);
   l0(Cx) = contamden;
   ll0 = -log(l0);

  % Marginals for accuracy, joint distribution and MRT
   gtm = zeros(nw, sz);  % Last index is stimulus phase
   pthetam = zeros(nw, 1);
   mthetam = zeros(nw, 1);
   etheta = zeros(1, nv);

   gtm = sum(gt(:,:,1:nv), 3) / nv;
   % Predictions for plot
   ftm = sum(gtm) * w;
   pthetam = sum(ptheta(:,1:nv), 2) / nv;
   mthetam = sum(mtheta(:,1:nv), 2) / nv;
   % Mean error computed in canonical orientation - sum across rows for each column (stimulus)
   etheta = sum(ptheta .* theta') * w;
   for j = 1:nv1
       ptheta(:,j) = circshift(ptheta(:, j), j - nvm);
       mtheta(:,j) = circshift(mtheta(:, j), j - nvm);
   end
   % Sum across rows (response angle) gives mean RT for a given stimulus (Nondecision time added above)
   mtheta = sum(ptheta .* mtheta') * w;

   % Do medians
   mdtheta = zeros(1, nv1);
   for j = 1:nv
       gt(:, :, j) = circshift(gt(:, :, j), j - nvm);
   end
   % Sum over response - weird syntax b/c cumsum returns 1 x 300 x 51, need to reduce dimension.
   ft = zeros(sz, nv1);
   ft(:,:) = cumsum(sum(gt, 1)) * w * h;
   for j = 1:nv
        mjlo = max(find(ft(:, j) <  0.5));
        mjhi = max(find(ft(:, j) <= 0.5));
        mdtheta(j) = (t(mjlo) + t(mjhi)) / 2; 
   end
   mdtheta(nv1) = mdtheta(1); 
end



function [t, gt, thetas, thetaerr, ptheta, mtheta] = joint5density(P, BiasAngle, tmax, nw1, nv1)
% ===============================================================================================
%  [t,gt,thetas, thetaerr,ptheta,mtheta] = joint5density(P, BiasAngle, tmax, nw, nv);
% P = [v1, v2, b, eta1, eta2, sigma, a, alpha]
% Circular diffusion predictions as a function of stimulus angle.
% Stimuli in canonical orientation (i.e., re 0), bias computed as an offset. 
% ===============================================================================================
   v1 = P(1);
   v2 = P(2);
   B = P(3:7);
   eta1 = P(8);
   eta2 = P(9);
   sigma = P(10);
   a = P(11);
   alpha = P(12);

   sz = 300; % number of time steps
   nw = 50;  % Needed for Matlab version, C version sets internally.
   h = tmax / sz;
   nbias = 5;
   badix = 5; % was 25 for MN
   nv = nv1 - 1;
   v = 2 * pi / nv; 

   thetaerr = linspace(-pi, pi, nw1); % To accommodate wrap around. 
   thetas = linspace(-pi, pi,  nv1);   
   ltheta = length(thetas);
   thetav = zeros(1, ltheta);
   Vtheta = zeros(2, ltheta);   % Values of drift at stimulus angle.
   %VthetaPhase = zeros(1, ltheta)
   gt = zeros(nw1, sz, nv1);  % Last index is stimulus phase
   ptheta = zeros(nw1, nv1);
   mtheta = zeros(nw1, nv1);
   etheta = zeros(nw1, nv1);
   t = linspace(0, tmax, sz);
   vnorm = sqrt(v^1 + v2^2);
   % Bias
   Thetasex = ones(nbias,1) * thetas;
   %thetas
   %BiasAngle
   BiasAnglex = BiasAngle' * ones(1, nv1);
   Bias = B' * ones(1, nv1);
  % Use 1 - cos distance. 
   Distance = BiasAnglex - Thetasex;
   CircularDistance = 1 - cos(Distance);
   DecayedBias =  vnorm * Bias .* exp(-alpha * CircularDistance);  
   DistanceCos = cos(Distance);
   DistanceSin = sin(Distance);
   SumBiasCos = sum(DecayedBias .* DistanceCos);
%   DistanceByDecay = DecayedBias .* DistanceCos
   SumBiasSin = sum(DecayedBias .* DistanceSin);
   mcd = mean(CircularDistance, 2);
   %size(gt)
   %size(ptheta)
   for k = 1:nv1 
        Vtheta(1,k) = v1 + SumBiasCos(k);
        Vtheta(2,k) = v2 + SumBiasSin(k);
        % C-version
        %[~,gt(:,:,k), ~, ptheta(:,k), mtheta(:,k)] = vdcircle300cls([Vtheta(1,k), Vtheta(2,k), ...
        %eta1, eta2, sigma, a], tmax,badix);
        % Matlab version   
        [~,gt(:,:,k), ~, ptheta(:,k), mtheta(:,k)] = vdcircle3cls([Vtheta(1,k), Vtheta(2,k), ...
                eta1, eta2, sigma, a], nw, h, tmax-h, badix);
   end;
   %Vnorm = sqrt(Vtheta(1,:).^2 + Vtheta(2,:).^2)
   %mvnorm = mean(Vnorm)

 

   % Wrap around to close for interpolation.
   gt(:,:,nv1) = gt(:,:, 1);
   ptheta(:,nv1) = ptheta(:, 1);
   mtheta(:, nv1) = mtheta(:, 1);

   %plot(thetas, mtheta)
   %disp('In j3')
   %size(ptheta)
   %size(mtheta)
   %pause
end
  
function sangle = signed_angle(a)
% ================================================================
% Convert angles on [0 : 2 *pi] to [-pi : +pi]
% ================================================================
    a = a / pi;
    sangle = pi * (rem(a , 1) - fix(a / 1));
end


