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

function [pBefore,pAfter] = VisualiseResults( sensorTransformsBeforeXYZRPY, sensorTransformsAfterXYZRPY, dataSets, costFunctions )

disp( 'offset before calibration (m/deg):' )
disp( [sensorTransformsBeforeXYZRPY(:,[1,2,3]), rad2deg( sensorTransformsBeforeXYZRPY(:,[4,5,6]) )] )
disp( 'offset after calibration (m/deg):' )
disp( [sensorTransformsAfterXYZRPY(:,[1,2,3]), rad2deg( sensorTransformsAfterXYZRPY(:,[4,5,6]) )] )
disp( 'offset difference:' )
SensorTransformsAfterXYZRPYDiff=sensorTransformsAfterXYZRPY-sensorTransformsBeforeXYZRPY;
disp( [SensorTransformsAfterXYZRPYDiff(:,[1,2,3]), rad2deg( SensorTransformsAfterXYZRPYDiff(:,[4,5,6]) )] ) 

nSensors = size(sensorTransformsBeforeXYZRPY,1);
nFeatures = size(dataSets,1);

costsBefore = zeros( nSensors, nFeatures );
costsAfter = zeros( nSensors, nFeatures );
pBefore = cell(nFeatures,nSensors);
pAfter = cell(nFeatures,nSensors);
for( f=1:nFeatures )
    for( s=1:nSensors )
        pAfter{f,s} = [feval(dataSets(f,s).georegister, dataSets(f,s), sensorTransformsAfterXYZRPY(s,:) ) ];
        pBefore{f,s} = [feval(dataSets(f,s).georegister, dataSets(f,s), sensorTransformsBeforeXYZRPY(s,:) ) ];
        costsAfter(s,f) = feval(costFunctions{f}, pAfter{f,s});
        costsBefore(s,f) = feval(costFunctions{f}, pBefore{f,s});
    end
end

disp( 'costs before (sd m):' )
disp( sqrt(costsBefore) );
disp( 'costs after (sd m):' )
disp( sqrt(costsAfter) );
disp( 'cost difference (sd m):' )
disp( sqrt(costsAfter)-sqrt(costsBefore) );

disp( 'mean per feature before (sd m):' )
disp( mean( sqrt(costsBefore) ) );
disp( 'mean per feature after (sd m):' )
disp( mean( sqrt(costsAfter) ) );
disp( 'mean difference per feature (sd m)' );
disp( mean( sqrt(costsAfter) ) - mean( sqrt(costsBefore) ) );

disp( 'mean per sensor before (sd m):' )
disp( mean( sqrt(costsBefore') )' );
disp( 'mean per sensor after (sd m):' )
disp( mean( sqrt(costsAfter') )' );
disp( 'mean difference per sensor (sd m)' );
disp( mean( sqrt(costsAfter') )' - mean( sqrt(costsBefore') )' );

disp( 'mean cost all features before (sd m)' );
disp( mean( mean( sqrt(costsBefore) )) );
disp( 'mean cost all features after (sd m)' );
disp( mean( mean( sqrt(costsAfter) )) );
disp( 'mean cost difference all features (sd m)' );
disp( mean( mean( sqrt(costsAfter) ))-mean( mean( sqrt(costsBefore) )) );