function data = eventLockData(R, M, eventName, tPts, rois)
% data = eventLockData(R, M, eventName, tPts)
% data = eventLockData(R, M, eventName, tPts, rois)
% 
% Resample deconvolved calcium events into a new time base. For example,
% instead of having a time base that's set inconveniently to 32.17 ms by
% our scan rate, we can use a time base of 10 ms. Furthermore, this allows
% us to do sub-frame alignment, and to correct for the different lags of
% ROIs due to being scanned on different lines or in different planes.
% 
% This is not a standard interpolation. Instead, for every bin in the new
% time base that is completely inside the time of the original frame, we
% assign an equal value. For partially overlapping bins, we assign a value
% proportional to the overlap.
% 
% INPUTS
% R         -- from mergeBehavSuite2p
% M         -- from mergeBehavSuite2p
% eventName -- the field in R to lock to, e.g., 'grabTime'
% tPts      -- times relative to the locking event. E.g., -200:10:300.
%              Intervals must be faster than the original frame rate.
% rois      -- optional. Supply indices of ROIs if you only want one/some.
% 
% OUTPUTS
% data -- struct array, one element per trial. The data are in .data,
%         which is nTimePoints x nROIs. Also contains .locked, which tells
%         you whether this trial could be event-locked. If false,
%         data(tr).data will be empty.
% 
% See also: eventLockDataFluor.m

% This algorithm is fairly efficient. We first map tPts into (exact,
% non-integer) frames. Then, because the new time base is faster than the
% frame rate, each bin in the new time base will take data from a maximum
% of two frames. We can therefore find the contributions from the earlier
% and from the later frame, and add them.


%% Argument error checking

if nargin < 4
  error('eventLockData:badArgs', 'Supply 4 arguments');
end

if length(tPts) <= 1
  error('eventLockData:badTPts', ...
    'tPts should be a vector of time points relative to event, such as -100:10:300');
end

if ~isfield(R, eventName)
  error('eventLockData:badEventName', 'eventName must be the name of a field in R');
end

if any(isnan(tPts))
  error('eventLockData:nanTPts', 'tPts may not contain NaNs');
end

dTPts = diff(tPts);
if any(abs(dTPts - dTPts(1)) > 1e-8)
  error('eventLockData:badTPts', 'tPts must be evenly spaced');
end
tWidth = mean(dTPts);

if tWidth > M.cycleDurMs
  error('eventLockData:fastTPts', 'Spacing of tPts must be faster than the frame rate');
end

if nargin < 5
  rois = 1:length(M.ROILags);
end


%% Implement algorithm

nROIs = length(rois);
data.data = [];
data.locked = false;
data = repmat(data, 1, length(R));

tWidthInFr = tWidth / M.cycleDurMs;

for tr = 1:length(R)
    
  if ~R(tr).hasNeuralData
    continue;
  end
  
  %% Align to sync signal, map times to frames
  
  % Event relative to syncTime. Times in R.frameTimes are relative to
  % syncTime.
  evRelTime = R(tr).(eventName) - R(tr).syncTime;
  
  % Skip trial if event didn't happen
  if isnan(evRelTime)
    continue;
  end
  
  data(tr).locked = true;
  
  % Find the exact (non-integer) frame that the relevant event occurred
  % The +1 is because of Matlab's 1-indexing
  fr0 = 1 + (evRelTime - R(tr).frameTimes(1)) / M.cycleDurMs;
  
  % Map tPts to frames
  frPts = fr0 + tPts(:) / M.cycleDurMs;
  
  
  %% Loop through ROIs to do the "interp"
  
  data(tr).data = NaN(length(tPts), nROIs);

  for roi = 1:nROIs
    % Correct for lag due to ROI not being located at the very top of the
    % field of view. Note the minus: this is because, for an ROI that is
    % scanned *later*, to get info about this ROI from the same absolute
    % time, we need to look in an *earlier* frame
    rFrPts = frPts - M.ROILags(rois(roi)) / M.cycleDurMs;
    
    % Central part of the algorithm. See comment at top.
    earlyFrames = floor(rFrPts);
    lateFrames = ceil(rFrPts);
    earlyFrameContrib = min((lateFrames - rFrPts) / tWidthInFr, 1);
    lateFrameContrib = 1 - earlyFrameContrib;
    data(tr).data(:, roi) = R(tr).events(earlyFrames, rois(roi)) .* earlyFrameContrib + ...
      R(tr).events(lateFrames, rois(roi)) .* lateFrameContrib;
  end
  
  % Rescale to account for spreading out the events
  data(tr).data = data(tr).data * tWidthInFr;
end