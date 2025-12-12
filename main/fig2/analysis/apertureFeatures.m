function kinematics = apertureFeatures(kinematics)
% Computes kinematic features related to paw aperture

for tr = 1:length(kinematics)
    % Find max speed
    zvel = kinematics(tr).CvelXYZ(:,3);
    [~, maxzvelbin] = max(zvel);
    kinematics(tr).maxZVelBin = maxzvelbin;
    kinematics(tr).maxZVelTime = kinematics(tr).tPts(maxzvelbin);
    
    % Find zvelocity peaks
    bins = kinematics(tr).tPts > 0 & kinematics(tr).tPts < kinematics(tr).eventInterval;
    minheight = 20;
    [pks, locs] = findpeaks(zvel(bins), 'MinPeakHeight', minheight);
    kinematics(tr).nPeaks = length(pks);
    kinematics(tr).zPeaks = bins(locs);
    
    % Aperture
    aperture = kinematics(tr).aperture;
    
    % Find peaks after maxzvelbin
    bins = maxzvelbin:length(aperture);
    [~, locs] = findpeaks(-aperture(bins));
   
    % If no peak found, check in a larger window around maxzvelbin, but if
    % no peak is still found, then this trial is discarded
    if isempty(locs)
        % Find peaks after maxzvelbin
        bins = maxzvelbin - 5:length(aperture);
        [~, locs] = findpeaks(-aperture(bins));
    end
    
    % Check again
    if isempty(locs)
        kinematics(tr).collectBin = NaN;
        kinematics(tr).collectTime = NaN;
    else
        % Find best collect candidate, the one closest in time to max z vel
        % If there is a tie, choose the bin with the smaller aperture
        [~, closepks] = min(abs(bins(locs) - maxzvelbin));
        
        if length(closepks) > 1
            [~, closepk] = min(aperture(bins(locs)));
            bestpk = bins(locs(closepk));
        else
            bestpk = bins(locs(closepks));
        end
        
        % Save
        kinematics(tr).collectBin = bestpk;
        kinematics(tr).collectTime = kinematics(tr).tPts(bestpk);
    end
        
    % Find extend bin, next aperture peak after collect
    if ~isnan(kinematics(tr).collectBin)
        bins = kinematics(tr).collectBin:length(aperture);
        
        % If we have sufficient bins between collect and extend
        if length(bins) > 3
            % Find peaks
            [~, locs] = findpeaks(aperture(bins));
            % If no peak found, this trial can't be analyzed
            if isempty(locs)
                kinematics(tr).extendBin = NaN;
                kinematics(tr).extendTime = NaN;
            else
                % Find first peak after aperture
                [~, bestpk] = min(locs);
                kinematics(tr).extendBin = bins(locs(bestpk));
                kinematics(tr).extendTime = kinematics(tr).tPts(bins(locs(bestpk)));
            end
        else
            kinematics(tr).extendBin = NaN;
            kinematics(tr).extendTime = NaN;
        end
        
    else
        kinematics(tr).extendBin = NaN;
        kinematics(tr).extendTime = NaN;
    end
end

end