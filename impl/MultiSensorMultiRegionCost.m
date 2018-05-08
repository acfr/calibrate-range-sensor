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
