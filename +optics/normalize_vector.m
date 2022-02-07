function vec = normalize_vector(vec)
% INPUT
%   vec:        n*d
% OUTPUT
%   vec:        n*d

num = size(vec, 1);
d = size(vec, 2);

sq_vec = vec.^2;
sq_vec_norm = sum(sq_vec, 2);
rcp_vec_norm = 1 ./ sqrt(sq_vec_norm);

for i = 1:num
    vec(i, :) = vec(i, :) * rcp_vec_norm(i);
end
end
