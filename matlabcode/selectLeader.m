% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com



function [leader, All_Count, leaderIndex] = selectLeader(Allleaders, All_Index, All_Count)
   % All leaders stores all the candidate leaders
   % indexSel denotes the index in the population
   % leaderCount denotes the count of this leader slected as the leader
   % leader returns the selected leader
   % leaderIndex denotes the selected leader position in population
   % the leaders with the minimum count are selected
   indices = find(All_Count == min(All_Count));
   i = randi(length(indices));
   leaderIndex = All_Index(indices(i), :);
   leader = Allleaders(indices(i), :);
   All_Count(indices(i)) = All_Count(indices(i))+ 1;
end