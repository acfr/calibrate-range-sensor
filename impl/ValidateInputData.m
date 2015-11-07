function ValidateInputData( SensorToNavPose, DataSets, CostFunctions, bounds )

% sensorToNavPose
numSensors = size(SensorToNavPose,1);
if( size(SensorToNavPose,2) ~= 6 || numSensors < 1 )
    error('RangeSensorCalibrationToolbox:InvalidTransformInput', ...
          'The SensorTransformsXYZRPY matrix must be an NS-by-6 matrix, with NS > 0');
end

% DataSets
numFeatures = size(DataSets,1);
if( size(DataSets,2) < 1 || numFeatures < 1 )
    error('RangeSensorCalibrationToolbox:InvalidDataInput', ...
          'DATA must not be empty.');
end

if( ~isstruct(DataSets) )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'DATA must be a struct array.');
end

if( size(DataSets,2) ~= numSensors )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch', ...
          'The number of sensors does not match between inputs DATA and SensorTransformsXYZRPY. The number of columns in DATA should be equal to the number of rows in SensorTransformsXYZRPY.');
end

if( ~isfield(DataSets, 'sensor') || ~isfield(DataSets, 'nav') )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'DATA must be a struct array with the following fields: sensor, nav.');
end

for S = 1:numSensors
    for F = 1:numFeatures
        % Check each element of DATA has correctly formatted fields
        [rM, rN] = size(DataSets(F,S).sensor);
        [nM, nN] = size(DataSets(F,S).nav);
        if( rM ~= nM ),
            error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
                  'sensor and nav in the DATA structs must have the same number of rows.');
        end
    end
end

% CostFunctions
if( ~iscell(CostFunctions) || ~isvector(CostFunctions) )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'COSTFUNS must be a cell vector of function handles.');
end
for F = 1:length(CostFunctions)
    if( ~isa(CostFunctions{F}, 'char') && ~(numel(CostFunctions{F}) == 1 && isa(CostFunctions{F}, 'function_handle') ) )
        error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
              'The elements of the COSTFUNS cell vector must be function handles.');
    end
end

if( numel(CostFunctions) ~= numFeatures )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch', ...
          'The number of geometric features does not match between inputs DATA and COSTFUNS. The number of rows in DATA should be equal to the number of elements in COSTFUNS.');
end

if( size(bounds) ~= size(SensorToNavPose) )
    error('RangeSensorCalibrationToolbox:DataSizeMismatch:The size of bounds must equal size of initial offset');
end

