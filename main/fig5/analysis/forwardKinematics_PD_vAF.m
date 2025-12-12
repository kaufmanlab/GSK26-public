function posXYZout = forwardKinematics_PD_vAF(posXYZ, jointAngles)
% posXYZ input is a single trial of pose data for a set of markers from DLC
% posXYZ shape is Timepoints x XYZ x Markers

% Reconstructs only forelimb positions, leaves other markers as original

% Links, as pairs of markers
phal_dist = [[1, 5]; [2, 6]; [3, 7]; [4, 8]]; % distal phalanges
phal_prox = [[5, 9]; [6, 10]; [7, 11]; [8, 12]]; % proximal phalanges
phalanges = [phal_dist; phal_prox]; % all phalanges
metacarpals = [[9, 13]; [10, 13]; [11, 13]; [12, 13]]; %metacarpals
radius_ulna = [13,14]; % radius/ulna link
humerus = [14,15]; % humerus link

% unit normals, only used for shoulder
n_X = [1,0,0]'; % red
n_Z = [0,0,1]'; % green
n_Y = [0,1,0]'; % blue

% % Pre-allocate
posXYZout = zeros(size(posXYZ)); % This stores the completed posture
nTPts = size(posXYZ,1);

% Doing inverse kinematics here to make sure we are applying the angles to
% the appropriate skeleton
[jointAnglesOG, posXYZn, n_PIPs] = inverseKinematics_PD_vAF(posXYZ);

% Debug
% jointAngles = jointAnglesOG;

% Loop over time points, not optimized, done this way for clarity
for t = 1:nTPts
    % Subselect one time point
    posXYZt = squeeze(posXYZn(t,:,:));
    
    %% PROXIMAL-INTERPHALANGES
    
    posXYZt = revert_PIP(posXYZt, [4,8,12], jointAngles(t,24), n_PIPs(t,:,4)');
    posXYZt = revert_PIP(posXYZt, [3,7,11], jointAngles(t,23), n_PIPs(t,:,3)');
    posXYZt = revert_PIP(posXYZt, [2,6,10], jointAngles(t,22), n_PIPs(t,:,2)');
    posXYZt = revert_PIP(posXYZt, [1,5,9], jointAngles(t,21), n_PIPs(t,:,1)');
    
    %% FINGER SPLAY
    % Wrist vectors
    wrist_pos = posXYZt(:, 13);
    
    % Angles
    theta_splay12 = jointAngles(t,18);
    theta_splay23 = jointAngles(t,19);
    theta_splay34 = jointAngles(t,20);
    
    % Add angles on iteratively, this hurts performance for bad decodes
    % more than adding them absolutely would, but it is the most
    % straightforward given the method we used for inverse kinematics
    % From angle 34 -> angle 12
    fingers = [phal_prox(1,:); phal_dist(1,:); metacarpals(1,:); phal_prox(2,:); phal_dist(2,:); metacarpals(2,:); phal_prox(3,:); phal_dist(3,:); metacarpals(3,:)];
    posXYZt = makeNeutral(posXYZt, fingers, n_X, -theta_splay34, wrist_pos);
    fingers = [phal_prox(1,:); phal_dist(1,:); metacarpals(1,:); phal_prox(2,:); phal_dist(2,:); metacarpals(2,:)];
    posXYZt = makeNeutral(posXYZt, fingers, n_X, -theta_splay23, wrist_pos);
    fingers = [phal_prox(1,:); phal_dist(1,:); metacarpals(1,:)];
    posXYZt = makeNeutral(posXYZt, fingers, n_X, -theta_splay12, wrist_pos);
    
    %% METACARPOPHALANGEAL
    
    % Inverse of Method 2:
    % Flexion/extension
    posXYZt = revert_MCP(posXYZt, [4,8,12,13], 'flexion', [phal_prox(4,:); phal_dist(4,:)], jointAngles(t,11));
    posXYZt = revert_MCP(posXYZt, [3,7,11,13], 'flexion', [phal_prox(3,:); phal_dist(3,:)], jointAngles(t,10));
    posXYZt = revert_MCP(posXYZt, [2,6,10,13], 'flexion', [phal_prox(2,:); phal_dist(2,:)], jointAngles(t,9));
    posXYZt = revert_MCP(posXYZt, [1,5,9,13], 'flexion', [phal_prox(1,:); phal_dist(1,:)], jointAngles(t,8));
    % Abduction/adduction
    posXYZt = revert_MCP(posXYZt, [4,8,12,13], 'abd/add', [phal_prox(4,:); phal_dist(4,:)], jointAngles(t,15));
    posXYZt = revert_MCP(posXYZt, [3,7,11,13], 'abd/add', [phal_prox(3,:); phal_dist(3,:)], jointAngles(t,14));
    posXYZt = revert_MCP(posXYZt, [2,6,10,13], 'abd/add', [phal_prox(2,:); phal_dist(2,:)], jointAngles(t,13));
    posXYZt = revert_MCP(posXYZt, [1,5,9,13], 'abd/add', [phal_prox(1,:); phal_dist(1,:)], jointAngles(t,12));
    
    %% INTERMETACARPALS
    
    % MC opposition
    % Rotate first and last MC into YZ plane around n_Y
    wrist_pos = posXYZt(:, 13);
    % Angle of theta_opposition
    theta_MC4_opposition = jointAngles(t, 17);
    % Neutralize MC4 opposition
    posXYZt = makeNeutral(posXYZt, [phalanges([4,8],:); metacarpals(4,:)], -n_Y, -theta_MC4_opposition, wrist_pos);
    % Angle of theta_opposition
    theta_MC1_opposition = jointAngles(t, 16);
    % Neutralize MC1 opposition
    posXYZt = makeNeutral(posXYZt, [phalanges([1,5],:); metacarpals(1,:)], -n_Y, -theta_MC1_opposition, wrist_pos);
    
    %% WRIST
    
    % Inverse of Method 2:
    % Internal/external rotation
    posXYZt = revert_wrist(posXYZt, 'rotation', [phalanges; metacarpals], jointAngles(t,7));
    
    % Flexion/extension
    posXYZt = revert_wrist(posXYZt, 'flexion', [phalanges; metacarpals], jointAngles(t,5));
    
    % Abduction/Adduction
    posXYZt = revert_wrist(posXYZt, 'abd/add', [phalanges; metacarpals], jointAngles(t,6));
    
    %% ELBOW
    
    % "Euler" angle around n_X (flexion)
    elbow_position = posXYZt(:, 14);
    wrist_position = posXYZt(:, 13);
    vec_RU = wrist_position - elbow_position;
    theta_elbo_flexion = jointAngles(t,4);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, [radius_ulna; phalanges; metacarpals], n_X, -theta_elbo_flexion, elbow_position);
    
    %% SHOULDER
    
    % Inverse of Method 2:
    % Internal/external rotation
    posXYZt = revert_shoulder(posXYZt, 'rotation', [humerus; radius_ulna; phalanges; metacarpals], jointAngles(t,3));
    
    % Flexion/extension
    posXYZt = revert_shoulder(posXYZt, 'flexion', [humerus; radius_ulna; phalanges; metacarpals], jointAngles(t,1));
    
    % Abduction/Adduction
    posXYZt = revert_shoulder(posXYZt, 'abd/add', [humerus; radius_ulna; phalanges; metacarpals], jointAngles(t,2));
    
    %% Save
    posXYZout(t,:,:) = posXYZt;
end


function posXYZt = revert_shoulder(posXYZt, angle, links2Neutralize, theta)

% Method 1: FLEXION IS REMOVED FIRST, THEN ABD/ADD
% Method 2: ABD/ADD IS REMOVED FIRST, THEN FLEXION
% the operations are not commutative so while each calculation is the same,
% each method/order will produce a different value for each angle

% Params
n_X = [1,0,0]';
n_Y = [0,1,0]';
n_Z = [0,0,1]';

% Humerus vector, at origin
shldr_position = posXYZt(:, 15);
% elbo_position = posXYZt(:, 14);
% wrist_position = posXYZt(:, 13);
% vec_H = elbo_position - shldr_position;
% vec_RU = wrist_position - elbo_position;

if strcmp(angle, 'flexion')
    % "Euler" angles around n_X (flexion)
%     theta = atan2d(vec_H(2),-vec_H(3)); % flex
    %fprintf('theta_flex: %0.3f\n', theta_flex);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, n_X, -theta, shldr_position);
end

if strcmp(angle, 'abd/add')
    % "Euler" angle around n_Y (abd/add)
%     theta = atan2d(vec_H(1),-vec_H(3));
    %fprintf('theta_abd_add: %0.3f\n', theta_abd_add);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, n_Y, -theta, shldr_position);
end

if strcmp(angle, 'rotation')
    % "Euler" angle around n_Z of radius/ulna vector (rotation)
%     theta = atan2d(vec_RU(1),-vec_RU(2));
    %fprintf('theta_abd_add: %0.3f\n', theta_abd_add);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, n_Z, -theta, shldr_position);
end

function posXYZt = revert_wrist(posXYZt, angle, links2Neutralize, theta)

% Method 1: FLEXION IS REMOVED FIRST, THEN ABD/ADD
% Method 2: ABD/ADD IS REMOVED FIRST, THEN FLEXION
% the operations are not commutative so while each calculation is the same,
% each method/order will produce a different value for each angle

% Params
n_X = [1,0,0]';
n_Y = [0,1,0]';
n_Z = [0,0,1]';

% Wrist bisection vector, at origin
% like a virtual MC, from wrist to midpoint of MCP link
wrist_position = posXYZt(:, 13);
% Second and third MCs
% vec_MCa = posXYZt(:, 10) - wrist_position;
% vec_MCb = posXYZt(:, 11) - wrist_position;
% % Link connecting second and third MCP joints
% vec_MCcon = posXYZt(:, 10) - posXYZt(:, 11);
% vec_vMC = vec_MCb + vec_MCcon/2;
% % Normal vector to plane spanned by MC2 and MC3
% n_MC = cross(vec_MCb, vec_MCa)/norm(cross(vec_MCb, vec_MCa));

if strcmp(angle, 'flexion')
    % "Euler" angles around n_Z (flexion)
    % theta = atan2d(vec_vMC(1),-vec_vMC(2)); % flex
    % fprintf('theta_flex: %0.3f\n', theta_flex);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, -n_Z, -theta, wrist_position);
end

if strcmp(angle, 'abd/add')
    % "Euler" angle around n_X (abd/add)
    %theta = atan2d(vec_vMC(3),-vec_vMC(2));
    %fprintf('theta_abd_add: %0.3f\n', theta_abd_add);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, n_X, -theta, wrist_position);
end

if strcmp(angle, 'rotation')
    % "Euler" angle around -n_Z of MC2-MC3 plane normal (rotation)
%     theta = atan2d(n_MC(3),-n_MC(1));
    %fprintf('theta_abd_add: %0.3f\n', theta_abd_add);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, -n_Y, -theta, wrist_position);
end

function posXYZt = revert_MCP(posXYZt, finger, angle, links2Neutralize, theta)

% Method 1: FLEXION IS REMOVED FIRST, THEN ABD/ADD
% Method 2: ABD/ADD IS REMOVED FIRST, THEN FLEXION
% the operations are not commutative so while each calculation is the same,
% each method/order will produce a different value for each angle

% these are slightly different than the other flexion and abd/add
% calculations because the joint is oriented into the XY plane, not the ZY
% plane like the wrist and shoulder
% we rotate off the splay value for this finger assemblage to calculate
% the angles in the same XYZ coordinate frame as all the others

% Params
n_X = [1,0,0]';
n_Y = [0,1,0]';
n_Z = [0,0,1]';
wrist_position = posXYZt(:, finger(4));
MCP_position = posXYZt(:, finger(3));
vec_MC = MCP_position - wrist_position;
% Compute pseudo Y axis
n_pY = -vec_MC/norm(vec_MC); % pseudo Y axis, aligned to MC bone
% Compute pseudo Z axis
n_pZ = cross(n_X, n_pY)/norm(cross(n_X, n_pY)); % pseudo Z axis

% Compute splay, bringing vec_MC into XY plane
theta_splay = atan2d(n_pY(3), n_pY(2));

% Rotate off splay to compute F/A in XYZ coordinates
posXYZt = makeNeutral(posXYZt, [finger(1:2); finger(2:3)], -n_X, theta_splay, MCP_position);
% Compute finger vector for flexion/abd_add calculations
vec_PIP = posXYZt(:, finger(2)) - MCP_position;

if strcmp(angle, 'flexion')
    % "Euler" angles around -n_Z (flexion)
%     theta = atan2d(-vec_PIP(1),-vec_PIP(2)); % flex
    %fprintf('theta_flex: %0.3f\n', theta_flex);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, -n_Z, -theta, MCP_position);
    
    % Rotate splay back on
    posXYZt = makeNeutral(posXYZt, [finger(1:2); finger(2:3)], -n_X, -theta_splay, MCP_position);
end

if strcmp(angle, 'abd/add')
    % "Euler" angle around n_X (abd/add)
%     theta = atan2d(vec_PIP(3),-vec_PIP(2));
    %fprintf('theta_abd_add: %0.3f\n', theta_abd_add);
    % Neutralize
    posXYZt = makeNeutral(posXYZt, links2Neutralize, n_X, -theta, MCP_position);
    % Rotate splay back on
    posXYZt = makeNeutral(posXYZt, [finger(1:2); finger(2:3)], -n_X, -theta_splay, MCP_position);
end

function posXYZt = revert_PIP(posXYZt, finger, theta, n_PIP)

% We calculate this angle as the absolute angle between the distal
% phalanx and the proximal phalanx links, this does not exactly match the
% flexion of the finger that should take place entirely within the plane
% spanned by the X axis and the corresponding metacarpal, but it is close
% enough for government work

PIP_pos = posXYZt(:, finger(2));
% set up vectors
vec_dist = posXYZt(:, finger(1)) - PIP_pos;

% vec_prox = PIP_pos - posXYZt(:, finger(3));
% get angle of flexion
% theta = acosd(dot(vec_dist, vec_prox)/(norm(vec_dist)*norm(vec_prox)));
% rotate off
% n_PIP = cross(vec_dist, vec_prox)/norm(cross(vec_dist, vec_prox));

posXYZt(:, finger(1)) = rodriguesRot(vec_dist, n_PIP, -theta) + PIP_pos;

%
function posXYZ = makeNeutral(posXYZ, links, n_Rot, theta, origin)
for l = 1:length(links)
    vec = posXYZ(:, min(links(l,:))) - origin;
    posXYZ(:, min(links(l,:))) = rodriguesRot(vec, n_Rot, theta) + origin;
end