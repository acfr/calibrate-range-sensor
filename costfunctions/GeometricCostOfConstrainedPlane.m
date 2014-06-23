%
% This function evaluates the geometric cost of a set of points with
% respect to a plane with a specified normal.
%
% C = GeometricCostOfConstrainedPlane( normal, pointsXYZ )
% Where:
%   normal is a vector normal to the plane against which the points will be
%       compared
%   pointsXYZ is an N-by-3 matrix of points in a cartesian coordinate
%       system
%   C is the total cost (or standard deviation) of these points from the
%       plane defined above.
%
% If there are 0 or 1 rows in pointsXYZ (i.e. 0 or 1 cartesian points),
% the total cost will always be zero.
%
%   See also MULTISENSORMULTIREGIONCOST
%

function [C] = GeometricCostOfConstrainedPlane( normal, pointsXYZ )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test validity of input data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[numberOfPoints, cartesianDimensions] = size(pointsXYZ);
% Must be M-by-3 or empty
if( cartesianDimensions ~= 3 && numberOfPoints ~= 0 ),
    error('RangeSensorCalibrationToolbox:GeometricCostOfConstrainedPlane:InputPointsInvalidFormat', 'The points used to determine the cost with respect to a plane must be 3D cartesian, in an M-by-3 matrix.');
end

% Cannot take mean/etc on empty array, so return zero if its got nothing.
if( numberOfPoints < 1 )
    C = 0;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pointsXYZ = RemoveMean(pointsXYZ);
% pointsXYZ = RemovePointOutliers2(pointsXYZ, 3);

normal = normal ./ norm(normal);

[V, D] = eig( cov(pointsXYZ) );
C =     D(1,1) * dot( normal, V(:,1) )^2;
C = C + D(2,2) * dot( normal, V(:,2) )^2;
C = C + D(3,3) * dot( normal, V(:,3) )^2;
