%check dependencies
if exist('bin_load')~=2
    error('Could not find required dependency: comma/csv/examples/bin_load.m - check your path settings')
end
reload=1;
dataFolder='X:/vegibot-data/processed/sardi/calibration/sick';

featureFiles=dir([dataFolder,'/*features.bin']);
nSensors=length(featureFiles);
if nSensors==0
    error(['No feature files found: ', dataFolder,'/*features.bin'])
end
if( reload )
    rawSensorData=cell(1,nSensors);
    for i=1:nSensors
        %rawSensorData{i}=load(featureFiles(2).name); % csv
        rawSensorData{i}=bin_load([dataFolder,'/',featureFiles(i).name],'t,d,d,d,d,d,d,d,d,d,d,d,d,ui');
    end
end

%todo: parse from json file using something like:
%fieldname='cc';
%if(length(strfind(fieldstring,fieldname))==1)
%   fieldnum=length(strfind(fieldstring(1:strfind(fieldstring,fieldname)),','))+1
%end
xs=2;
ys=3;
zs=4;
xn=5;
yn=6;
zn=7;
north=8;
east=9;
down=10;
roll=11;
pitch=12;
yaw=13;
feature=14;

sensorTransformsXYZRPY0=zeros(nSensors,6);
for i=1:nSensors
    system( sprintf('cat %s | name-value-get offset/initial > tmp.offset.csv',[dataFolder,'/',featureFiles(i).name(1:end-3),'json']) );
    sensorTransformsXYZRPY0(i,:)=load('tmp.offset.csv');
    delete tmp.offset.csv
end

%todo: get from json file instead
bounds = [0.2, 0.2, 0.2, deg2rad(5), deg2rad(5), deg2rad(5) ];
bounds = repmat(bounds,nSensors,1);

nFeatures=0;
for s=1:nSensors
    nFeatures = max( nFeatures, max(rawSensorData{s}(:,feature)) );%largest feature id of all sensors. Id 0 is rubish non-feature.
end
for( f=1:nFeatures )
    for( s=1:nSensors )
        fId = find(rawSensorData{s}(:,feature)==f); %f are indices to all points in feature i
        data(f,s).sensor = [rawSensorData{s}(fId,xs),rawSensorData{s}(fId,ys),rawSensorData{s}(fId,zs)]; %fill out the X,Y,Z sensor data for feature i
        data(f,s).nav = [rawSensorData{s}(fId,north),rawSensorData{s}(fId,east),rawSensorData{s}(fId,down),rawSensorData{s}(fId,roll),rawSensorData{s}(fId,pitch),rawSensorData{s}(fId,yaw)];
        data(f,s).georegister = @SensorXYZtoWorldNED;
    end
end


%todo: specify feature shapes from json file?
%todo: auto calc based on min cost?

%the following bindings add constrained functions or allow ignoring a feature
%GeometricCostOfVerticalLine = @(x)(GeometricCostOfConstrainedLine([0,0,1],x));
Ignore=@(x)(0);

costfunctions = cell(nFeatures,1);
costfunctions{1} = 'GeometricCostOfUnconstrainedLine';
costfunctions{2} = 'GeometricCostOfUnconstrainedLine';
costfunctions{3} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{4} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{5} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{6} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{7} = Ignore;

options = optimset( 'Algorithm','active-set','MaxFunEvals', 2000, 'MaxIter', 1000, 'Display','iter', 'TolFun', 1e-10, 'TolX', 1e-10);

disp('optimising...')
tic
[ sensorTransformsXYZRPY ] = OptimiseSensorPoses( sensorTransformsXYZRPY0, data, costfunctions, bounds, options )
toc

[p0,p1] = VisualiseResults( sensorTransformsXYZRPY0, sensorTransformsXYZRPY, data, costfunctions );
VisualiseDataSets( sensorTransformsXYZRPY0, data );
VisualiseDataSets( sensorTransformsXYZRPY, data );
