function [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data, trace)
% ========================================================================
% Circular diffusion with drift variability for Jason's source memory task.
%    [ll,bic,Pred] = fitdcircle(Pvar, Pfix, Sel, Data)
%    P = [v1, v2, eta1, eta2, a, Ter]
%          1   2     3     4  5    6 
%    'Data' is cell array structure created by <makelike>
% ========================================================================
name = 'FITDCIRCLE: ';
errmg1 = 'Incorrect number of parameters for model, exiting...';
errmg2 = 'Incorrect length selector vector, exiting...';
errmg3 = 'Data should be a 1 x 2 cell array from <makelike>...';

tmax = 3.0;  % Used 2.0 for original fits.
np = 6;

n = size(Data, 1);

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

end