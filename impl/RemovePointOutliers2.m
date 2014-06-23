function [X] = RemovePointOutliers2(Xin,outlierStDev)

X=RemoveMean(Xin);

N = size(Xin,1);

[eigvec,eigval] = eig(cov(X));

rSq = X*inv(eigvec');
rSq = rSq*inv(sqrt(eigval));
rSq = dot(rSq,rSq,2);

idx = find(rSq < outlierStDev^2);
X = Xin(idx,:);
