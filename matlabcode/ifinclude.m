% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

function f_set=ifinclude(A,B) 
    L_A=size(A,1);
    f_set=[];
    for i=1:L_A
        if isequal(A(i,:),B)
           f_set=[f_set;i]; 
        end
    end
    disp('function ifinclude used');

end