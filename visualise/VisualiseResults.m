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