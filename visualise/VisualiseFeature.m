function VisualiseFeature(f, s, dataSets, cal)

pts = feval(dataSets(f,s).georegister, dataSets(f,s), cal);
ptsMean = RemoveMean(pts);
ptsOutliers = RemovePointOutliers2(pts,3);

subplot(2,1,1);
plot3(ptsMean(:,1), ptsMean(:,2), ptsMean(:,3),'.')

subplot(2,1,2);
plot3(ptsOutliers(:,1), ptsOutliers(:,2), ptsOutliers(:,3),'.')
