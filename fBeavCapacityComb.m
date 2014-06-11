%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for Calculating Beaver Dam Capacity
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
% This function outputs a dam density in dams/km based on
% vegetation within a 30 m buffer and vegetation within a 100 m buffer
% The vegetation scores are from 0 to 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oCC] = fBeavCapacityComb(oVC,iHyd_SP2,iHyd_SPLow,iGeo_Slope)

%% Make sure inputs in range
if oVC < 0 || iHyd_SP2 < 0 || iHyd_SPLow < 0 || iGeo_Slope < 0
    error('OUT OF RANGE: One of your inputs is negative! Values must be greater then zero.')
elseif oVC > 50
    error('OUT OF RANGE: Your input dam density based on vegetation cannot be greater then 50 dams/km')
elseif iHyd_SP2 > 1000000 
    error('OUT OF RANGE: Are you sure your input 2 year recurance interval stream power is over 1,000,000 Watts?')
elseif iHyd_SPLow > 100000
    error('OUT OF RANGE: Are you sure your input baseflow stream power is over 100,000 Watts?')
elseif iGeo_Slope > 1
    error('OUT OF RANGE: Your segment slopes cannot be > 100 % slope!')
end
%% LOAD FIS & INPUTS
%  [FIS2filename, FIS2pathname]=uigetfile('*.fis','Load the Combined BRAT *.FIS you wish to use.');
%  FISComb = [FIS2pathname FIS2filename];
%  userCombFIS = readfis(FISComb); % Creates FIS Structure Object
  
 userCombFIS = readfis('BeaverDamCapacity_COMB4input.fis');

%% Do Calculation
 oCC = evalfis([oVC iHyd_SP2 iHyd_SPLow iGeo_Slope], userCombFIS); 


return