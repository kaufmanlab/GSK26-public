function data = eventLockKinematics(R, M, eventName, tPts, varargin)
% data = eventLockKinematics(R, eventName, tPts, ...)
%
% Smooth, and time-lock video tracking data from DeepLabCut (3D
% version) from an R struct produced by mergeDLC3R.
%
% Smooth: Use either Savitsky-Golay (default) or Gaussian smoothing.
%
% Time-lock: Resample data, using linear interpolation, at the times
% specified by the user relative to locking event eventName. E.g., to get
% grab-locked data from 200 before the grab to 300 ms after, call:
% data = eventLockCams3(R, 'grabTime', -200:10:300);
%
%
% INPUTS
% R         -- from mergeDLC3R
% M         -- from mergeDLC3R
% eventName -- the field in R to lock to, e.g., 'grabTime'
% tPts      -- times relative to the locking event. E.g., -300:10:300.
%              Should be evenly spaced.
%
% OPTIONAL INPUT/VALUE PAIRS
% 'smooth'       -- Whether or not to smooth. Default 1.
% 'smoothMethod' -- 'Gaussian' (or 'Normal') for Gaussian smoothing, or
%                   'sgolay' (or 'Savitzky') for Savitzky-Golay filtering.
%                   Default 'sgolay'.
% 'lowConfThresh' -- We don't want to use garbage markers, so this
%                   specifies the minimum confidence we require to include
%                   a point. If a point is excluded, it is repaired with
%                   fillgaps.m. Default 0.9. 0 turns this off.
% 'gaussSD'      -- If using Gaussian smoothing, this is the std. dev. in
%                   ms. Default 10.
% 'sgolayPoly'   -- If using Savitzky-Golay filtering, this is the
%                   polynomial order. Default 2.
% 'sgolayWindow' -- If using Savitzky-Golay filtering, this is the window
%                   width, in ms. Default 40.
%
% OUTPUT
% data -- struct array, one element per input trial.
%   .cam       -- the useful data. Has as many elements as cameras.
%       .posXY -- marker position, times x XY x markers
%       .conf  -- confidence, times x markers
%   .locked    -- whether this trial could be time-locked to the event
%                 requested
%   .maxCams   -- whether the maximum number of cameras were available on
%                 this trial
%   .camsUsed  -- which cameras were used on this trial.
%   .posXYZ    -- the useful 3D data, created from posXYZAll
%   see the end of function for further fields, jointAngles/Velocities etc

%% Parameters

smoothMethods = {'Gaussian', 'Normal', 'Savitzky', 'sgolay'};

% Method for interpolating points to switch time base. Note that smoothing
% is a separate step that happens first.
interpMethod = 'linear';


%% Parse optional inputs

ip = inputParser;
ip.addParameter('smooth', 1, @(x) assert(islogical(x) || isnumeric(x)));
ip.addParameter('smoothMethod', 'Gaussian');
ip.addParameter('gaussSD', 15, @isnumeric);
ip.addParameter('sgolayPoly', 2, @isnumeric);
ip.addParameter('sgolayWindow', 40, @isnumeric);
ip.addParameter('addMatrix', 0);
ip.addParameter('centroidMarkers', 9:12);
ip.addParameter('addVelocity', 1);
ip.addParameter('addAcceleration', 1);
ip.addParameter('addJoints', 1);
ip.addParameter('addCentroid', 1);
ip.addParameter('createAllMatrix', 1);
ip.parse(varargin{:});

% Validate smoothMethod, merge
if ip.Results.smooth
    smoothMethod = validatestring(ip.Results.smoothMethod, smoothMethods);
    switch smoothMethod
        case 'Normal'
            smoothMethod = 'Gaussian';
        case 'Savitzky'
            smoothMethod = 'sgolay';
    end
end

if length(unique(diff(tPts))) > 1
    error('eventLockCams2:badTPts', 'tPts should be evenly spaced');
end

if ~isfield(R, eventName)
    R = waterGrabAnnotateBehav(R, M, 2);
    if ~isfield(R, eventName)
        error('eventLockCams2:badEventName', 'eventName must be the name of a field in R');
    end
end


%% Basic bookkeeping

firstCamTr = find([R.maxCams] == 1, 1);
camTimeBase = median(diff(R(firstCamTr).cam(1).times));


%% Clean up Savitzky-Golay window width

if ip.Results.smooth && strcmp(smoothMethod, 'sgolay')
    % Convert window from ms to points
    sgolayWindow = ceil(ip.Results.sgolayWindow / camTimeBase);
    % Ensure the window is an odd integer
    if mod(sgolayWindow, 2) == 0
        sgolayWindow = sgolayWindow + 1;
    end
    % Ensure the window is long enough
    if sgolayWindow < ip.Results.sgolayPoly + 1
        sgolayWindow = ip.Results.sgolayPoly + 1;
        warning('Filter requested was too short for poly order; using %d', sgolayWindow);
    end
end


%% Prep data structure

data.animalID = [];
data.date = [];
data.posXYZ = [];
data.locked = false;
data.trialN = [];
data = repmat(data, 1, length(R));


%% Main processing

if ~isfield(R, 'posXYZ')
    R = addPosXYZ(R);
end

for tr = 1:length(R)
    data(tr).animalID = R(tr).animalID;
    data(tr).eventName = eventName;
    data(tr).tPts = tPts;
    data(tr).trialNumber = R(tr).trialNumber;
    data(tr).date = R(tr).date;
    data(tr).LR = R(tr).LR;
    
    if isfield(R, 'condition')
        data(tr).condition = R(tr).condition;
    end
    
    if isfield(R, 'wrongGrabFirst')
        data(tr).wrongGrabFirst = R(tr).wrongGrabFirst;
    end
    
    if isfield(R, 'goodDLC')
        data(tr).goodDLC = R(tr).goodDLC;
    end
    
    %% Check if we can lock to this event on this trial
    
    if isnan(R(tr).(eventName))
        % No aligning event this trial, skip it
        continue;
    end
    
    if isempty(R(tr).posXYZ)
        % No pose information at all, skip trial
        continue
    end
    
    data(tr).locked = true;
    
    % Set position and joint angle data for extraction
    posXYZ = R(tr).posXYZ;
    if ~isfield(R, 'jointAngles')
        [angJ,~] = getInverseKinematics(posXYZ); % takes 0.2s per trial
    else
        angJ = R(tr).jointAngles;
    end
    
    %% Smooth
    
    % Accounting for lost bins in the velocity and acceleration by doubling
    % up on the last bin, this is only an issue if we are asked to lock
    % with the last two bins of data, something that should happen rarely
    
    if ip.Results.smooth
        
        switch smoothMethod
            case 'Gaussian'
                % Markers
                siz = size(posXYZ);
                posXYZ = reshape(posXYZ, siz(1), []);
                posXYZ = gaussFilt1(posXYZ, ip.Results.gaussSD / camTimeBase);
                posXYZ = reshape(posXYZ, siz);
                
                velXYZ = diff(posXYZ);
                velXYZ = [velXYZ; velXYZ(end,:,:)];
                siz = size(velXYZ);
                velXYZ = reshape(velXYZ, siz(1), []);
                velXYZ = gaussFilt1(velXYZ, ip.Results.gaussSD / camTimeBase);
                velXYZ = reshape(velXYZ, siz);
                
                accXYZ = diff(velXYZ);
                accXYZ = [accXYZ; accXYZ(end,:,:)];
                siz = size(accXYZ);
                accXYZ = reshape(accXYZ, siz(1), []);
                accXYZ = gaussFilt1(accXYZ, ip.Results.gaussSD / camTimeBase);
                accXYZ = reshape(accXYZ, siz);
                
                % Joint angles
                angJ = gaussFilt1(angJ, ip.Results.gaussSD / camTimeBase);
                
                velJ = diff(angJ);
                velJ = [velJ; velJ(end,:)];
                velJ = gaussFilt1(velJ, ip.Results.gaussSD / camTimeBase);
                
                accJ = diff(velJ);
                accJ = [accJ; accJ(end,:)];
                accJ = gaussFilt1(accJ, ip.Results.gaussSD / camTimeBase);
                
                % Aperture
                aperture = getAperture(posXYZ);
                daperture = diff(aperture);
                daperture = [daperture, daperture(end)];
                daperture = gaussFilt1(daperture, ip.Results.gaussSD / camTimeBase);
                
            case 'sgolay'
                % Markers
                siz = size(posXYZ);
                posXYZ = sgolayfilt(posXYZ, ip.Results.sgolayPoly, sgolayWindow);
                posXYZ = reshape(posXYZ, siz);
                
                velXYZ = diff(posXYZ);
                velXYZ = [velXYZ; velXYZ(end,:,:)];
                siz = size(velXYZ);
                velXYZ = sgolayfilt(velXYZ, ip.Results.sgolayPoly, sgolayWindow);
                velXYZ = reshape(velXYZ, siz);
                
                accXYZ = diff(velXYZ);
                accXYZ = [accXYZ; accXYZ(end,:,:)];
                siz = size(accXYZ);
                accXYZ = sgolayfilt(accXYZ, ip.Results.sgolayPoly, sgolayWindow);
                accXYZ = reshape(accXYZ, siz);
                
                % Joint angles
                angJ = sgolayfilt(angJ, ip.Results.sgolayPoly, sgolayWindow);
                
                velJ = diff(angJ);
                velJ = [velJ; velJ(end,:)];
                velJ = sgolayfilt(velJ, ip.Results.sgolayPoly, sgolayWindow);
                
                accJ = diff(velJ);
                accJ = [accJ; accJ(end,:)];
                accJ = sgolayfilt(accJ, ip.Results.sgolayPoly, sgolayWindow);
        end
        
    end
    
    %% Switch time base for cameras to event-locked
    
    camTimes = R(tr).cam(1).times + R(tr).syncTime - R(tr).(eventName);
    velscale = camTimeBase / 1000;
    accscale = velscale * velscale;
    
    %% Cut out relevant chunks using linear interpolation for 3D data
    
    % Interpolate for marker positions
    data(tr).posXYZ = interp1(camTimes, posXYZ, tPts, interpMethod);
    
    % Interpolate for marker velocities
    data(tr).velXYZ = interp1(camTimes, velXYZ / velscale, tPts, interpMethod);
    
    % Interpolate for marker accelerations
    data(tr).accXYZ = interp1(camTimes, accXYZ / accscale, tPts, interpMethod);
    
    % Interpolate for joint angles
    data(tr).jointAngles = interp1(camTimes, angJ, tPts, interpMethod);
    
    % Interpolate for joint velocities
    data(tr).jointVelocities = interp1(camTimes, velJ / velscale, tPts, interpMethod);
    
    % Interpolate for joint accelerations
    data(tr).jointAccelerations = interp1(camTimes, accJ / accscale, tPts, interpMethod);
    
    % Aperture and daperture
    data(tr).aperture = interp1(camTimes, aperture, tPts, interpMethod);
    data(tr).daperture = interp1(camTimes, daperture / velscale, tPts, interpMethod);
    
    % Compute centroid if desired
    if ip.Results.addCentroid
        data(tr).CposXYZ = mean(data(tr).posXYZ(:,:, ip.Results.centroidMarkers), 3);
        data(tr).CvelXYZ = mean(data(tr).velXYZ(:,:, ip.Results.centroidMarkers), 3);
        data(tr).CaccXYZ = mean(data(tr).accXYZ(:,:, ip.Results.centroidMarkers), 3);
    end
        
    % Add dist2Spout
    if isfield(M, 'plotParams')
        if isfield(M.plotParams, 'spoutPose')
            spoutPoseL = M.plotParams.spoutPose(4,:);
            spoutPoseR = M.plotParams.spoutPose(2,:);
            [data(tr).dist2Spout, data(tr).dist2Tongue, data(tr).tongueLength] = getDists(data(tr), spoutPoseL, spoutPoseR);
        end
    end
    
    % Reshape the DLC tensors to matrices if desired
    if ip.Results.addMatrix
        data(tr).posMat = reshape(data(tr).posXYZ, size(data(tr).posXYZ,1), []);
        data(tr).velMat = reshape(data(tr).velXYZ, size(data(tr).velXYZ,1), []);
        data(tr).accMat = reshape(data(tr).accXYZ, size(data(tr).accXYZ,1), []);
    end
    
    % Add touch mask, indicating time bins where he is contact with the
    % spout
    data(tr).contactBins = getContactBins(R(tr), eventName, tPts);
    
end

end

function contactBins = getContactBins(Rtr, eventName, tPts)

cycleTimes = Rtr.cycleTimes - Rtr.(eventName);

if isfield(Rtr, 'targets')
    touchSensor = Rtr.lickTouch;
    touchThresh = Rtr.lickThresh;
else
    if Rtr.LR == 1
        touchSensor = Rtr.lickTouchL;
        touchThresh = Rtr.lickThreshL;
    else
        touchSensor = Rtr.lickTouchR;
        touchThresh = Rtr.lickThreshR;
    end
end

% Interpolate to new time base
touchInterp = interp1(cycleTimes, touchSensor, tPts, 'linear');
% Bins that exceed threshold
contactBins = touchInterp > touchThresh;

end

function [dist2Spouts, dist2Tongue, tongueLength] = getDists(data, spoutPoseL, spoutPoseR)

% Add dist2Spout
if data.locked
    
    posXYZ = data.posXYZ; % Get paw centroid position over time
    
    % Pre-allocate
    tBins = size(posXYZ, 1);
    nMarkers = size(posXYZ, 3);
    dist2Spouts = zeros(tBins, nMarkers);
    dist2Tongue = zeros(tBins, nMarkers);
    tongueLength = zeros(1,tBins);
    
    % Use the correct spout
    trialType = data.LR;
    if trialType == 1
        targetSpoutPose = spoutPoseL;
        nontargetSpoutPose = spoutPoseR;
    elseif trialType == 2
        targetSpoutPose = spoutPoseR;
        nontargetSpoutPose = spoutPoseL;
    end
    
    for t = 1:tBins
        % Get vector pointing from current position to target spout
        onTargetVec = targetSpoutPose' - squeeze(posXYZ(t,:,:));
        % Save the norm
        dist2Spouts(t, :, 1) = vecnorm(onTargetVec, 2, 1);
        % Get vector pointing from current position to non-target spout
        onTargetVec = nontargetSpoutPose' - squeeze(posXYZ(t,:,:));
        % Save the norm
        dist2Spouts(t, :, 2) = vecnorm(onTargetVec, 2, 1);
        
        if size(posXYZ) > 15
            % Get vector pointing from current position to tongue
            onTargetVec = squeeze(posXYZ(t,:,19))' - squeeze(posXYZ(t,:,:));
            % Save the norm
            dist2Tongue(t, :) = vecnorm(onTargetVec, 2, 1);
            
            % Get vector between two tongue markers
            vec = squeeze(posXYZ(t,:,19))' - squeeze(posXYZ(t,:,18))';
            % Save the norm
            tongueLength(t) = vecnorm(vec, 2, 1);
        else
            tongueLength = [];
        end
        
    end
    
else
    tongueLength = [];
    dist2Spouts = [];
    dist2Tongue = [];
end

end

function aperture = getAperture(posXYZ)

% This computes aperture of paw
% Could be improved to be more robust to marker order/number changes

ntPts = size(posXYZ,1);
aperture = zeros(1, ntPts);
for t = 1:ntPts
    triangleAreas = zeros(1, 3);
    wrist = posXYZ(t, :, 13);
    digits = 1:4;
    for q=1:4-1
        
        phalanxA = squeeze(posXYZ(t, :, digits(q)));
        phalanxB = squeeze(posXYZ(t, :, digits(q)+1));
        side1 = sqrt(sum((phalanxA - wrist).^2));
        side2 = sqrt(sum((phalanxB - wrist).^2));
        side3 = sqrt(sum((phalanxA - phalanxB).^2));
        s = (side1 + side2 + side3)/2;
        area = sqrt(s * (s-side1) * (s-side2) * (s-side3));
        
        triangleAreas(1, q) = area;
    end
    aperture(t) = mean(triangleAreas);
    
end
end