% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% get the objective fucntion values by the inner k-fold CV
function [obj]=runclassifier(classifier,Datain,population,infold)
    
    Data=weka.core.Instances(Datain);
    popsize=size(population,1);
    numInstan=zeros(infold,1);
    %fullFeature = Data.numAttributes()-1;%%
    sma=Data.numClasses();
    sensi_speciy=zeros(infold,sma);
    Avg_sensi=zeros(popsize,sma); %注意
    FeatureNum=zeros(popsize,1);
    %maxQC = zeros(popsize,1); %%
    %meanQC = zeros(popsize,1);
    cAcc=zeros(infold,1);
    Avg_Acc=zeros(popsize,1);
    Data.stratify(infold);
    %InterQC = zeros(popsize, 1);%% Inter_QC 为特征数和最末特征序数组成的综合适应度函数
    for p=1:popsize   
        if sum(population(p,:))~=0
            DataS=FeatureSelect(Data,population(p,:));
            for k=1:infold
                TrainDataS=DataS.trainCV(infold,k-1);
                TestDataS=DataS.testCV(infold,k-1);
                numInstan(k)=TestDataS.numInstances();
                [~,cAcc(k),matrix]=trainclassify(classifier,TrainDataS,TestDataS);             
                           
                for i=1:sma
                   sensi_speciy(k,i)= matrix(i,i)/sum(matrix(i,:));
                end
                
            end
            Avg_sensi(p,:)=sum(sensi_speciy.*repmat((numInstan),1,2))/sum(numInstan);
            Avg_Acc(p)=sum(cAcc.*numInstan)/sum(numInstan);
            FeatureNum(p)=sum(population(p,:));
            %maxQC(p) = find(population(p,:) == 1, 1, 'last' );
            %meanQC(p) = mean(find(population(p,:) == 1));
            %Inter_QC(p) = 1 - (((1 - (FeatureNum(p) / fullFeature)) * (1 - (maxQC(p) /fullFeature)))^0.5);
            %InterQC(p) = 0.9*FeatureNum(p) + 0.1*meanQC(p);
        else
            Avg_Acc(p)=0;
            Avg_sensi(p,:)=zeros(1,sma);
            %FeatureNum(p)=sum(population(p,:));
            FeatureNum(p) = 1000;
            %meanQC(p) = 1000;
            %maxQC(p) = 1000;
            %InterQC(p) = 1000;
        end
    end
    %obj=[1-Avg_Acc,FeatureNum];
    %Avg_sensi
  % obj=[1-Avg_sensi,FeatureNum];
   
   %type II
  % obj=[1-Avg_sensi(:,1),1-Avg_Acc,FeatureNum];
  
  %gmean
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),FeatureNum, meanQC];
  obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),FeatureNum];
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),InterQC];
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),meanQC];
  
end