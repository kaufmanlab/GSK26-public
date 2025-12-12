function vrot = rodriguesRot(v, k, theta, angle_type)
% rotate a vector v in R3 by theta around the axis of rotation defined by
% unit vector k in R3, in degrees or radians

if nargin < 4
    angle_type = 'degrees';
end

if strcmp(angle_type, 'degrees')
    cos_theta = cosd(theta);
    sin_theta = sind(theta);
else
    cos_theta = cos(theta);
    sin_theta = sin(theta);
end

if norm(k) ~= 1
    k = k/norm(k);
end

term1 = v*cos_theta;
term2 = cross(k,v)*sin_theta;
term3 = k*dot(k,v)*(1-cos_theta);

vrot = term1 + term2 + term3;

end