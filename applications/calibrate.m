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

%check dependencies
if exist('bin_load')~=2
    error('Could not find required dependency: comma/csv/examples/bin_load.m - check your path settings')
end
reload=1;
dataFolder='/home/data/my-calibration-data'

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
costfunctions{7} = 'GeometricCostOfUnconstrainedPlane';
costfunctions{7} = Ignore;

options = optimset( 'Algorithm','active-set','MaxFunEvals', 2000, 'MaxIter', 1000, 'Display','iter', 'TolFun', 1e-10, 'TolX', 1e-10);

disp('optimising...')
tic
[ sensorTransformsXYZRPY ] = OptimiseSensorPoses( sensorTransformsXYZRPY0, data, costfunctions, bounds, options );
toc

fprintf('optimised result:\noffset=%.5f,%.5f,%.5f,%.5f,%.5f,%.5f\n',sensorTransformsXYZRPY)

[p0,p1] = VisualiseResults( sensorTransformsXYZRPY0, sensorTransformsXYZRPY, data, costfunctions );
VisualiseDataSets( sensorTransformsXYZRPY0, data );
VisualiseDataSets( sensorTransformsXYZRPY, data );
