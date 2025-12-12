function [R, M] = timeClus(R, M, field)
% Group trials by median of the desired timing field

% Get times
medFieldTime_L = nanmedian([R([R.goodDLC] == 1 & [R.LR] == 1).(field)]);
medFieldTime_R = nanmedian([R([R.goodDLC] == 1 & [R.LR] == 2).(field)]);

% Save information
M.clusField = [field 'Clus'];
cmapClus_L = [[0,0.78125,1];[0, 0, 1]]; % long movement time is dark color
cmapClus_R = [[1, 0.78125, 0];[1,0,0]];
cmapClusLight_L = colormapHSV(cmapClus_L, [], 0.5, []);
cmapClusLight_R = colormapHSV(cmapClus_R, [], 0.5, []);
M.cmapClus = [cmapClus_L; cmapClus_R];
M.cmapClusLight = [cmapClusLight_L; cmapClusLight_R];
M.clusTypes = [1;1;2;2];
M.cmapClusInfo = [[1;2;3;4],[1;1;2;2],[1;2;3;4]];
M.nClusters = length(M.clusTypes);

% Loop over trials assigning groups
for tr = 1:length(R)
    if R(tr).goodDLC == 1
        fieldTime = R(tr).(field);
        if R(tr).LR == 1
            if fieldTime < medFieldTime_L
                R(tr).([field 'Clus']) = 1;
            else
                R(tr).([field 'Clus']) = 2;
            end
        elseif R(tr).LR == 2
            if fieldTime < medFieldTime_R
                R(tr).([field 'Clus']) = 3;
            else
                R(tr).([field 'Clus']) = 4;
            end
        end
    else
        R(tr).([field 'Clus']) = NaN;
    end
end

end