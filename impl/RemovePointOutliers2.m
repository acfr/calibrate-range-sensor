function [y] = RemovePointOutliers2(x,outlierStDev)
y=RemoveMean(x);

N = size(x,1);

[eigvec,eigval] = eig(cov(y));

rSq = y*inv(eigvec');
rSq = rSq*inv(sqrt(eigval));
rSq = dot(rSq,rSq,2);

idx = find(rSq < outlierStDev^2);
y = x(idx,:);
