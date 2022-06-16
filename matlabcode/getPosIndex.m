% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function newIndex = getPosIndex(Strength, fitness, SearchAgents_no)
%GETPOSINDEX Summary of this function goes here
%   Detailed explanation goes here
    [M,~] = size(Strength);
    newIndex = (1:M)';
    frontNum = Strength(SearchAgents_no, 1);
    index = find(Strength(:, 1) == frontNum);
    
    if(index(end) ~= SearchAgents_no)
        indexStrength = [fitness(index, 2),index];
        sortedIS = sortrows(indexStrength, 1);
        newIndex(index) = sortedIS(:, 2);
    end
    
end

