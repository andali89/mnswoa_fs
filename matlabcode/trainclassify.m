% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% this is the main procudure of the MNSWOA algorihtm, which is established
% based on single objective WOA proposed by S. Mirjalili.

function [predictedClass,rate,conf_matrix]=trainclassify(bayes,trainset,testset)

     bayes.buildClassifier(trainset);
             %test naive bayes
     if nargout==2
        [predictedClass,rate]=classify(bayes,testset);
     elseif nargout==3
        [predictedClass,rate,conf_matrix]=classify(bayes,testset); 
        
     end
end