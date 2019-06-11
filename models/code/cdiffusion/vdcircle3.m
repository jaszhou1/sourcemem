function [T,Gt, Theta, Ptheta, Mt] = vdcircle3(P, nw, h, tmax, badix)
% ========================================================================
% 2D diffusion on a circle with independent normal drift variability
%     [T, Gt, Theta, Ptheta, Mt] = vdcircle3(P, nw, h, tmax, badix)
%     P = [v1, v2, eta1, eta2, sigma, a]
%     Mt is closed-form E[T]
% ========================================================================
maxarg = 5;
kmax = 50; % Truncation length of series.
if nargin < maxarg
    badix = 0;
end;    
v1 = P(1);
v2 = P(2);
eta1 = P(3);
eta2 = P(4);
sigma = P(5);
a = P(6);

if eta1 <1e-5       
    eta1 = 0.01;
end
if eta2 <1e-5       
    eta2 = 0.01;
end 

sigma2 = sigma^2;
eta1onsigma2 = (eta1 / sigma)^2;
eta2onsigma2 = (eta2 / sigma)^2;
two_pi = 2.0 * pi;

[T, Gt0]= dhamana([a, sigma], kmax, h, tmax, badix);

w = two_pi / nw;
Theta = [-pi: w : pi - w];
sztheta = length(Theta);
szt = length(T);

Ptheta = zeros(1, sztheta);
Mt = zeros(1, sztheta);


Gt0u = ones(nw,1) * Gt0; % Replicate copies of g0s.

Tscale = sqrt(1./(1 + eta1onsigma2 * T)) .* sqrt(1./(1 + eta2onsigma2 * T));
G11 = 2.0 * eta1 * eta1 * (1 + eta1onsigma2 * T);
G21 = 2.0 * eta2 * eta2 * (1 + eta2onsigma2 * T);
for i = 1:nw
    G12 = v1 + a * eta1onsigma2 * cos(Theta(i));
    G22 = v2 + a * eta2onsigma2 * sin(Theta(i));
    for k = 2:szt
          Girs1 = exp(G12^2 / G11(k) - (v1 / eta1)^2 / 2);
          Girs2 = exp(G22^2 / G21(k) - (v2 / eta2)^2 / 2);
          Gt(i,k) = Tscale(k) * Girs1 * Girs2 * Gt0(k) / two_pi; 
    end
end

totalmass = sum(sum(Gt)) * w * h;
for i = 1:nw
    for k = 2:szt
        Ptheta(i) = Ptheta(i) + (Gt(i,k) + Gt(i,k-1)) /2.0;
        Mt(i) = Mt(i) + (T(k) * Gt(i,k) + T(k - 1) * Gt(i,k)) / 2.0; 
    end
    Ptheta(i) = Ptheta(i) * h / totalmass;
    Mt(i) = Mt(i) * h / Ptheta(i) / totalmass; 
end

end
