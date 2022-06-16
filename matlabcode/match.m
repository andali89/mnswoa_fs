% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function matched = match(pos, cache)
    % find if binary position match one pos in cache
    % if matched assign the fitness function values to  matched
    % else let mathed = -1
    num = sum(pos);
    index = find(cache.fitness(:,end) == num);
    if isempty(index)
       matched = -1; 
       return;
    else
        matched = -1;
        for i = 1: size(index)
            if all(pos == cache.pos(index(i),:))
                matched = cache.fitness(index(i),:);
                return;
            end
        end
    end

end