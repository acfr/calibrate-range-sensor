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
% Optimise/Calibrate multiple sensors using data collected from them
% viewing several geometric features and an initial guess of their poses
% with respect to the nav data.
%
% [ SensorTransformsXYZYPR ] = OptimiseSensorPose( SensorTransformsXYZYPR, DATA, COSTFUNS, 
%                                                  SensorTransformsLower, SensorTransformsUpper, OPTIONS )
% 
% Inputs:
% All inputs and outputs are in metres or radians as appropriate.
%
% For the purpose of explaining the format/size of each input argument, the
%   number of Range Sensors being calibrated will be denoted NS, and the
%   number of Geometric Features over which the optimisation(s) will take
%   place will be denoted NF.
%
% SensorTransformsXYZYPR is an NS-by-6 matrix of the initial guess/estimate
%   of the pose of each range  sensor with respect to the 'NavSolutions' 
%   provided in the DATA. Each  row represents one sensor's pose, and the
%   6 columns represent the  offsets of  the sensor with respect to the nav
%   box as follows:
%       [ X, Y, Z, Yaw, Pitch, Roll ]
%   NOTE: The order of angles is Yaw,Pitch,Roll as these are the euler
%   angles, and their order (as listed) is important.
%
% DATA is an NF-by-NS struct array, in which the struct located at
%   DATA(F,S) is the data representing sensor S's view of feature F.
%       For example, given two geometric features, a Pole and a Ground
%       Plane, which are viewed by three laser range scanning sensors with
%       different poses with respect to the Nav Solution of a vehicle.
%       The first row of the DATA array will be a set of data from each
%       sensor that represents its view of the Pole, and the second row
%       will be a set of data from each sensor that represents its view of
%       the Ground Plane.
%   Each of the elements of DATA is a struct with the following fields
%       RangeData - matrix with M rows. Columns depend on which
%                 GeoregisterFunction you're using
%                 NOTE: M must be the same as M in NavData
%       NavData - matrix with M rows.  Columns depend on which
%                 georegisterFunction you're using.
%                 NOTE: M must be the same as M in RangeData.
%       GeoregisterFunction - A function pointer that knows how to compute
%                 the global position of each point in RangeData.  eg
%                 GetNEDPoints or GetXYZPoint_XYZq_RAE
%   NOTE: All structs in a struct array must have the same fields, and for 
%   the case where a particular sensor (S) does not have any data for a 
%   particular geometric feature (F), the fields within DATA(F,S) should
%   simply be empty matrices.
%
% COSTFUNS is an NF-by-1 cell vector of function handles, where COSTFUNS{F}
%   is the function to be used to determine the cost of the data provided
%   by each sensor in DATA(F,:).
%       The cost functions that the function handles in COSTFUNS point to
%       must take a single argument which is an M-by-3 matricx of cartesian
%       points, one per row in the format:
%           [ Northing, Easting, Down ]
%       The output of the cost function is a scalar cost with respect to
%       the internally defined geometric feature. Two simple such cost
%       functions have been provided:
%           - GeometricCostOfVerticalLine(pointsNED)
%               The cost is computed as the standard deviation of all the 
%               points from the vertical line at the mean N,E
%               coordinates of all the data points.
%           - GeometricCostOfHorizontalPlane(pointsNED)
%               The cost is computed as the standard deviation of all the
%               points from the horizontal plane at the mean D
%               (height) of all the data points.
%           NOTE: The framework of this code has been specifically designed
%           to allow users to implement their own cost functions meeting
%           the requirements above, as the number of possible geometric
%           features, and cost metrics of these are almost unlimited. For
%           example, if the object's location in the N,E,D coordinate frame
%           is accurately known, it may be much more useful to use this
%           location rather than the mean as in the functions provided.
%
% SensorTransformsLower and SensorTransformsUpper are the (optional) lower
% and upper bounds for the optimisation of SensorTransformsXYZYPR. They
% take the same format as the SensorTransformsXYZYPR but are the numerical
% minimum and maximum constraints used by fmincon. This is typically not
% required if there is sufficient data and a sufficiently accurate initial
% guess. However, depending on the range of vehicle movements and range of
% poses of the vehicle for which there is data, some values may not be able
% to be optimised especially well (e.g. the Z offset when only a vertical
% pole is used to optimise the sensor pose). Setting these to empty
% matrices allows OPTIONS to be specified without applying these
% constraints.
%
% OPTIONS can be created manually or with the OPTIMSET function. See
% OPTIMSET and FMINCON for details on how to set these options and which
% particular options are used. If OPTIONS is provided, all options should
% be set as desired, otherwise a default OPTIONS is used, specified within
% this matlab function.
%
% Outputs:
%
% SensorTransformsXYZYPR is the optimised set of range sensor poses in the
% same format as the input estimate of these poses.
% All of the outputs of fmincon are also available in the same order and
% format.
%
%   See also STRUCT, CELL, FUNCTION_HANDLE, FMINCON,
%   GeometricCostOfVerticalLine, GEOMETRICCOSTOFHORIZONTALPLANE,
%   GetNEDPoints, RBSensorMeanNED, MultiSensorMultiRegionCost.

function [ SensorTransformsXYZYPR, FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN ] = OptimiseSensorPoses( sensorTransformsXYZRPY0, dataSets, costFunctions, bounds, options )

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults where not specified
%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimset( 'Algorithm','active-set','MaxFunEvals', 2000, 'MaxIter', 1000, 'Display','iter', 'TolFun', 1e-6, 'TolX', 1e-9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%
ValidateInputData( sensorTransformsXYZRPY0, dataSets, costFunctions, bounds );

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[SensorTransformsXYZYPR,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = fmincon( ...
        @(SensorTransformsXYZYPR)MultiSensorMultiRegionCost(SensorTransformsXYZYPR, dataSets, costFunctions), ...
        sensorTransformsXYZRPY0, [], [], [], [], sensorTransformsXYZRPY0-bounds, sensorTransformsXYZRPY0+bounds, [], options);
