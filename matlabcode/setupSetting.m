% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com


setup.SearchAgents_no = 100;
setup.Max_iter = 100;
setup.lb = -1;
setup.ub = 1;
setup.dim = numAttri;
setup.infold = 5;
setup.mutationtype = 1; % 1 one point, -1 change position , 0 hybrid 