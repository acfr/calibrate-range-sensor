function [pointsNED] = GetNEDPointsXYZ( DataSet, sensorTransformXYZYPR )
if( isstruct(DataSet) && isfield(DataSet, 'NavData') && isfield(DataSet, 'RangeData') )

    if( size(DataSet.NavData,1) == size(DataSet.RangeData,1) )

        if ( size(DataSet.NavData,2) == 6 && size(DataSet.RangeData,2) == 3 )

            %convert from sensor frame to body frame
            pointsBodyXYZ = CoordinateTransform( DataSet.RangeData, sensorTransformXYZYPR );

            %convert from body frame to nav frame
            pointsNED = CoordinateTransform( pointsBodyXYZ, DataSet.NavData(:,[1,2,3,6,5,4]) );

        else

            error('RangeSensorCalibrationToolbox:GetNEDPointsXYZ:InvalidDataFormat', ...
                'NavData should be in the format [x y z roll pitch yaw]', ...
                'and RangeData should be in the format [X Y Z] in the sensor frame.');

        end

    else
        error('RangeSensorCalibrationToolbox:GetNEDPointsXYZ:InvalidDataFormat', ...
            'Number of rows of Nav and Range data must be equal.');
    end

else
    error('RangeSensorCalibrationToolbox:GetNEDPointsXYZ:InvalidDataFormat', ...
          'DataSet must be a struct with fields:', ...
          'NavData and RangeData');
end
