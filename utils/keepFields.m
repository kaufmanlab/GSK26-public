function sOut = keepFields(sIn, keepList)
%KEEPFIELDS  Keep only specified fields in a struct.
%
%   sOut = KEEPFIELDS(sIn, keepList)
%
%   Inputs:
%       sIn      - Input struct.
%       keepList - Cell array of field names to retain in sIn.
%
%   Output:
%       sOut     - Struct containing only the specified fields.
%
%   Example:
%       s.a = 1; s.b = 2; s.c = 3;
%       s2 = keepFields(s, {'a','c'});
%       % s2 = struct('a',1,'c',3)

% Validate input
if ~isstruct(sIn)
    error('First input must be a struct.');
end
if ~iscellstr(keepList)
    error('Second input must be a cell array of character vectors.');
end

% Get all fields
allFields = fieldnames(sIn);

% Identify fields to remove
removeFields = setdiff(allFields, keepList);

% Remove unwanted fields
sOut = rmfield(sIn, removeFields);
end
