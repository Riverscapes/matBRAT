%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for Potential Conflict
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Produced by Joseph Wheaton 
%               Orignally Produced May 2014
%  Contributors:
%       Wally MacFarlane, Joe Wheaton, Martha Jensen, Konrad Hafen
%                                                                
%                        Version 1.0.1                           
%                  Updated on 5/22/2014 by JMW                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% This function outputs a probablity of conflict potential
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oPC_Prob] = fConflictPotential(iPC_UDotX,iPC_RoadX,iPCRoadAdj,iPC_RR, iPC_Canal,iPC_LU,iPC_Own)

%% Check for bad inputs
if iPC_UDotX < 0
    iPC_UDotX = 10000;
end
if iPC_RoadX <= 0
    iPC_RoadX = 10000;
end
if iPCRoadAdj < 0
    iPCRoadAdj = 10000;
end
if iPC_RR < 0
    iPC_RR = 10000;
end
if iPC_Canal < 0
    iPC_Canal = 10000;
end
if iPC_LU < 0
    iPC_LU = 10000;
end
if iPC_Own < 0
    iPC_Own = 10000;
end


%% Use Transform Functions to estimate probabilities
% UDOT
CrossingLow = 50;
CrossingHigh = 1000;
AdjLow = 10;
AdjHigh = 750;

if iPC_UDotX >= 0 && iPC_UDotX <= CrossingLow
    UDotX_Prob = 0.9; % Assign high probability when crossing in reach
elseif iPC_UDotX > CrossingLow && iPC_UDotX <= CrossingHigh
    UDotX_Prob = -0.0011867*iPC_UDotX + 0.90118667; % Use formula to calculate probability
elseif iPC_UDotX > CrossingHigh
    UDotX_Prob = 0.01; % Assign low probability when UDOT culvert is far from reach
else
    UDotX_Prob = 0.01; % Assign very low probability otherwise
end
% Road Crossings
if iPC_RoadX >= 0 && iPC_RoadX <= CrossingLow
    RoadX_Prob = 0.9; % Assign high probability when crossing in reach
elseif iPC_RoadX > CrossingLow && iPC_RoadX <= CrossingHigh
    RoadX_Prob = -0.0011867*iPC_RoadX + 0.90118667; % Use formula to calculate probability
elseif iPC_RoadX > CrossingHigh
    RoadX_Prob = 0.01; % Assign low probability when crossing is far from reach
else
    RoadX_Prob = 0.01; % Assign very low probability otherwise
end

% Road Adjacent
if iPCRoadAdj >= 0 && iPCRoadAdj <= AdjLow
    RoadAdj_Prob = 0.9; % Assign high probability when road is close to reach
elseif iPCRoadAdj > AdjLow && iPCRoadAdj <= AdjHigh
    RoadAdj_Prob = -0.0100933333333*iPCRoadAdj + 1.00933333333; % Use formula to calculate probability
elseif iPCRoadAdj > AdjHigh
    RoadAdj_Prob = 0.01; % Assign low probability when road is far from reach
else
    RoadAdj_Prob = 0.01; % Assign very low probability otherwise
end

% Canal
if iPC_Canal >= 0 && iPC_Canal <= AdjLow
    Canal_Prob = 0.9; % Assign high probability when crossing in reach
elseif iPC_Canal > AdjLow && iPC_Canal <= AdjHigh
    Canal_Prob = -0.00137*iPC_Canal + 1.0369; % Assign high probability when crossing in reach
elseif iPC_Canal > AdjHigh
    Canal_Prob = 0.01; % Assign high probability when crossing in reach
else
    Canal_Prob = 0.01; % Assign very low probability otherwise
end

% Rail Road
if iPC_RR >= 0 && iPC_RR <= AdjLow
    RR_Prob = 0.9; % Assign high probability when crossing in reach
elseif iPC_RR > AdjLow && iPC_RR <= AdjHigh
    RR_Prob = -0.00137*iPC_RR + 1.0369; % Assign high probability when crossing in reach
elseif iPC_RR > AdjHigh
    RR_Prob = 0.01; % Assign high probability when crossing in reach
else
    RR_Prob = 0.01; % Assign very low probability otherwise
end

%% Combine probability
ProbArray = [UDotX_Prob RoadX_Prob RoadAdj_Prob RR_Prob Canal_Prob];

oPC_Prob = max(ProbArray); % Just let worst probabilty drive model
    
return

