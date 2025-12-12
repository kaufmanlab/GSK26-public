function rotatedData = rotatePoints(alignmentVector, originalData)
% Rotate a set of points around a specific axis using matrix and vector
% operations

DOF = size(originalData,2);

% Rotating in 2D
if DOF==2
    [rad_theta, rho] = cart2pol(alignmentVector(1), alignmentVector(2));
    deg_theta = -1 * rad_theta * (180/pi);
    ctheta = cosd(deg_theta);  stheta = sind(deg_theta);
    
    Rmatrix = [ctheta, -1.*stheta;...
        stheta,     ctheta];
    rotatedData = originalData*Rmatrix;
    
else  % Rotating in 3D
    [rad_theta, rad_phi, rho] = cart2sph(alignmentVector(1), alignmentVector(2), alignmentVector(3));
    rad_theta = rad_theta * -1;
    deg_theta = rad_theta * (180/pi);
    deg_phi = rad_phi * (180/pi);
    ctheta = cosd(deg_theta);  stheta = sind(deg_theta);
    Rz = [ctheta,   -1.*stheta,     0;...
        stheta,       ctheta,     0;...
        0,                 0,     1];
    rotatedData = originalData*Rz;
    [rotX, rotY, rotZ] = sph2cart(-1* (rad_theta+(pi/2)), 0, 1);
    rotationAxis = [rotX, rotY, rotZ];
    u = rotationAxis(:)/norm(rotationAxis);
    cosPhi = cosd(deg_phi);
    sinPhi = sind(deg_phi);
    invCosPhi = 1 - cosPhi;
    x = u(1);
    y = u(2);
    z = u(3);
    Rmatrix = [cosPhi+x^2*invCosPhi        x*y*invCosPhi-z*sinPhi     x*z*invCosPhi+y*sinPhi; ...
        x*y*invCosPhi+z*sinPhi      cosPhi+y^2*invCosPhi       y*z*invCosPhi-x*sinPhi; ...
        x*z*invCosPhi-y*sinPhi      y*z*invCosPhi+x*sinPhi     cosPhi+z^2*invCosPhi]';
    rotatedData = rotatedData*Rmatrix;
end
