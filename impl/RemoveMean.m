function y = RemoveMean(x)
y = x - repmat(mean(x),size(x,1),1);
