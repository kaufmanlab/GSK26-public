function printFigs(figNums, folderName, format, fileTitles, landscape)
% useage:
%   printFigs(figNums, folderName)
%   printFigs(figNums, folderName, format)
%   printFigs(figNums, folderName, format, fileTitles)
%
%   figNums is just a list of the figure numbers (e.g., 1:10)
%   if folderName doesn't exist, it will be created, and you will be told
%
%   fileTitles is a cell array of strings, one for each figNums value, if
%   there are not enough strings, the figures will be saved with the
%   figNums values for their names
%
%   'format' is optional.  The default is '-dpdf'.
%   You can also use '-depsc2' (postscript lv 2), '-djpeg', '-dill' (ai), '-dtiff',
%
% examples:
%   printFigs(1:16, '')     prints 16 pdf files into the current directory
%   printFigs(1:16, 'printedFigures2')   puts the files in the directory printedFigures2 (created if necessary)
%   printFigs(1:16, '', '-djpeg')  output as jpeg into the current directory
%   printFigs(2, 'printedFigures2', '-dpdf', 'myFig');  prints fig 2 as a single pdf named 'myFig' into
%           % the folder 'printedFigures2'.  Note that the fig number should be a scalar.
%

if ~exist('landscape', 'var')
    landscape = 0;
end

if exist('fileTitles', 'var')
    if ~iscell(fileTitles)
        fileTitles = {fileTitles};
    end
end

if exist('fileTitles', 'var') && length(fileTitles) ~= length(figNums)
    disp('Beware, each figure did not have a corresponding title, defaulting to figure number titles');
    clear fileTitles
end

% default file format is encapsulated postscript level 2
if ~exist('format', 'var'), format = '-dpdf'; end

if ~isempty(folderName)
    if ~isfolder(folderName)
        fprintf('making folder %s\n', folderName);
        mkdir(folderName);
    end
    folderName = strcat(folderName, '/');
end

for f = 1:length(figNums)
    if exist('fileTitles', 'var')
        filename = sprintf('%s%s', folderName, fileTitles{f});
    else
        filename = sprintf('%sfigure%d', folderName, figNums(f));
    end
    
    % orientation
    if landscape
        orient(figure(figNums(f)),'landscape')
    end
    
    % Print info for debugging
    fprintf('Printing figure %i as %s at %s \n', figNums(f), format(3:end), filename);
    set(figNums(f),'InvertHardCopy','off'); % Dont invert background color
    if strcmp(format, '-dpdfbf')
        set(figNums(f), 'Color', 'none')
        print(figNums(f), '-dpdf', '-painters', '-r300', filename, '-bestfit');
    elseif strcmp(format, '-dpdffp')
        set(figNums(f), 'Color', 'none')
        print(figNums(f), '-dpdf', '-painters', '-r300', filename, '-fillpage');
    else
%         set(figNums(f), 'Color', 'none')
        print(figNums(f), format, '-painters', '-r300', filename);
    end
end
end