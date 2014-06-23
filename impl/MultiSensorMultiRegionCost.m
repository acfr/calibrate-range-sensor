function totalCost = MultiSensorMultiRegionCost( SensorToNavPose, DataSets, CostFunctions )

numSensors = size(SensorToNavPose,1);
numFeatures = size(DataSets,1);

totalCost = 0;

% Iterate each feature
for F = 1:numFeatures
    % Initialise points for this feature to empty matrix
    pointsNED = zeros(0,3);
    % Iterate each sensor
    for S = 1:numSensors
        % Calculate cartesian points (N,E,D) for this sensor's view of the
        % feature
        if( numel(DataSets(F,S).RangeData) > 0 )
            pointsNED = [ pointsNED
                          feval(DataSets(F,S).GeoregisterFunction, DataSets(F,S), SensorToNavPose(S,:) ) ];
        end
    end % S over DataSets(F,:)
    if( size(pointsNED,1) > 0)
        % Feed NED points into cost function
        totalCost = totalCost + feval(CostFunctions{F}, pointsNED);
    end
end % F over DataSets
totalCost = totalCost / numFeatures;
