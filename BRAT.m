%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   BRAT
%                   Beaver Restoration Assessment Tool
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Produced by Wally MacFarlane & Joseph Wheaton 
%               Orignally Produced October 2012
%  Contributors:
%       Wally MacFarlane, Joe Wheaton, Martha Jensen, Konrad Hafen
%                                                                
%                        Version 2.0.3                           
%                  Updated on 6/16/2014 by MLJ                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% This script uses a series of fuzzy inference systems to estimate the capacity
% of the landscape to support dam building activity by beaver. It also runs
% a conflcit potential (probablity) model (optionally)a
% conservation/restoration management model. 
%
% The model requires a *.csv file to run with following collumns:
% 1: iGeo_ElMin	 Minimum Segment Elevation - Extracted from 10m NED DEM [meters ABMS]
% 2: iGeo_ElMax  Maximum Segment Elevation - Extracted from 10m NED DEM  [meters ABMS]
% 3: iGeo_ElBeg	 Elevation at Segment Beginning- Extracted from 10m NED DEM  [meters ABMS]
% 4: iGeo_ElEnd	 Elevation at Segment End - Extracted from 10m NED DEM [meters ABMS]
% 5: iGeo_Length  Segment Length  - Derived from NHD 24K geometry; typically 250 m [meters]	
% 6: iGeo_Slope	  Segment Slope - Derived from elevations and segment length [percent slope - dimensionless]
% 7: iveg_VT100EX Existing Vegetation Type Beaver Suitability Adjacent to Stream - Classified from existing LANDFIRE as Beaver Vegetation Suitability using Zonal Stat Average within 100 m buffer [Suitability Value between 0 & 4]	
% 8: iveg_VT30EX  Existing Vegetation Type Beaver Suitability Near Stream(Riparian)
% 9: iveg_VT100PT	Potential Vegetation Type Beaver Suitability Adjacent to Stream
% 10: iveg_VT30PT  	Potential Vegetation Type Beaver Suitability Near Stream
% 11: iGeo_DA	 Upslope Drainage Area - SqMi - Derived from flow accumulation calculated on 10m NHD DEM [square miles]
% 12: iPC_UDotX	 Distance to UDoT Culvert - Euclidian distance to nearest UDoT Culvert [meters]
% 13: iPC_RoadX	  Distance to Road Crossing - Euclidian distance to nearest road crossing excluding UDot Culverts [meters]
% 14: IPC_RoadAdj	Distance to Road - Euclidian distance to nearest Road  [meters]
% 15: IPC_RR	 Distance to Railroad - Euclidian distance to nearest Railroad  [meters]
% 16: IPC_Canal  Distance to Canal - Euclidian distance to nearest Canal  [meters]

% The model outputs the above inputs as well as:
% iHyd_QLow - iHyd: Low Flow - CFS - Estimated by USGS Regional Curves [cfs]
% iHyd_Q2 - iHyd: 2 Year RI Flow - CFS - Estimated by USGS Regional Curves [cfs]
% iHyd_Q25 - iHyd: 25 Year RI Flow - CFS - Estimated by USGS Regional Curves [cfs]
% iHyd_SPLow - iHyd: Low Flow Stream Power - Calculated by Slope & Q estimate [Watts]
% iHyd_SP2 - iHyd: 2 Year RI Stream Power- Calculated by Slope & Q estimate [Watts]
% iHyd_SP25 - iHyd: 25 Year RI Stream Power - Calculated by Slope & Q estimate [Watts]
% oVC_EX - oVC: Modeled Vegetation Existing Beaver Dam Capacity Density - FIS modelled output of beaver dam density based only on existing vegetation [dams/km]
% oVC_PT - oVC: Modeled Vegetation Potential Beaver Dam Capacity Density - FIS modelled output of beaver dam density based only on potential vegetation [dams/km]
% oCC_EX - oDC: Modeled Combined Existing Beaver Dam Capacity Density - Final FIS modelled output of existing beaver dam density based on all combined inputs [dams/km]
% oCC_PT - oCC: Modeled Combined Potential Beaver Dam Capacity Density - Final FIS modelled output of potential beaver dam density based on all combined inputs [dams/km]
% mCC_EX_Ct - mCC: Existing Capacity Dam Count - Product of oCC_EX and Segment length [dams]
% mCC_PT_Ct - mCC: Potential Capacity Dam Count - Product of oCC_PT and Segment length [dams]
% mCC_EX-PT - mCC: Existing to Potential Capacity Ratio - Ratio of actual to potential dam densities [dimensionless ratio between 0 and 1]
% e_DamCt - Empirical: Actual Dam Count - These are the adjusted flow types by FHC [dams: optionally NA]
% e_DamDens - Empirical: Actual Dam Density - These are the adjusted flow types by FHC [dams/km; Optionally NA]
% e_DamPcC - Empirical: Actual Percent of Existing Capacity Ratio - A ratio comparing actual dam count to capacity estimate for segment  [ratio between 0 & 1; Optionally NA]
% oPC_Prob - oPC: Potential for Beaver Conflict Probability - These are the adjusted flow types by FHC [Probability]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   
%% LOAD INPUTS

[filename, pathname]=uigetfile('*.csv','Load the table with all BRAT inputs:');    
filename_BRAT_Input=[pathname filename];
% filename_BRAT_Input='C:\Docs\Programs\BRAT_FIS\BeaverCapacity_FIS\EscalanteBeaverFISInputs.txt';
outfilename = strcat(pathname,'BRAT_',filename);
reportfilename = strcat(outfilename,'_Metadata.txt');
clear filename pathname;
% % Get Header First then Close
% fid1=fopen(filename_BRAT_Input,'r');      % opens file to fid in read only mode
% Header =fscanf(fid1,'%s',1);         % Reads first row to save header
% fclose(fid1);                        % closes the file
% clear fid1;

% Import the file
newData1 = importdata(filename_BRAT_Input);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

disp('Done reading input file.');
    

%% Keep track of variables properly

iGeo_ElMin = data(:,1);
iGeo_ElMax = data(:,2);
iGeo_ElBeg = data(:,3);
iGeo_ElEnd = data(:,4);
iGeo_Length = data(:,5);
iGeo_Slope=data(:,6);

%% iGeo_Length (Remove zero iGeo_Lengths from the data)

% get rid of negative iGeo_Slopes
iGeo_Slope = abs(iGeo_Slope);
% get rid of outlighers by taking upstream neighbor iGeo_Slope
slpZeroAdd = find(iGeo_Slope == 0);
slpTooBigAdd = find(iGeo_Slope >= 1);
iGeo_Slope(slpZeroAdd) = 0.0001; % Override zero iGeo_Slopes with really low iGeo_Slope
iGeo_Slope(slpTooBigAdd) = 0.25; % Override big slopes to 25%

if (length(slpZeroAdd) > 0)
    fprintf('Fixed %u segment slopes that were equal to 0. \n',length(slpZeroAdd)); 
end
if (length(slpTooBigAdd) > 0)
    fprintf('Fixed %u segment slopes that were greater then 100 percent. \n',length(slpTooBigAdd)); 
end


%% AREA (iGeo_DA)
iGeo_DA = data(:,11);
% Convert from km2 to mi2
iGeo_DA = 0.3861021585424458*iGeo_DA;



%% VEG INPUTS
iveg_VT100EX = data(:,7);% Existing Vegeation in 100 m buffer
iveg_VT30EX = data(:,8); % Existing Vegetation in 30 m buffer
iveg_VT100PT = data(:,9); % FIX Potential Vegetation in 100 m buffer
iveg_VT30PT = data(:,10); % FIX Potential Vegetation in 30 m buffer


% Find the negative values
eCT_VT30EX = find(iveg_VT30EX < 0);
eCT_VT100EX = find(iveg_VT100EX < 0);
eCT_VT100PT = find(iveg_VT100PT < 0);
eCT_VT30PT = find(iveg_VT30PT < 0);
% Find the values above 4
eaCT_VT30EX = find(iveg_VT30EX > 4);
eaCT_VT100EX = find(iveg_VT100EX > 4);
eaCT_VT100PT = find(iveg_VT100PT > 4);
eaCT_VT30PT = find(iveg_VT30PT > 4);
% Fix the negative values
iveg_VT30EX(eCT_VT30EX) = 0;
iveg_VT100EX(eCT_VT100EX) = 0;
iveg_VT30PT(eCT_VT30PT) = 0;
iveg_VT100PT(eCT_VT100PT) = 0;
% Fix the values above 4
iveg_VT30EX(eaCT_VT30EX) = 3.9;
iveg_VT100EX(eaCT_VT30EX) = 3.9;
iveg_VT30PT(eaCT_VT30PT) = 3.9;
iveg_VT100PT(eaCT_VT100PT) = 3.9;

fprintf('Fixed %u VT30EX input problems. \n',(length(eCT_VT30EX)+length(eaCT_VT30EX)));  
fprintf('Fixed %u VT100EX input problems. \n',(length(eCT_VT100EX)+length(eaCT_VT100EX))); 
fprintf('Fixed %u VT30PT input problems. \n',(length(eCT_VT30PT)+length(eaCT_VT30PT)));
fprintf('Fixed %u VT100PT input problems. \n',(length(eCT_VT100PT)+length(eaCT_VT100PT)));

%% Stream Power Calcs
% All in CFS for now
% Calculate QBase
% Prealocate Size
iHyd_QLow = zeros(length(data),1);  % Hydrologic Input: Baseflow Q (in cfs)
iHyd_Q2 = zeros(length(data),1);    % Hydrologic Input: Two year return interval Q (in cfs)
iHyd_Q25 = zeros(length(data),1);   % Hydrologic Input: 25 year return interval Q (in cfs)
iHyd_SPLow = zeros(length(data),1); % Hydrologic Input: Baseflow Stream Power (in Watts)
iHyd_SP2 = zeros(length(data),1);   % Hydrologic Input: 2 year return interval Stream Power (in Watts)
iHyd_SP25 = zeros(length(data),1);  % Hydrologic Input: 25 year return interval Stream Power (in Watts)

regionButton = inputdlg('Enter exact region number for regional curves(see code 1-7 for utah 8 for Idaho)','Specify Hydrologic Region',1);

fprintf('Estimating discharge and stream power...\n')
h = waitbar(0,'Estimating Q & Stream Power from regional curves...');
for b=1:length(data); 
     [iHyd_QLow(b), iHyd_Q2(b), iHyd_Q25(b)]= fRegionalCurves((char(regionButton)),iGeo_DA(b));
% Calculate Unit Stream Power (Watts)
    %  CFS to Unit Stream Power (Watts)
    %  Flow (CFS) is converted to CMS by multiplying by 0.028316846592
    iHyd_SPLow(b) = (1000*9.80665)*iGeo_Slope(b)*(iHyd_QLow(b)*0.028316846592);  % iHyd_QLow - (Watts = (Density - 1000kg /cubic meter * Gravity 9.8m /squared second)* iGeo_Slope(m) * (cms)
    iHyd_SP2(b) = (1000*9.80665)*iGeo_Slope(b)*(iHyd_Q2(b)*0.028316846592);  % iHyd_Q2
    iHyd_SP25(b) = (1000*9.80665)*iGeo_Slope(b)*(iHyd_Q25(b)*0.028316846592);  % iHyd_Q25
    waitbar(b/(length(data)))
end
close(h);
clear b;

% Make sure Stream Power are not too big
ecT_iHyd_SPLow = find(iHyd_SPLow > 1000000);
ecT_iHyd_SP2 = find(iHyd_SP2 > 1000000);
ecT_iHyd_SP25 = find(iHyd_SP25 > 1000000);
% Fix as needed
iHyd_SPLow(ecT_iHyd_SPLow) = 100000;
iHyd_SP2(ecT_iHyd_SP2) = 100000;
iHyd_SP25(ecT_iHyd_SP25) = 100000;

% Make sure stream power is not too small
ecsT_iHyd_SPLow = find(iHyd_SPLow < 0);
ecsT_iHyd_SP2 = find(iHyd_SP2 < 0);
ecsT_iHyd_SP25 = find(iHyd_SP25 < 0);
% Fix as needed
iHyd_SPLow(ecsT_iHyd_SPLow) = 0.001;
iHyd_SP2(ecsT_iHyd_SP2) = 0.001;
iHyd_SP25(ecsT_iHyd_SP25) = 0.001;

%% POTENTIAL CONFLICT INPUTS
iPC_UDotX = data(:,12);
iPC_RoadX = data(:,13);
iPC_RoadAdj = data(:,14);
iPC_RR = data(:,15);
iPC_Canal = data(:,16);
iPC_LU = data(:,17);
iPC_Own = data(:,18);

%% Dam COUNT INPUT (OPTIONAL)
temp = size(data);
cols = temp(2);
if cols == 18
    boolDamCapOut = 0;
    fprintf('No Dam Capacity; %f column in dataset\n', (cols));
else
    boolDamCapOut = 1;
    fprintf('Dam Capacity; %f columns in dataset\n', (cols));
        
end

if boolDamCapOut
   e_DamCt = data(:,19);
end

%% BEAVER VEG CAPACITY FIS
fprintf('Estimating capacity estimates based on vegetation FIS...\n')
oVC_EX = zeros(length(data),1);
oVC_PT = zeros(length(data),1);

h = waitbar(0,'Running vegetation capacity FIS Model...');
for b=1:length(data);    
       oVC_EX(b)= fVegBeavCapacity(iveg_VT30EX(b), iveg_VT100EX(b)); % Existing Veg Capacity Model
       oVC_PT(b)= fVegBeavCapacity(iveg_VT30PT(b), iveg_VT100PT(b)); % Potential Veg Capacity Model
       waitbar(b/(length(data)))
end
close(h);
clear b;

fprintf('Done running vegetation FIS...\n')
%% BEAVER COMBINED FIS
fprintf('Estimating capacity estimates based on combined FIS...\n')
 oCC_EX = zeros(length(data),1);
 oCC_PT = zeros(length(data),1);


h = waitbar(0,'Running combined capacity FIS Model...');
for b=1:length(data);    
       oCC_EX(b)= fBeavCapacityComb(oVC_EX(b), iHyd_SP2(b), iHyd_SPLow(b), iGeo_Slope(b)); % Run for Existing
       oCC_PT(b)= fBeavCapacityComb(oVC_PT(b), iHyd_SP2(b), iHyd_SPLow(b), iGeo_Slope(b)); % Run for Potential
   % Manual Adjustments
   % Prevents output combined capacity from having higher value than Veg
   % Capacity
 
   if oCC_EX(b) > oVC_EX(b);
       oCC_EX(b) = oVC_EX(b);
   end
   if oCC_PT(b) > oVC_PT(b);
       oCC_PT(b) = oVC_PT(b);
   end

   if iGeo_DA(b) > 3860 && char(regionButton) == '6'; %Max Drainage Area (sq. mi.) for beaver dam presence in Region 6
       oCC_EX(b) = 0;
       oCC_PT(b) = 0;
   elseif iGeo_DA(b) > 1800; %Max Drainage Area (sq. mi.) for beaver dam presence in all other Regions
       oCC_EX(b) = 0;
       oCC_PT(b) = 0;
   end

   
   % Headwater Fix 
    if oCC_EX(b) >1 && oCC_EX(b)<5 %if existing capacity occasional 
        if iHyd_SP2(b)<250 %if stream power low
            oCC_EX(b) = oCC_EX(b)+10; %Bump occasional to frequent
        end
    end
    if oCC_PT(b) >1 && oCC_PT(b)<5 %if potential capacity occasional 
        if iHyd_SP2(b)<250 %if stream power low
            oCC_PT(b) = oCC_PT(b)+10; %Bump occasional to frequent
        end
    end
    waitbar(b/(length(data)))
 end
close(h);
clear b;      
 
fprintf('Done running combined Beaver Capacity FIS...\n')

%% POTENTIAL CONFLICT FIS
oPC_Prob = zeros(length(data),1);

% conflictButton = questdlg('Do you want to run the potential conflict model?','Potential Conflict Analysis','Yes','No','No');
conflictButton = 'Yes';
if strcmp(conflictButton,'Yes')
    % Add a status bar, while running model
    h = waitbar(0,'Running Potential Conflict Model...');
    for b=1:length(data);
        oPC_Prob(b) = fConflictPotential(iPC_UDotX(b),iPC_RoadX(b),iPC_RoadAdj(b),iPC_Canal(b),iPC_RR(b), iPC_LU(b), iPC_Own(b));
        waitbar(b/(length(data)))
    end
    close(h);
    clear b;
end

%% Potential Beaver Restoration and Conservation

% restButton = questdlg('Do you want to run the beaver restoration/conservation potential model?','BRAT Analysis','Yes','No','No');
restButton = 'Yes';
% initialize string array
dfltStr = 'Not Evaluated';
for i= 1:(length(data))
    oPBRC{i,1} = dfltStr;
end
clear i;

% Add a status bar, while running model
h = waitbar(0,'Running restoration/conservation model...');
for i= 1:(length(data))
    if strcmp(restButton,'Yes')
        oPBRC{i,1}= fConservationRestoration(oCC_EX(i), oCC_PT(i), oVC_EX(i), oVC_PT(i), oPC_Prob(i));
    end
    waitbar(i/(length(data)))
end
close(h)
clear i;

%% CALCULATE METRICS
mCC_EX_Ct = zeros(length(data),1);
mCC_PT_Ct = zeros(length(data),1);
mCC_EXtoPT = zeros(length(data),1);

if boolDamCapOut
    e_DamDens = zeros(length(data),1);
    e_DamPcC = zeros(length(data),1);
end
   

% Add a status bar, while running model
h = waitbar(0,'Calculating Metrics...');
for k = 1:(length(data))
    mCC_EX_Ct(k) = ((iGeo_Length(k))/1000)*oCC_EX(k);  %  Existing Capacity Dam Count - Product of oCC_EX and Segment length [dams]
    mCC_PT_Ct(k) = ((iGeo_Length(k))/1000)*oCC_PT(k);  %  Potential Capacity Dam Count - Product of oCC_PT and Segment length [dams]
    if mCC_EX_Ct(k) > 0
        mCC_EXtoPT(k) = mCC_EX_Ct(k)/mCC_PT_Ct(k);
    else
        mCC_EXtoPT(k) = 0;
    end
    if boolDamCapOut
       e_DamDens (k) = e_DamCt (k)/((iGeo_Length(k))/1000); % a metric of the existing dams/km
       e_DamPcC (k) = e_DamCt(k)/oCC_EX(k); % a metric of the existing dam count divided by the exiting capacity - output is a probability between 0 and 1
    end
    waitbar(k/(length(data)))
end
close(h)
clear k;

%% Write out data
%------Write the BRAT Results to an CSV file format-----

fid3 = fopen(outfilename, 'w');    %create output file to write to

if e_DamCt ~= NaN
    fprintf(fid3, 'FID,iGeo_ElMin,iGeo_ElMax,iGeo_ElBeg,iGeo_ElEnd,iGeo_Length,iGeo_Slope,iveg_VT100EX,iveg_VT30EX,iveg_VT100PT,iveg_VT30PT,iGeo_DA,iHyd_QLow,iHyd_Q2,iHyd_Q25,iHyd_SPLow,iHyd_SP2,iHyd_SP25,oVC_EX,oVC_PT,oCC_EX,oCC_PT,mCC_EX_Ct,mCC_PT_Ct,mCC_EXtoPT,iPC_UDotX,iPC_RoadX,iPC_RoadAdj,iPC_RR,iPC_Canal,iPC_LU,iPC_Own,oPC_Prob,oPBRC,e_DamCt,e_DamDens,e_DamPcC\n'); % write header
else
   fprintf(fid3, 'FID,iGeo_ElMin,iGeo_ElMax,iGeo_ElBeg,iGeo_ElEnd,iGeo_Length,iGeo_Slope,iveg_VT100EX,iveg_VT30EX,iveg_VT100PT,iveg_VT30PT,iGeo_DA,iHyd_QLow,iHyd_Q2,iHyd_Q25,iHyd_SPLow,iHyd_SP2,iHyd_SP25,oVC_EX,oVC_PT,oCC_EX,oCC_PT,mCC_EX_Ct,mCC_PT_Ct,mCC_EXtoPT,iPC_UDotX,iPC_RoadX,iPC_RoadAdj,iPC_RR,iPC_Canal,iPC_LU,iPC_Own,oPC_Prob,oPBRC\n'); % write header
 
end
% write out data
h = waitbar(0,'Writing output to disc...');
% Make sure first FID is 0 and they progress sequentially! Otherwise change
% counter to FIDStart =1
FIDstart = 0;
for j=1:(length(oCC_EX));                                                      
    if e_DamCt ~= NaN
        fprintf(fid3,'%u,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s,%f,%f,%f\n', FIDstart, iGeo_ElMin(j), iGeo_ElMax(j), iGeo_ElBeg(j), iGeo_ElEnd(j) ,iGeo_Length(j), iGeo_Slope(j), iveg_VT100EX(j), iveg_VT30EX(j), iveg_VT100PT(j), iveg_VT30PT(j), iGeo_DA(j), iHyd_QLow(j), iHyd_Q2(j), iHyd_Q25(j), iHyd_SPLow(j), iHyd_SP2(j), iHyd_SP25(j), oVC_EX(j), oVC_PT(j), oCC_EX(j), oCC_PT(j), mCC_EX_Ct(j), mCC_PT_Ct(j), mCC_EXtoPT(j), iPC_UDotX(j), iPC_RoadX(j), iPC_RoadAdj(j), iPC_RR(j), iPC_Canal(j),iPC_LU(j),iPC_Own(j), oPC_Prob(j),char(oPBRC(j)), e_DamCt(j),e_DamDens(j),e_DamPcC(j));
    else        
        fprintf(fid3,'%u,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s\n', FIDstart, iGeo_ElMin(j), iGeo_ElMax(j), iGeo_ElBeg(j), iGeo_ElEnd(j) ,iGeo_Length(j), iGeo_Slope(j), iveg_VT100EX(j), iveg_VT30EX(j), iveg_VT100PT(j), iveg_VT30PT(j), iGeo_DA(j), iHyd_QLow(j), iHyd_Q2(j), iHyd_Q25(j), iHyd_SPLow(j), iHyd_SP2(j), iHyd_SP25(j), oVC_EX(j), oVC_PT(j), oCC_EX(j), oCC_PT(j), mCC_EX_Ct(j), mCC_PT_Ct(j), mCC_EXtoPT(j), iPC_UDotX(j), iPC_RoadX(j), iPC_RoadAdj(j), iPC_RR(j), iPC_Canal(j),iPC_LU(j),iPC_Own(j), oPC_Prob(j), char(oPBRC(j)));
    end
    waitbar(j/(length(oCC_EX)))
    FIDstart = FIDstart +1;
end
close(h)
clear j;
fclose(fid3);
fprintf('Done writing output file %s.\n',outfilename);


%% Summary Metrics and Output
