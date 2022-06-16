% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% performs the mutation operation
function [ Positions ] = mutate( Positions, possi, type )
%MUTATE Summary of this function goes here
%   Detailed explanation goes here
% type =1 one point mutation
% type =-1 change the position
[m,n] = size(Positions);
rand_num =rand(m,1);
if type ==1
    
    for i = 1: m
       if rand_num(i) < possi
          index = randi(n);
          Positions(i, index) = -Positions(i, index);          
       end        
    end
    
elseif type ==-1
    for i = 1: m
       pos = Positions(i, :) > 0;
       sum_pos = sum(pos);
       if sum_pos>0 && sum_pos<n && rand_num(i) < possi
          %index = randi(n);
          %Position(i, index) = -Position(i, index);
          index1 = find(pos == 1);
          index2 = find(pos == 0);
          point1 = index1(randi(size(index1)));
          point2 = index2(randi(size(index2)));
                    
          temp = Positions(i, point1);
          Positions(i, point1) = Positions(i, point2);
          Positions(i, point2) = temp;        
            
          
       end        
    end
elseif type == 0
    for i = 1: m
       pos = Positions(i, :) > 0;
       sum_pos = sum(pos);
       if sum_pos>0 && sum_pos<n && rand_num(i) < possi/2
          %index = randi(n);
          %Position(i, index) = -Position(i, index);
          index1 = find(pos == 1);
          index2 = find(pos == 0);
          point1 = index1(randi(size(index1)));
          point2 = index2(randi(size(index2)));
                    
          temp = Positions(i, point1);
          Positions(i, point1) = Positions(i, point2);
          Positions(i, point2) = temp;        
       elseif   rand_num(i)<possi
          index = randi(n);
          Positions(i, index) = -Positions(i, index);
       end        
    end
    
    
end 
    
end

