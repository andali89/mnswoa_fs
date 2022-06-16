% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

% This is an implementation of the multi-objective optimization algorithm called 
% modified nondominated-sorting-based whale optimization algorithm (MNSWOA)
% for key quality characteristic identification in production processes (feature selection).
% The optimization method adapt the  whale optimization algorithm (WOA) into 
% multi-objective scenario with several new components, a modified non-dominated sorting
% approach, a uniform reference solution selection strategy, and mutation operations. 
% For a detailed description of the method please refer to 

% Li, A.-D.*, & He, Z. (2020). Multiobjective feature selection for key quality
% characteristic identification in production processes using a nondominated-sorting-based 
% whale optimization algorithm. Computers & Industrial Engineering, 149, 106852. 
% doi:10.1016/j.cie.2020.106852



% Note: In the illustration example, a set of non-dominated solutios is returned by 
% MNSWOA. Users may use the perfectpoit function proposed in this package to furter select
% a single ideal point (solution).

clc;
%clear all;
close;
%% Add weka path
addwekapath;
%% run setting
seed=46;        
infold=5;
segnum=10;
%% classifier
classifier=weka.classifiers.bayes.NaiveBayes();
classifier.setUseKernelEstimator(0); % 1 or 0
%% read and normalize data
datapath=['../data/wdbc.arff'];
data=readArffData(datapath);
data=dataNorm(data); 
fprintf('attribute num is %d\nnum of instances is %d\n',data.numAttributes()-1,data.numInstances());
numAttri=data.numAttributes()-1;
data.randomize(java.util.Random(seed));
data.stratify(segnum);
%% parameters for MNSWOA
setupSetting;
%%
Start=tic;
Startcpu=cputime;
randseed = 1;


segfold = 0;
%for segfold=8:8
RandStream.setGlobalStream(RandStream('mt19937ar','seed',randseed));
Startin=tic;
Startincpu=cputime;
disp(['Running fold ',num2str(segfold)]);


trainset=data.trainCV(segnum,segfold);

testset=data.testCV(segnum,segfold);

                                    
[Solution,Trainfunc, iter_result]= MNSWOA(classifier,trainset,setup);

%% get the prediction accuracy for each solution in the final solution set

numsolution=size(Solution,1);
Conf_matrix=cell(numsolution,1);
pAcc=zeros(numsolution,1);
Sensitivity=zeros(numsolution,1);
Specificity=zeros(numsolution,1);
f1=zeros(numsolution,1);
for i=1:numsolution   
    trainsetr=FeatureSelect(trainset,Solution(i,:));
    testsetr=FeatureSelect(testset,Solution(i,:));
    [~,pAcc(i),Conf_matrix{i,1}]=trainclassify(classifier,trainsetr,testsetr);
     Sensitivity(i)=Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(1,:));
    Specificity(i)=Conf_matrix{i,1}(2,2)/sum(Conf_matrix{i,1}(2,:));
    preci = Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(:, 1));
    if (preci + Sensitivity(i)) ==0 || isnan(preci)
        f1(i) = 0;
    else
        f1(i) = ( 2* preci * Sensitivity(i))/ (preci + Sensitivity(i));      
    end
  
end

Performance=[Sensitivity,Specificity,pAcc, f1];




