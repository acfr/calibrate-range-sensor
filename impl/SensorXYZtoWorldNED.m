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
        
            


