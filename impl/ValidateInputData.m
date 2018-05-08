% This file is part of calibrate-range-sensor, a utility to calibrate extrinsic range sensor offsets
% Copyright (c) 2011 The University of Sydney
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 3. Neither the name of the University of Sydney nor the
%    names of its contributors may be used to endorse or promote products
%    derived from this software without specific prior written permission.
%
% NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
% GRANTED BY THIS LICENSE.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
% HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED
% WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
% IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

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

