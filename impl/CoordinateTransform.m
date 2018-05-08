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

function [pointInBFrameXYZ] = CoordinateTransform( pointInAFrameXYZ, frameBtoAOffsetXYZRPY )

xab=frameBtoAOffsetXYZRPY(:,1);
yab=frameBtoAOffsetXYZRPY(:,2);
zab=frameBtoAOffsetXYZRPY(:,3);
sinrollab=sin(frameBtoAOffsetXYZRPY(:,4));
cosrollab=cos(frameBtoAOffsetXYZRPY(:,4));
sinpitchab=sin(frameBtoAOffsetXYZRPY(:,5));
cospitchab=cos(frameBtoAOffsetXYZRPY(:,5));
sinyawab=sin(frameBtoAOffsetXYZRPY(:,6));
cosyawab=cos(frameBtoAOffsetXYZRPY(:,6));
xa=pointInAFrameXYZ(:,1);
ya=pointInAFrameXYZ(:,2);
za=pointInAFrameXYZ(:,3);

pointInBFrameXYZ = zeros( size(pointInAFrameXYZ) );

pointInBFrameXYZ(:,1) = xab - ya.*(cosrollab.*sinyawab - cosyawab.*sinpitchab.*sinrollab) + za.*(sinrollab.*sinyawab + cosrollab.*cosyawab.*sinpitchab) + xa.*cospitchab.*cosyawab;
pointInBFrameXYZ(:,2) = yab + ya.*(cosrollab.*cosyawab + sinpitchab.*sinrollab.*sinyawab) - za.*(cosyawab.*sinrollab - cosrollab.*sinpitchab.*sinyawab) + xa.*cospitchab.*sinyawab;
pointInBFrameXYZ(:,3) =                                                                    zab - xa.*sinpitchab + za.*cospitchab.*cosrollab + ya.*cospitchab.*sinrollab;

%this function was created by running the following symbolic code
%syms xab yab zab rollab pitchab yawab xa ya za xb yb zb Rx Ry Rz C
%Rx = [1,0,0; 0,cos(rollab),-sin(rollab); 0,sin(rollab),cos(rollab) ];
%Ry = [cos(pitchab),0,sin(pitchab); 0,1,0; -sin(pitchab),0,cos(pitchab)];
%Rz = [cos(yawab),-sin(yawab),0; sin(yawab),cos(yawab),0; 0,0,1];
%C=(Rz*Ry*Rx);
%T=[xab;yab;zab];
%Pa=[xa;ya;za];
%Pb = C*Pa + T;