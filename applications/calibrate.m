RELOAD=0;
VISUALISE=1;
DATA_DIR='C:\Users\j.underwood\Data\mars\CalibrationArkFiles\process\';

nSensors=1;
if( RELOAD )
    rawSensorData=cell(1,1);
    rawSensorData{1}=load([DATA_DIR,'features.csv']);
end

%fields=['t','xs','ys','zs','scan-id','x','y','z','xn','yn','zn','roll','pitch','yaw','id']
xs=2;
ys=3;
zs=4;
xn=6;
yn=7;
zn=8;
north=9;
east=10;
down=11;
roll=12;
pitch=13;
yaw=14;
feature=15;

%offsets with XYZYPR (note YAW-PITCH-ROLL)
sensorTransformsXYZYPR0=[0.3,0,-0.25,1.57,0,1.2915];
bounds = [0.2, 0.2, 0.2, deg2rad(5), deg2rad(5), deg2rad(5) ];

sensorTransformsXYZYPRLower = sensorTransformsXYZYPR0 - bounds;
sensorTransformsXYZYPRUpper = sensorTransformsXYZYPR0 + bounds;

nFeatures=0;
for s=1:nSensors
    nFeatures = max( nFeatures, max(rawSensorData{s}(:,feature)) );%largest feature id of all sensors. Id 0 is rubish non-feature.
end

for( f=1:nFeatures )
    for( s=1:nSensors )
        fId = find(rawSensorData{s}(:,feature)==f); %f are indices to all points in feature i
        data(f,s).RangeData = [rawSensorData{s}(fId,xs),rawSensorData{s}(fId,ys),rawSensorData{s}(fId,zs)]; %fill out the X,Y,Z sensor data for feature i
        data(f,s).NavData = [rawSensorData{s}(fId,north),rawSensorData{s}(fId,east),rawSensorData{s}(fId,down),rawSensorData{s}(fId,roll),rawSensorData{s}(fId,pitch),rawSensorData{s}(fId,yaw)];
        data(f,s).GeoregisterFunction = @GetNEDPointsXYZ;
    end
end

%THIS PART IS STILL MANUALLY ENTERED - YUK!
%TODO Auto calc based on min cost
costfunctions = cell(nFeatures,1);
costfunctions{1} = 'GeometricCostOfUnconstrainedLine';
costfunctions{2} = 'GeometricCostOfUnconstrainedLine';
costfunctions{3} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{4} = 'GeometricCostOfUnconstrainedPlane';

options = optimset( 'Algorithm','active-set','MaxFunEvals', 2000, 'MaxIter', 1000, 'Display','iter', 'TolFun', 1e-10, 'TolX', 1e-10);

disp('optimising...')
tic
[ sensorTransformsXYZYPR ] = OptimiseSensorPoses( sensorTransformsXYZYPR0, data, costfunctions, sensorTransformsXYZYPRLower, sensorTransformsXYZYPRUpper, options )
toc

[p0,p1] = VisualiseResults( sensorTransformsXYZYPR0, sensorTransformsXYZYPR, data, costfunctions );
VisualiseDataSets( sensorTransformsXYZYPR0, data );
VisualiseDataSets( sensorTransformsXYZYPR, data );
