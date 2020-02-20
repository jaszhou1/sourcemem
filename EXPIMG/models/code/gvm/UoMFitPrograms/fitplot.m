function fitplot(Data, Pred)
% ========================================================================
% Plot fitted values of circular diffusion model with drift variability.
%     fitplot(Data, Pred)
% ========================================================================
name = 'FITPLOT: ';
errmg1 = 'Data should be a 1 x 2 cell array from <makelike>...';

axhandle = setfig4;
Theta1 = Data{1}(:,1);
Rt1 = Data{1}(:,2);
Theta2 = Data{2}(:,1);
Rt2 = Data{2}(:,2);

ta = Pred{1}(1,:);
gtam = Pred{1}(2,:);
tb = Pred{2}(1,:);
gtbm = Pred{2}(2,:);
thetaa = Pred{3}(1,:);
pthetaa = Pred{3}(2,:);
thetab = Pred{4}(1,:);
pthetab = Pred{4}(2,:);

%Accuracy long
axes(axhandle(1))
histogram(Theta1, 50, 'Normalization', 'pdf', 'BinLimits', [-pi,pi]);
set(gca, 'Xlim', [-pi, pi])
set(gca, 'Ylim', [0, 1.2])
xlabel('Response Error')
ylabel('Probability density')
label(gca, .7, .9, 'Long');
hold
plot(thetaa, pthetaa, 'Linewidth', 2);

% Accuracy short
axes(axhandle(2));
histogram(Theta2, 50, 'Normalization', 'pdf', 'BinLimits', [-pi,pi]);
set(gca, 'Xlim', [-pi, pi])
set(gca, 'Ylim', [0, 1.2])
xlabel('Response Error')
label(gca, .7, .9, 'Short');
hold
plot(thetab, pthetab, 'Linewidth', 2);

% RT long
axes(axhandle(3));
histogram(Rt1, 50, 'Normalization', 'pdf', 'BinLimits', [0,3.0]);
xlabel('Response Time (s)')
set(gca, 'Ylim', [0, 3.0])
set(gca, 'Xlim', [0, 3.0])
label(gca, .7, .9, 'Long');
hold
ylabel('Probability density')
plot(ta, gtam, 'Linewidth', 2);

% RT short
axes(axhandle(4));
histogram(Rt2, 50, 'Normalization', 'pdf', 'BinLimits', [0,3.0]);
xlabel('Response Time (s)')
set(gca, 'Ylim', [0, 3.0])
set(gca, 'Xlim', [0, 3.0])
label(gca, .7, .9, 'Short');
hold
plot(tb, gtbm, 'Linewidth', 2);

