function [R, M, config] = loadData(mouseName, sessionDate, prefix, suffix, folder, verbose)
% loadData  Load an R/M neural-behavior dataset given identifying info.
% 
% Inputs:
%   mouseName    - animal ID string
%   sessionDate  - date string (YYMMDD)
%   prefix       - file prefix (default 'R')
%   suffix       - file suffix (default '')
%   folder       - optional folder
%   verbose      - flag for printing status (default 1)
%
% Outputs:
%   R       - R struct loaded from file (or data struct)
%   M       - M struct of kinematic/metadata (if present)
%   config  - metadata about file and session

% ------------------------ Handle defaults -------------------------------

if nargin < 3, prefix = 'R'; end
if nargin < 4, suffix = ''; end

% Default base path unless a custom folder is provided
% CHANGE FOR NEW USERS
if nargin < 5
    basePath = '';
else
    basePath = ['' folder];
end

if nargin < 6, verbose = 1; end

% ------------------------ Construct search pattern ------------------------

thePath = fullfile(basePath);
RName = sprintf('%s,%s_20%s_*%s.mat', prefix, mouseName, sessionDate, suffix);

if verbose
    fprintf('Looking for %s in %s... ', RName, thePath);
end

% Get directory listing of matching files
fold = dir(fullfile(thePath, RName));

% ------------------------ Resolve file matches ----------------------------

if length(fold) == 1
    % Exactly one match ? good
    RName = fold.name;
    if verbose, fprintf('found it... '); end

elseif isempty(fold)
    % No R-file found; check for behavior-only files
    fprintf('\nWarning: No R structs match criteria, checking for behavior-only files\n')
    fprintf('Looking for R struct called %s\n', RName(3:end));

    % Try same name without the 'R,' prefix
    fold = dir(fullfile(thePath, RName(3:end)));

    if length(fold) == 1
        RName = fold.name;
    elseif isempty(fold)
        error('No behavior structs match your criteria');
    else
        error('Multiple behavior structs match your criteria');
    end

else
    % More than one matching file ? ambiguous
    fold.name
    error('Multiple R structs match your criteria');
end

% ------------------------ Load file contents ------------------------------

loadT = tic;
RPath = fullfile(thePath, RName);
loadVar = load(RPath);

% Standard case: variables R and M exist
if isfield(loadVar, 'R')
    R = loadVar.R;
    M = loadVar.M;
else
    % Behavior-only data
    R = loadVar.data;
    M = [];
end

% ------------------------ Add joint metadata ------------------------------

M(1).jointNames = {'SHDRf', 'SHDRa', 'SHDRr', 'ELBOf', 'WRSTf', 'WRSTd', 'WRSTr', ...
    'MCP1f', 'MCP2f','MCP3f', 'MCP4f', 'MCP1a', 'MCP2a', 'MCP3a', 'MCP4a','MCP1o', 'MCP4o', ...
    'P1P2', 'P2P3', 'P3P4', 'PIP1f', 'PIP2f', 'PIP3f', 'PIP4f'};

M(1).shortJointNames = {'SHDRf', 'a', 'r', 'ELBOf', 'WRSTf', 'd', 'r', ...
    'MCPf1', '2', '3', '4', 'MCPa1', '2', '3', '4', 'MCPo1', '4', ...
    'P1-P2', '2-3', '3-4',  'PIPf 1', '2', '3', '4'};

% ------------------------ Build config struct ------------------------------

config.mouseName = R(1).animalID;
config.sessionDate = R(1).date(1:8);

[~, filename, ~] = fileparts(RPath);
config.filename = filename;

% Extract file suffix (for non-standard names)
try
    splitfilename = split(filename, ',');
    filesuffix = split(filename, splitfilename{2});
    config.filesuffix = filesuffix{2};
catch
    config.filesuffix = '';
end

config.fullFileName = RPath;

fprintf('loaded in %0.3fs \n', toc(loadT));

end
