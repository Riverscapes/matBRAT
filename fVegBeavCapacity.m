%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for Calculating Beaver Dam Capacity from Vegetation
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
% This function outuputs a dam density in dams/km based soley on
% vegetation within a 30 m buffer and vegetation within a 100 m buffer
% The vegetation scores are from 0 to 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oVC] = fVegBeavCapacity(iVegVT30, iVegVT100)

%% Make sure inputs in range
% if iVegVT30 < 0
%     error('Your vegetation input within riparian (30 m buffer) is negative! Values must be between 0 & 4.')
% elseif iVegVT30 > 4
%     error('Your vegetation input within riparian (30 m buffer) is > 4!Values must be between 0 & 4.')
% elseif iVegVT100 < 0 
%     error('Your vegetation input within riparian (100 m buffer) is negative!Values must be between 0 & 4.')
% elseif iVegVT100 > 4
%     error('Your vegetation input within riparian (100 m buffer) is > 4!Values must be between 0 & 4.')
% end
%% LOAD FIS & INPUTS
%  [FISfilename, FISpathname]=uigetfile('*.fis','Load the Vegetation *.FIS you wish to use.');
%  FISVegtype = [FISpathname FISfilename];
% % Call up the *.fis file produced from the fuzzy logic toolbox
%     % This will only run if the Fuzzy Logic Toolbox is loaded
%     % The fuzzy rule system can be modified using the toolbox
% userVegFIS = readfis(FISVegtype); % Creates FIS Structure Object

userVegFIS = readfis('BeaverDamCapacity_VEG2input.fis');

%% Do Calculation
 oVC = evalfis([iVegVT30 iVegVT100], userVegFIS);
return