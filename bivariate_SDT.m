% just a quick script to make a figure for thesis illustrating bivariate SDT (recognition/source memory)

% Parameters 
mu1 = [0 -1.5];
mu2 = [1.5  1.5];
mu3 = [-1.5, 1.5];
Sigma = [1 0; 0 1];

% grid of points
x1 = -5:0.2:5;
x2 = -5:0.2:5;
[X1,X2] = meshgrid(x1,x2);
X = [X1(:) X2(:)];

% construct pdf on grid points
y1 = mvnpdf(X,mu1,Sigma);
y1 = reshape(y1,length(x2),length(x1));

y2 = mvnpdf(X,mu2,Sigma);
y2 = reshape(y2,length(x2),length(x1));

y3 = mvnpdf(X,mu3,Sigma);
y3 = reshape(y3,length(x2),length(x1));

% plot
surf(x1,x2,y1)
hold on
surf(x1,x2,y2)
hold on
surf(x1,x2,y3)
caxis([min(y(:))-0.5*range(y(:)),max(y(:))])
axis([-4 4 -4 4 0 0.2])
xlabel('Source Evidence')
ylabel('Recognition Evidence')
zlabel('Response Probability')
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'ZTickLabel',[]);
set(gca,'TickLength',[0 0])
hold off