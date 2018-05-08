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

function [pointsNED] = SensorXYZtoWorldNED( dataSet, sensorTransformXYZRPY )
if( ~isstruct(dataSet) )
    error('RangeSensorCalibrationToolbox:SensorXYZtoWorldNED:InvalidDataFormat', ...
          'DataSet must be a struct array.');
end
if( ~isfield(dataSet, 'sensor') || ~isfield(dataSet, 'nav') )
    error('RangeSensorCalibrationToolbox:SensorXYZtoWorldNED:InvalidDataFormat', ...
          'DataSet must be a struct array with the following fields: sensor, nav.');
end
if( size(dataSet.nav,1) ~= size(dataSet.sensor,1) )
    error('RangeSensorCalibrationToolbox:SensorXYZtoWorldNED:InvalidDataFormat', ...
            'Number of rows of nav and sensor data must be equal.');
end

if ( size(dataSet.nav,2) ~= 6 || size(dataSet.sensor,2) ~= 3 )
    error('RangeSensorCalibrationToolbox:SensorXYZtoWorldNED:InvalidDataFormat', ...
                'nav should be in the format [x y z roll pitch yaw]', ...
                'and sensor should be in the format [x y z] in the sensor frame.');
end

%convert from sensor frame to body frame
pointsBodyXYZ = CoordinateTransform( dataSet.sensor, sensorTransformXYZRPY );

%convert from body frame to nav frame
pointsNED = CoordinateTransform( pointsBodyXYZ, dataSet.nav(:,[1,2,3,4,5,6]) );
        
            


