%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function for Calling up Regional Curves
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
% This function just houses the regional curves and when called returns 
% QP80, Q2 and Q25 (in cfs). The inputs are the RegionID (must be
% specified exactly), and the upstream area (in square miles)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [QP80 Q2 Q25] = fRegionalCurves(regionID,UpstreamArea)
QP80 = 0;
Q2 = 0;
Q25 = 0;

try
%%    Calculate QP80 (baseflow), Q2 (Peakflow) & Q25

    if(regionID == '1') % Utah Region 1
         QP80 = (0.0000000000040244*(UpstreamArea)^(0.2355))*(7079.69^(2.5456))*((17.6+0.001)^(1.5444));
         Q2= 1.52*(UpstreamArea)^0.677*(1.39^(7.07969));   
         Q25= (19.7*(UpstreamArea)^(0.547))*((1.21)^(7.07969));
    elseif(regionID == '2') % Utah Region 2
         QP80 = (6.726*10^(-37))*((UpstreamArea)^0.6244)*(5707.02^9.3200);
         Q2= 0.585*(UpstreamArea)^0.847*(1.07^50.0);
         Q25= (4*(UpstreamArea)^(0.661))*1.06^(50.0);
    elseif(regionID == '3')  % Utah Region 3
         QP80 = 0.012712*((UpstreamArea)^0.8789)*(10^(0.0539*11.71)); 
         Q2= 14.5*(UpstreamArea)^0.328;
         Q25= (148*(UpstreamArea)^0.298);
    elseif(regionID == '4')  % Utah Region 4
         QP80 = (8.4859*10^(-4))*((UpstreamArea)^(0.9355))*(10^(0.0927*16.29));
         Q2= 0.083*((UpstreamArea)^(0.822))*(2.72^((0.656*(7666.99/1000))-(0.039*22.19)));
         Q25= (1.64*(UpstreamArea)^(0.804))*(2.72^((0.414*(7666.99/1000))-(0.030*19.7)));
    elseif(regionID == '5')  % Utah Region 5
         QP80 = 0.012712*((UpstreamArea)^(0.8789))*(10^(0.0539*19.42));
         Q2= 4.32*((UpstreamArea)^(0.623))*(4^(0.503));
         Q25= (28.8*(UpstreamArea)^(0.538))*((4)^(0.352));
    elseif(regionID == '6')  % Utah Region 6
         QP80 = 0.27139*((UpstreamArea)^(0.5124));
         Q2= 4150*((UpstreamArea)^(0.553))*((6182.81/1000)^(-2.45));
         Q25= (49500*(UpstreamArea)^(0.411))*((6182.81/1000)^(-2.51));
    elseif(regionID == '7')  % Utah Region 7
        QP80 = 0.18205*((UpstreamArea)^(0.7938));
        Q2= 18.4*((UpstreamArea)^(0.630));
        Q25= 278*((UpstreamArea)^(0.429));
    elseif(regionID == '8')  % Idah Region 
        % For Idaho streampower region intersecting Utah (Wood, 2009)
        QP80 = 0.0000115*((UpstreamArea)^(0.837))*((5716.8/1000)^(4.658));
        Q2= 10.2*((UpstreamArea)^(0.611));
        Q25= 29.9*((UpstreamArea)^(0.644));
    else
        error('Unspported region number specified.');  
    end
    return
catch err
   error('Unspported region number specified.');  
end

