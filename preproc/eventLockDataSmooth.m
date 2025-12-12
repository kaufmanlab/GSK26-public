function data = eventLockDataSmooth(R, M, eventName, tPts, varargin)
% data = eventLockDataSmooth(R, M, eventName, tPts [, smoothSD] [, rois] [, field])
% 
% Similar to eventLockData() and eventLockDataFluor(), but smooths the
% data.
% 
% Like eventLockData() and eventLockDataFluor(), this function returns data
% that has been interpolated to a new time base and locked to a behavioral
% event, given by eventName. See documentation for either function for
% details about locking and arguments.
% 
% This function uses extra padding at both ends of the data to improve
% accuracy of the ends after smoothing, then trims the padding back off.
% 
% smoothSD, if provided, should be in ms. Default 50.
% rois defaults to including all ROIs. To use default but also set field,
%   supply [].
% field should be 'events', 'rawFluor', or 'denoised'. Default 'events'.
%   Note that only 'events' is guaranteed to be in the R struct; other
%   fields are only present if that option is chosen at merge time.


%% Parameters

extraSDs = 2;
smoothSD = 50;
rois = [];
field = 'events';


%% Optional arguments

if length(varargin) >= 1 && ~isnan(varargin{1})
  smoothSD = varargin{1};
end
if length(varargin) >= 2
  rois = varargin{2};
end
if length(varargin) >= 3
  field = varargin{3};
end

validFields = {'events', 'rawFluor', 'denoised', 'redFluor'};
field = validatestring(field, validFields);

firstNeural = find([R.hasNeuralData], 1);
if isempty(rois)
  rois = 1:size(R(firstNeural).events, 2);
end


%% Determine time points to extract, with extra at ends for smoothing

timeBase = diff(tPts(1:2));

% Want to add extraSDs worth of padding, but also want to make sure we
% don't shift the points even if smoothSD / timeBase isn't an integer
nExtraPts = ceil(extraSDs * smoothSD / timeBase);
first = tPts(1) - timeBase * nExtraPts;
last = tPts(end) + timeBase * nExtraPts;

paddedTPts = first:timeBase:last;

firstRealPt = nExtraPts + 1;
lastRealPt = firstRealPt + length(tPts) - 1;
realPts = firstRealPt:lastRealPt;


%% Gather data, smooth

% Gather
% If using 'events', use the faster function
if strcmpi(field, 'events')
  data = eventLockData(R, M, eventName, paddedTPts, rois);
else
  data = eventLockDataFluor(R, M, field, eventName, paddedTPts, rois);
end

% Smooth and extract relevant points
if smoothSD > 0
  for tr = 1:length(data)
    if ~isempty(data(tr).data)
      data(tr).data = gaussFilt1(data(tr).data, smoothSD / timeBase, 1);
      data(tr).data = data(tr).data(realPts, :);
    end
  end
end
