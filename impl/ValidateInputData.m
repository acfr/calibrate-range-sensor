function ValidateInputData( SensorToNavPose, DataSets, CostFunctions, bounds )

% sensorToNavPose
numSensors = size(SensorToNavPose,1);
if( size(SensorToNavPose,2) ~= 6 || numSensors < 1 )
    error('RangeSensorCalibrationToolbox:InvalidTransformInput', ...
          'The SensorTransformsXYZYPR matrix must be an NS-by-6 matrix, with NS > 0');
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
          'The number of sensors does not match between inputs DATA and SensorTransformsXYZYPR. The number of columns in DATA should be equal to the number of rows in SensorTransformsXYZYPR.');
end

if( ~isfield(DataSets, 'RangeData') || ~isfield(DataSets, 'NavData') )
    error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
          'DATA must be a struct array with the following fields: RangeData, NavData.');
end

for S = 1:numSensors
    for F = 1:numFeatures
        % Check each element of DATA has correctly formatted fields
        [rM, rN] = size(DataSets(F,S).RangeData);
        [nM, nN] = size(DataSets(F,S).NavData);
        if( rM ~= nM ),
            error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
                  'RangeData and NavData in the DATA structs must have the same number of rows.');
        end
        % The following should be checked by the georegistration function
        % the actually uses the data (typically GetNEDPoints or
        % GetXYZPoints_XYZq_RAE)
%         % Number of columns only matters if rows is nonzero --- this
%         if( nM ~= 0 ) 
%             if ( rN~=2 || nN~=6 ) && ( rN~=3 || nN~=7 )
%                 error('RangeSensorCalibrationToolbox:InvalidDataFormat', ...
%                       'RangeData must be in the format [range bearing] or [range azimuth elevation]', ...
%                       'NavData must be in the format [north east down roll pitch yaw] or [x y z q1 q2 q3 q4]', ...
%                       '(where [q1 q2 q3 q4] is an orientation quaternion).');
%             end
%         end
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

