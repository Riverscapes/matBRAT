%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Function for Beaver Restoration/Conservation
%                   Preliminary Categorization
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
% This function outuputs a preliminary estimate of potential beaver
% conservation and/restoration zones.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fCR] = fConservationRestoration(oCC_EX, oCC_PT, oVC_EX, oVC_PT, oPC_Prob)

%% Check for bad inputs
if oCC_EX < 0 || oCC_PT < 0 || oVC_EX < 0 || oVC_PT < 0 || oPC_Prob < 0
    error('OUT OF RANGE: One of your inputs has a negtive value!');
elseif  oCC_EX > 50 || oCC_PT > 50 || oVC_EX > 50 || oVC_PT > 50
    error('OUT OF RANGE: One of your capacity inputs exceeds 50 dams/km (this is not allowed)');
elseif oPC_Prob > 1
    error('OUT OF RANGE: You cannot have a conflict probability > 1!');
end


%% Start the Logic Train
LowConflict = 0.25; % The low conflict probablity threshold
HighConflict = 0.75; % The high conflict probablity threshold

if oCC_EX == 0 % Deal with the existing None capacity areas first
    % Either going to be Unsuitable (Anthropogenic or Natural) or Long-Term
    % Possiblity. What differntiates it is basically potential and
    % probability of conflict.
    if oCC_PT > 5 % i.e. Potential is > 5 dams/km
        if oPC_Prob < LowConflict 
            fCR = 'Long-Term Possibility Restoration Zone';
        else % Must be limited by current landuse?
            fCR = 'Unsuitable: Anthropogenically Limited';
        end
       
    else % Now figure out whether anthropogenic or naturally limiting
        if oVC_PT > 1 % If the vegetation potential was good enough to support some activty
            fCR = 'Unsuitable: Anthropogenically Limited';
        else
            fCR = 'Unsuitable: Naturally Limited';
        end
    end
elseif oCC_EX > 0 && oCC_EX <=1 % The existing Rare Capacity Areas
    if oCC_PT > 5 && oCC_PT <= 15 % Is there better potential?
        if oPC_Prob <= LowConflict % Low conflict potential
            fCR = 'Long-Term Possibility Restoration Zone';
        elseif oPC_Prob > LowConflict && oPC_Prob <= HighConflict % Intermediate Potential... Requires input?
            fCR = 'Living with Beaver (Low Source)';
        elseif oPC_Prob > HighConflict 
            fCR = 'Unsuitable: Anthropogenically Limited';
        end
    elseif oCC_PT > 15 % Or really great potential
         if oPC_Prob <= LowConflict 
            fCR = 'Quick Return Restoration Zone';
        elseif oPC_Prob > LowConflict && oPC_Prob <= HighConflict % Intermediate Potential... Requires input?
            fCR = 'Living with Beaver (Low Source)';
        elseif oPC_Prob > HighConflict 
            fCR = 'Unsuitable: Anthropogenically Limited';
        end
    else % Just not great potential
        fCR = 'Unsuitable: Naturally Limited';
        if oVC_PT > 1 % If the vegetation potential was good enough to support some activty
            fCR = 'Unsuitable: Anthropogenically Limited';
        else
            fCR = 'Unsuitable: Naturally Limited';            
        end    
    end
elseif oCC_EX > 1 && oCC_EX <=5 % The existing Occasional Capacity Areas
     if oCC_PT > 5  % Is there better potential?
        if oPC_Prob <= LowConflict % 25% Low conflict potential
            fCR = 'Long-Term Possibility Restoration Zone';
        elseif oPC_Prob > LowConflict && oPC_Prob <= HighConflict % Intermediate Potential... Requires input?
            fCR = 'Living with Beaver (Low Source)';
        elseif oPC_Prob > HighConflict % Interm
            fCR = 'Unsuitable: Anthropogenically Limited';
        end
    elseif oCC_PT <= 5 % Or not so great potential
         if oPC_Prob <= HighConflict % 25% Low conflict potential
                fCR = 'Living with Beaver (Low Source)';
         elseif oPC_Prob >  HighConflict 
            fCR = 'Unsuitable: Naturally Limited';
         end
     end 
elseif oCC_EX > 5 && oCC_EX <=15 % The existing Frequent Capacity Areas
     if oCC_PT > 15  % Is there better potential?
        if oPC_Prob <= LowConflict % 25% Low conflict potential
            fCR = 'Quick Return Restoration Zone';
        elseif oPC_Prob > LowConflict && oPC_Prob <= HighConflict % Intermediate Potential... Requires input?
            fCR = 'Living with Beaver (High Source)';
        elseif oPC_Prob > HighConflict % Interm
            fCR = 'Unsuitable: Anthropogenically Limited';
        end
    elseif oCC_PT <= 15 % Or not so great potential improvment
         if oPC_Prob <= HighConflict % 25% Low conflict potential
                fCR = 'Low Hanging Fruit - Potential Restoration/Conservation Zone';
        elseif oPC_Prob >  HighConflict 
            fCR = 'Living with Beaver (High Source)';
        end
    end 
elseif oCC_EX > 15 && oCC_EX <=50 % The existing Pervasive Capacity Areas
        if oPC_Prob <= HighConflict % 25% Low conflict potential
            fCR = 'Low Hanging Fruit - Potential Restoration/Conservation Zone';
        elseif oPC_Prob > HighConflict % Interm
            fCR = 'Living with Beaver (High Source)';
        end  
else
    fCR = 'NOT PREDICTED - Requires Manual Attention';
end

return

