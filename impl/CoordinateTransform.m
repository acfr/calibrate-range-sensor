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