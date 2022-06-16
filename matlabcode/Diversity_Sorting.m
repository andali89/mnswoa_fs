% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function [Sorted_Positions,Sorted_fitness, F_score,Sorted_leaderSel] = Diversity_Sorting(Positions,fitness, leaderSel)
    % leaderSel means the times of this leader is selected 
    [inst, dim] = size(Positions);
    % Convert to binary coded position
    Positions_bi = Positions > 0;
    %fitness
    %
    x = [Positions_bi, fitness];
    [f,index] = non_domination_sort_mod(x,dim, size(fitness, 2));
    
    Sorted_Positions = Positions(index, :);
    Sorted_fitness = f(:, dim + 1 : dim + 2);
    Sorted_leaderSel = leaderSel(index, :);
    F_score = f(:, dim + 3);
    
    
end
