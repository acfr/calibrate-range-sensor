function VisualiseFeature(F, S, DataSets, cal)

pts = feval(DataSets(F,S).GeoregisterFunction, DataSets(F,S), cal);
ptsMean = RemoveMean(pts);
ptsOutliers = RemovePointOutliers2(pts,3);

subplot(2,1,1);
plot3(ptsMean(:,1), ptsMean(:,2), ptsMean(:,3),'.')

subplot(2,1,2);
plot3(ptsOutliers(:,1), ptsOutliers(:,2), ptsOutliers(:,3),'.')
