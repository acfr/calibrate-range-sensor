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
% Visualise a set of geometric features in the data structure as described
% in OptimiseSensorPoses and MultiSensorMultiRegionCost.
%
% VisualiseData(SensorToNavPoses, DataSets)
%
% The format of each input is explained in OptimiseSensorPoses and
% MultiSensorMultiRegionCost. 
%
% A 3D plot is shown for each feature defined in the input data. If there
% are multiple sets of data for each feature (i.e. multiple sensors /
% columns in DataSets) then each sensor's view of the feature is coloured
% in order:
%       blue, green, red, cyan, magenta, yellow, black
% If there is only one sensor view (one column in DataSets) then the
% feature is split into equal height bins and coloured in the same order
% based on the elevation of the points.
% 
% This can be useful in order to see the nature of a single feature when 
% first extracting the data, while the per-sensor-colouring is more useful
% when visualising how well the sensors are calibrated together.
%
%   See also OPTIMISESENSORPOSES, MULTISENSORMULTIREGIONCOST, PLOT3
function VisualiseDataSets(sensorToNavPoses, dataSets)

cols = { 'b.', 'g.', 'r.', 'c.', 'm.', 'y.', 'k.' };

for F = 1:size(dataSets,1),
    figure;
    clf
    hold on
    title(['Feature ' num2str(F)]);
    xlabel('Northing')
    ylabel('Easting')
    zlabel('Down');
    if size(dataSets,2) > 1
        for S = 1:size(dataSets,2),
            pointsNED = feval(dataSets(F,S).georegister, dataSets(F,S), sensorToNavPoses(S,:));
            if ( size(pointsNED,1) > 0 )
                pointsNED = RemoveMean(pointsNED);
                % pointsNED = RemovePointOutliers2(pointsNED,3);
                plot3(pointsNED(:,1),pointsNED(:,2),pointsNED(:,3),cols{mod(S,length(cols))})
            end
        end
    else
        pointsNED = feval(dataSets(F,1).georegister, dataSets(F,1), sensorToNavPoses(1,:));
        if ( size(pointsNED,1) > 0 )
            pointsNED = RemoveMean(pointsNED);
            % pointsNED = RemovePointOutliers2(pointsNED,3);
            maxDown = max(pointsNED(:,3));
            minDown = min(pointsNED(:,3));
            heights = linspace(minDown,maxDown,length(cols)+1);
            for C = 1:length(cols)
                i = find( pointsNED(:,3) > heights(C) & pointsNED(:,3) < heights(C+1) );
                plot3(pointsNED(i,1),pointsNED(i,2),pointsNED(i,3),cols{C})
            end
        end
    end
    axis equal
    grid on
end
