function ValidateInputData( sensorToNavPose, dataSets, costFunctions, bounds )

% sensorToNavPose
numSensors = size(sensorToNavPose,1);
if( size(sensorToNavPose,2) ~= 6 || numSensors < 1 )
    error('RangeSensorCalibrationToolbox:InvalidTransformInput', ...
          'The SensorTransformsXYZRPY matrix must be an NS-by-6 matrix, with NS > 0');
end

% DataSets
numFeatures = size(dataSets,1);
if( size(dataSets,2) < 1 || numFeatures < 1 )
    error('RangeSensorCalibrationToolbox:InvalidDataInput', ...
          'DATA must not be empty.');
end

if( ~isstruct(dataSets) )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'DATA must be a struct array.');
end

if( size(dataSets,2) ~= numSensors )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch', ...
          'The number of sensors does not match between inputs DATA and SensorTransformsXYZRPY. The number of columns in DATA should be equal to the number of rows in SensorTransformsXYZRPY.');
end

if( ~isfield(dataSets, 'sensor') || ~isfield(dataSets, 'nav') )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'DATA must be a struct array with the following fields: sensor, nav.');
end

for S = 1:numSensors
    for F = 1:numFeatures
        % Check each element of DATA has correctly formatted fields
        [rM, rN] = size(dataSets(F,S).sensor);
        [nM, nN] = size(dataSets(F,S).nav);
        if( rM ~= nM ),
            error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
                  'sensor and nav in the DATA structs must have the same number of rows.');
        end
    end
end

% CostFunctions
if( ~iscell(costFunctions) || ~isvector(costFunctions) )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'COSTFUNS must be a cell vector of function handles.');
end
for F = 1:length(costFunctions)
    if( ~isa(costFunctions{F}, 'char') && ~(numel(costFunctions{F}) == 1 && isa(costFunctions{F}, 'function_handle') ) )
        error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
              'The elements of the COSTFUNS cell vector must be function handles.');
    end
end

if( numel(costFunctions) ~= numFeatures )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch', ...
          'The number of geometric features does not match between inputs DATA and COSTFUNS. The number of rows in DATA should be equal to the number of elements in COSTFUNS.');
end

if( size(bounds) ~= size(sensorToNavPose) )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch:The size of bounds must equal size of initial offset');
end

