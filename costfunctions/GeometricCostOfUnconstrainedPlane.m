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
%
% This function evaluates the geometric cost of a set of points with
% respect to an unconstrained plane of best fit.
%
% C = GeometricCostOfUnconstrainedPlane( pointsXYZ )
% Where:
%   pointsXYZ is an N-by-3 matrix of points in a cartesian coordinate
%   system
%   C is the total cost (or standard deviation) of these points from the
%       plane defined above.
%
% If there are 0 or 1 rows in pointsXYZ (i.e. 0 or 1 cartesian points),
% the total cost will always be zero.
%
%   See also MULTISENSORMULTIREGIONCOST
%

function [C] = GeometricCostOfUnconstrainedPlane( pointsXYZ )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test validity of input data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[numberOfPoints, cartesianDimensions] = size(pointsXYZ);
% Must be M-by-3 or empty
if( cartesianDimensions ~= 3 && numberOfPoints ~= 0 ),
    error('RangeSensorCalibrationToolbox:GeometricCostOfUnconstrainedPlane:InputPointsInvalidFormat', 'The points used to determine the cost with respect to a plane must be 3D cartesian, in an M-by-3 matrix.');
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

lambda = sort( eig(cov(pointsXYZ)) );
C = lambda(1);
