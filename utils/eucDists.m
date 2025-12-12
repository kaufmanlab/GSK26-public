function dists = eucDists(X)
% dists = eucDists(X)
% 
% Pairwise Euclidean distances between columns, with no preprocessing.

% The below works because linear algebra. I stole it from tsne.m (and
% swapped the dimensions), but also checked the math.
% It is much, much faster than the more obvious way to do this. I think
% just because of vectorization.
sum_X = sum(X .^ 2, 1);
% Modified to get rid of bsxfun
% dists = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (X' * X)));
dists = sum_X + (sum_X' - 2 * (X' * X));

% Zero the diagonal (otherwise we sometimes get values just <0 due to
% floating point tolerance)
n = size(dists, 1);
inds = sub2ind(size(dists), 1:n, 1:n);
dists(inds) = 0;

dists = sqrt(dists);

% Ensure perfect symmetry
dists = (dists + dists') ./ 2;
