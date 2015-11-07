%
% Visualise a set of geometric features in the data structure as described
% in OptimiseSensorPoses and MultiSensorMultiRegionCost.
%
% VisualiseData(SensorToNavPoses, DataSets)
%
% The format of each input is explained in OptimiseSensorPoses and
% MultiSensorMultiRegionCost. 
%
% A 3D plot is shown for each feature defined in the input data. If there
% are multiple sets of data for each feature (i.e. multiple sensors /
% columns in DataSets) then each sensor's view of the feature is coloured
% in order:
%       blue, green, red, cyan, magenta, yellow, black
% If there is only one sensor view (one column in DataSets) then the
% feature is split into equal height bins and coloured in the same order
% based on the elevation of the points.
% 
% This can be useful in order to see the nature of a single feature when 
% first extracting the data, while the per-sensor-colouring is more useful
% when visualising how well the sensors are calibrated together.
%
%   See also OPTIMISESENSORPOSES, MULTISENSORMULTIREGIONCOST, PLOT3
function VisualiseDataSets(SensorToNavPoses, DataSets)

cols = { 'b.', 'g.', 'r.', 'c.', 'm.', 'y.', 'k.' };

for F = 1:size(DataSets,1),
    figure;
    clf
    hold on
    title(['Feature ' num2str(F)]);
    xlabel('Northing')
    ylabel('Easting')
    zlabel('Down');
    if size(DataSets,2) > 1
        for S = 1:size(DataSets,2),
            pointsNED = feval(DataSets(F,S).georegister, DataSets(F,S), SensorToNavPoses(S,:));
            if ( size(pointsNED,1) > 0 )
                pointsNED = RemoveMean(pointsNED);
                % pointsNED = RemovePointOutliers2(pointsNED,3);
                plot3(pointsNED(:,1),pointsNED(:,2),pointsNED(:,3),cols{mod(S,length(cols))})
            end
        end
    else
        pointsNED = feval(DataSets(F,1).georegister, DataSets(F,1), SensorToNavPoses(1,:));
        if ( size(pointsNED,1) > 0 )
            pointsNED = RemoveMean(pointsNED);
            % pointsNED = RemovePointOutliers2(pointsNED,3);
            maxDown = max(pointsNED(:,3));
            minDown = min(pointsNED(:,3));
            heights = linspace(minDown,maxDown,length(cols)+1);
            for C = 1:length(cols)
                i = find( pointsNED(:,3) > heights(C) & pointsNED(:,3) < heights(C+1) );
                plot3(pointsNED(i,1),pointsNED(i,2),pointsNED(i,3),cols{C})
            end
        end
    end
    axis equal
    grid on
end
