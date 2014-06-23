function x = RemoveMean(x)
x = x - repmat(mean(x),size(x,1),1);
% function x = RemoveMean(x)

%[M,N] = size(x);

%x0 = x(1,:);
%x = x - repmat(x0,M,1);

%xMean = mean(x);
%x = x - repmat(xMean,M,1);
