function plotSkeletonEulerAngles(data, tPt, plotParams, view)
% Plots a single time point posture and annotates the angles around which
% we computed the major joint angles (mostly proximal due to over clutter
% if all are plotted)

% Figure
fig;
hA = gca;
axis off
axis equal
hold on;
set(gca,'View', view);
hA.ZLim = [-5, 15];
hA.XLim = [-15, 5];
hA.YLim = [95, 120];

% Plot data
drawSkeleton(hA, data.posXYZ(tPt,:,:), plotParams);
drawMarkers(hA, data.posXYZ(tPt,:,:), plotParams);

% Angles
theta_elbo_flexion = data.jointAngles(tPt,4);
theta_shldr_rotation = data.jointAngles(tPt,3);
theta_shldr_abdadd = data.jointAngles(tPt,2);
theta_shldr_flexion = data.jointAngles(tPt,1);

% Shoulder coords
scale = 2;
Z = [0,0,scale]';
Y = [0,scale,0]';
X = [scale,0,0]';
shldr_position = data.posXYZ(tPt,:,15);
arrow3D([shldr_position(1), shldr_position(2), shldr_position(3)], [X(1), X(2), X(3)], [1,0,0], 0.75)
arrow3D([shldr_position(1), shldr_position(2), shldr_position(3)], [Y(1), Y(2), Y(3)], [0,1,0], 0.75)
arrow3D([shldr_position(1), shldr_position(2), shldr_position(3)], [Z(1), Z(2), Z(3)], [0,0,1], 0.75)

% Global
n_Z = [0,0,1]';
n_Y = [0,1,0]';
n_X = [1,0,0]';

% Elbo coords
Z = [0,0,scale]';
Y = [0,scale,0]';
X = [scale,0,0]';
elbow_position = data.posXYZ(tPt,:,14);

% Rotate CF around Z by -theta_shdlr_rot to add on shoulder rotation
Z = rodriguesRot(Z, n_Z, -theta_shldr_rotation);
Y = rodriguesRot(Y, n_Z, -theta_shldr_rotation);
X = rodriguesRot(X, n_Z, -theta_shldr_rotation);

% Rotate CF around X by -theta_shdlr_flexion to add on shoulder
% flexion
Z = rodriguesRot(Z, n_X, -theta_shldr_flexion);
Y = rodriguesRot(Y, n_X, -theta_shldr_flexion);
X = rodriguesRot(X, n_X, -theta_shldr_flexion);

% Rotate CF around Y by -theta_shdlr_abdadd to add on shoulder
% abduction
Z = rodriguesRot(Z, n_Y, -theta_shldr_abdadd);
Y = rodriguesRot(Y, n_Y, -theta_shldr_abdadd);
X = rodriguesRot(X, n_Y, -theta_shldr_abdadd);

% Plot
arrow3D([elbow_position(1), elbow_position(2), elbow_position(3)], [X(1), X(2), X(3)], [1,0,0], 0.75)
arrow3D([elbow_position(1), elbow_position(2), elbow_position(3)], [Y(1), Y(2), Y(3)], [0,1,0], 0.75)
arrow3D([elbow_position(1), elbow_position(2), elbow_position(3)], [Z(1), Z(2), Z(3)], [0,0,1], 0.75)

% Wrist coords
Z = [0,0,scale]';
Y = [0,scale,0]';
X = [scale,0,0]';
wrist_position = data.posXYZ(tPt,:,13);

% Rotate CF by X for elbow flexion
Z = rodriguesRot(Z, n_X, -theta_elbo_flexion);
Y = rodriguesRot(Y, n_X, -theta_elbo_flexion);
X = rodriguesRot(X, n_X, -theta_elbo_flexion);

% Rotate CF around Z by -theta_shdlr_rot to add on shoulder rotation
Z = rodriguesRot(Z, n_Z, -theta_shldr_rotation);
Y = rodriguesRot(Y, n_Z, -theta_shldr_rotation);
X = rodriguesRot(X, n_Z, -theta_shldr_rotation);

% Rotate CF around X by -theta_shdlr_flexion to add on shoulder
% flexion
Z = rodriguesRot(Z, n_X, -theta_shldr_flexion);
Y = rodriguesRot(Y, n_X, -theta_shldr_flexion);
X = rodriguesRot(X, n_X, -theta_shldr_flexion);

% Rotate CF around Y by -theta_shdlr_abdadd to add on shoulder
% abduction
Z = rodriguesRot(Z, n_Y, -theta_shldr_abdadd);
Y = rodriguesRot(Y, n_Y, -theta_shldr_abdadd);
X = rodriguesRot(X, n_Y, -theta_shldr_abdadd);

% Plot
arrow3D([wrist_position(1), wrist_position(2), wrist_position(3)], [X(1), X(2), X(3)], [1,0,0], 0.75)
arrow3D([wrist_position(1), wrist_position(2), wrist_position(3)], [Y(1), Y(2), Y(3)], [0,1,0], 0.75)
arrow3D([wrist_position(1), wrist_position(2), wrist_position(3)], [Z(1), Z(2), Z(3)], [0,0,1], 0.75)

end