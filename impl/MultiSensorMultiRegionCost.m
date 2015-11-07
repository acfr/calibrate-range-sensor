function totalCost = MultiSensorMultiRegionCost( sensorToNavPose, dataSets, costFunctions )

numSensors = size(sensorToNavPose,1);
numFeatures = size(dataSets,1);

totalCost = 0;

% Iterate each feature
for f = 1:numFeatures
    % Initialise points for this feature to empty matrix
    pointsNED = zeros(0,3);
    % Iterate each sensor
    for s = 1:numSensors
        % Calculate cartesian points (N,E,D) for this sensor's view of the
        % feature
        if( numel(dataSets(f,s).sensor) > 0 )
            pointsNED = [ pointsNED
                          feval(dataSets(f,s).georegister, dataSets(f,s), sensorToNavPose(s,:) ) ];
        end
    end % S over DataSets(F,:)
    if( size(pointsNED,1) > 0)
        % Feed NED points into cost function
        totalCost = totalCost + feval(costFunctions{f}, pointsNED);
    end
end % F over DataSets
totalCost = totalCost / numFeatures;
