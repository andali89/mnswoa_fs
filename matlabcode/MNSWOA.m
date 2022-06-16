% Copyright (c) 2022, An-Da Li
% All rights reserved. Please read the "license" for license terms.
% The Implementation of NSGAII-DMS algorithm.
% Author: An-Da Li 
% Email: andali1989@163.com

% this is the main procudure of the MNSWOA algorihtm, which is established
% based on single objective WOA proposed by S. Mirjalili.


%_________________________________________________________________________%
%  Whale Optimization Algorithm (WOA) source codes demo 1.0               %
%                                                                         %
%  Developed in MATLAB R2011b(7.13)                                       %
%                                                                         %
%  Author and programmer: Seyedali Mirjalili                              %
%                                                                         %
%         e-Mail: ali.mirjalili@gmail.com                                 %
%                 seyedali.mirjalili@griffithuni.edu.au                   %
%                                                                         %
%       Homepage: http://www.alimirjalili.com                             %
%                                                                         %
%   Main paper: S. Mirjalili, A. Lewis                                    %
%               The Whale Optimization Algorithm,                         %
%               Advances in Engineering Software , in press, 2016         %
%               DOI: http://dx.doi.org/10.1016/j.advengsoft.2016.01.008   %
%                                                                         %
%_________________________________________________________________________%

% You can simply define your cost in a seperate file and load its handle to fobj 
% The initial parameters that you need are:
%__________________________________________
% fobj = @YourCostFunction
% dim = number of your variables
% Max_iteration = maximum number of generations
% SearchAgents_no = number of search agents
% lb=[lb1,lb2,...,lbn] where lbn is the lower bound of variable n
% ub=[ub1,ub2,...,ubn] where ubn is the upper bound of variable n
% If all the variables have equal lower bound you can just
% define lb and ub as two single number numbers

% To run ALO: [Best_score,Best_pos,cg_curve]=ALO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj)

% The MNSWOA algorithm
function [Leader_pos_binary,All_Leader_score, iter_result]=MNSWOA(classifier,trainset,setup)
SearchAgents_no = setup.SearchAgents_no;
Max_iter = setup.Max_iter;
lb = setup.lb;
ub = setup.ub;
dim = setup.dim;
infold = setup.infold;
mutationtype = setup.mutationtype;
% initialize position vector and score for the leader
%Leader_pos=zeros(1,dim);
%Leader_score=inf; %change this to -inf for maximization problems


%Initialize the positions of search agents
Positions=initialization(SearchAgents_no,dim,ub,lb);
leaderSelCount = zeros(SearchAgents_no, 1);
%Convergence_curve=zeros(1,Max_iter);

%%
t=0;% Loop counter
cache = [];
%% Evaluate the initial solutions
 for i=1:SearchAgents_no
            % Return back the search agents that go beyond the boundaries of the search space
    Flag4ub=Positions(i,:)>ub;
    Flag4lb=Positions(i,:)<lb;
    Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
 end    
% Calculate objective function for each search agent
pos=(Positions>0);
All_fitness=runclassifier(classifier,trainset,pos,infold);
cache.pos = pos;
cache.fitness = All_fitness;
objnum = size(All_fitness, 2);
[Sorted_Positions,Sorted_fitness, Strength, leaderSelCount] =...
    Diversity_Sorting(Positions,All_fitness, leaderSelCount);
    % get the leader position and score
 leader_Index = find(Strength == 1);
 All_Leader_pos = Sorted_Positions(leader_Index, :);
 All_Leader_score = Sorted_fitness(leader_Index, :);
 All_Leader_SelCount = leaderSelCount(leader_Index, :);

 
 %% iter re
 searchNum = SearchAgents_no;
 iter_result = [[t, searchNum],{All_Leader_score}];
%%
% Main loop

globalpoint = 0.5;

while t < Max_iter
%     if globalpoint >= globalpointMin
%         globalpoint = globalpoint - step;
%         disp(['iter', num2str(t) ,', the global point is ',num2str(globalpoint)]);
%     end
    Positions_pa = Positions;
    leaderSelCount_pa = leaderSelCount;
    All_fitness_pa = All_fitness;
    
    
    a=2-t*((2)/Max_iter); % a decreases linearly from 2 to 0 in Eq. (2.3)    
    % a2 linearly dicreases from -1 to -2 to calculate t in Eq. (3.12)
    a2=-1+t*((-1)/Max_iter);    
    % Update the Position of search agents 
    for i=1:SearchAgents_no
        % find a leader from leader set for the current whale
        [Leader_pos, All_Leader_SelCount,leaderSelIndex] = ...
            selectLeader(All_Leader_pos, leader_Index, All_Leader_SelCount);
        
        leaderSelCount_pa(leaderSelIndex) = leaderSelCount_pa(leaderSelIndex) + 1; 
        %Leader_pos = All_Leader_pos(randi(size(All_Leader_pos,1)), :);
        
        r1=rand(); % r1 is a random number in [0,1]
        r2=rand(); % r2 is a random number in [0,1]
        
        A=2*a*r1-a;  % Eq. (2.3) in the paper
        C=2*r2;      % Eq. (2.4) in the paper
        
        
        b=1;               %  parameters in Eq. (2.5)
        l=(a2-1)*rand+1;   %  parameters in Eq. (2.5)
        
        p = rand();        % p in Eq. (2.6)
        
        for j=1:size(Positions,2)
            
            if p<globalpoint   
                if abs(A)>=1
                    rand_leader_index = floor(SearchAgents_no*rand()+1);
                    X_rand = Positions(rand_leader_index, :);
                    D_X_rand=abs(C*X_rand(j)-Positions(i,j)); % Eq. (2.7)
                    Positions(i,j)=X_rand(j)-A*D_X_rand;      % Eq. (2.8)
                    
                elseif abs(A)<1
                    D_Leader=abs(C*Leader_pos(j)-Positions(i,j)); % Eq. (2.1)
                    Positions(i,j)=Leader_pos(j)-A*D_Leader;      % Eq. (2.2)
                end
                
            elseif p>= globalpoint
              
                distance2Leader=abs(Leader_pos(j)-Positions(i,j));
                % Eq. (2.5)
                Positions(i,j)=distance2Leader*exp(b.*l).*cos(l.*2*pi)+Leader_pos(j);
                
            end
            
        end
    end
    %get the fitness function values
    Positions = mutate(Positions, 0.5, mutationtype );
    pos=(Positions>0);
    All_fitness = zeros(SearchAgents_no, objnum); 
    leaderSelCount = zeros(SearchAgents_no, 1);
    
    for i = 1: SearchAgents_no
       matched = match(pos(i, :), cache);
       if matched~= -1
           All_fitness(i, :) = matched;
       else
           All_fitness(i, :) = runclassifier(classifier,trainset,pos(i, :),infold);
           cache.pos = [cache.pos; pos(i, :)];
           cache.fitness = [cache.fitness; All_fitness(i, :)];
       end
    end
    
    
    % Sorting the solutions and obtaining the Strength values
    [Sorted_Positions,Sorted_fitness, Strength, leaderSelCount] = Diversity_Sorting([Positions; Positions_pa],...
        [All_fitness; All_fitness_pa], [leaderSelCount; leaderSelCount_pa]);
    % get the leader position and score
    leader_Index = find(Strength == 1);
    All_Leader_pos = Sorted_Positions(leader_Index, :);
    All_Leader_score = Sorted_fitness(leader_Index, :);
    All_Leader_SelCount = leaderSelCount(leader_Index, :);
    % get the position  and fitness value for the next generation
    
    newIndex = getPosIndex(Strength,Sorted_fitness, SearchAgents_no);
    Positions = Sorted_Positions(newIndex(1: SearchAgents_no), :);
    All_fitness = Sorted_fitness(newIndex(1: SearchAgents_no), :);
    leaderSelCount = leaderSelCount(newIndex(1 : SearchAgents_no), :);
    t=t+1;
    
    fprintf('i= %d    Leader set size= %f\r\n',[t,size(All_Leader_score, 1)]);
    %Convergence_curve(t)=Leader_score;
%     
%     if t>2
%         line([t-1 t], [Convergence_curve(t-1) Convergence_curve(t)],'Color','b')
%         xlabel('Iteration');
%         ylabel('Best score obtained so far');        
%         drawnow
%     end
 
    
%     set(handles.itertext,'String', ['The current iteration is ', num2str(t)])
%     set(handles.optimumtext,'String', ['The current optimal value is ', num2str(Leader_score)])
%     if value==1
%         hold on
%         scatter(t*ones(1,SearchAgents_no),All_fitness,'.','k')
%     end
%    
      searchNum = searchNum + SearchAgents_no;
      iter_this = [[t, searchNum],{All_Leader_score}];
      if t ==0
          iter_result = iter_this;
      else
          iter_result = [iter_result;iter_this];
      end
    
    
end
Leader_pos_binary = (All_Leader_pos >0);



