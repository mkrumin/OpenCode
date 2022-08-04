%set first image as "anchor" and align all other FOVs across days to this image
%use pre-computed manual affine transform to create initial alignment, then shift
%subtle differences using cross-correlation peaks
%then take isolation distances for each cell and compute weighted average across days
%uses example subject from other panels

function alignROIs()

baseDir = load_paper_dirs;
%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

usfac = 100; %upsampling factor to align pixels

%%%%%%%%%%%%%%%%%%%%%%%%%% fixed %%%%%%%%%%%%%%%%%%%%%% 
mName 			    = 'JL035';
expDateFixed 		= '2019-06-12';
taskNameFixed       = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanesFixed        = 2;

i = 0;
i = i + 1;
xpdb{i}.mName 			= mName;
xpdb{i}.expDate 		= expDateFixed;
% xpdb{i}.expNumStr       = expNumStrFixed;
xpdb{i}.taskName        = taskNameFixed;
xpdb{i}.NPlanes         = NPlanesFixed;

[roiCentroids_fixed,rPix_fixed] = getROILocations(mName,expDateFixed); 

TMIdx = find(strcmp(taskNameFixed, 'TM'));
SWIdx = find(strcmp(taskNameFixed, 'SW'));

allDB_fixed   = calcIsolationDist(mName,expDateFixed,taskNameFixed, NPlanesFixed);
allDBSI_fixed = (allDB_fixed{TMIdx}-allDB_fixed{SWIdx})./(allDB_fixed{TMIdx}+allDB_fixed{SWIdx});

%% start with pixels to sanity check 
immap_fixed   = zeros(512,512); %i.e. the background is white - the mid value
NCells = length(rPix_fixed); 

for ci = 1:NCells
    immap_fixed(rPix_fixed{ci}) = allDB_fixed(ci); %needed?
end
immap_fixed(isnan(immap_fixed))=0;

pd_fixed        = padarray(immap_fixed,[200 200]); %padding in pixels
immap_moved{1}  = pd_fixed;

randomPl = 1;

load(fullfile(baseDir, 'OpenData', 'PrecomputedData', sprintf('regops_%s_%s.mat', mName,expDateFixed)))
mImg_fixed = ops1{randomPl}.mimg1; 

%%%%%%%%%%%%%%%%%%%%%%%%%% moving %%%%%%%%%%%%%%%%%%%%%% 
        
i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-13';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-15';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-16';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
xpdb{i}.NPlanes         = 1;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-17';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-22';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-23';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-25';
xpdb{i}.taskName        = {'SW', 'blankwheel', 'TM', 'blankball', 'passiveBall'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL035';
xpdb{i}.expDate 		= '2019-06-26';
xpdb{i}.taskName        = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 
xpdb{i}.NPlanes         = 2;

NMaps = length(xpdb);
for xp = 2:NMaps
    mName       = xpdb{xp}.mName;
    expDate     = xpdb{xp}.expDate;
    taskName    = xpdb{xp}.taskName;
    NPlanes     = xpdb{xp}.NPlanes;

    %% load pixels
    TMIdx = find(strcmp(taskName, 'TM'));
    SWIdx = find(strcmp(taskName, 'SW'));
    [roiCentroids_moving,rPix_moving] = getROILocations(mName,expDate,expNumStr); 

    %returns NCells x 1 cell of coords in linear indexing
    allDB_moving   = calcIsolationDists(mName,expDate,expNumStr,taskName, NPlanes,0);
    allDBSI_moving = (allDB_moving{TMIdx}-allDB_moving{SWIdx})./(allDB_moving{TMIdx}+allDB_moving{SWIdx});

    contVar_moving = allDBSI_moving;

    %% make a map
    immap_moving{xp}   = zeros(512,512); %i.e. the background is white - the mid value
    NCells = length(rPix_moving); 
    for ci = 1:NCells
        immap_moving{xp}(rPix_moving{ci}) = contVar_moving(ci); %needed?
    end
    assert(isequal(NCells, length(contVar_moving)));
    immap_moving{xp}(isnan(immap_moving{xp}))=0;

    %% load transform
    FN = fullfile(baseDir, 'OpenCode', 'PrecomputedData', ...
        sprintf('manual_tf_%s_%s_%s.mat', mName,expDateFixed,expDate))
    load(FN,'tf')

    pd_moving{xp} = padarray(immap_moving{xp},[200 200]); %padding in pixels
    outView = imref2d(size(pd_moving{xp})); %align to reference (allows translation to work)
    immap_moved{xp} = imwarp(pd_moving{xp},tf, ...
        'OutputView',outView, 'smoothedges', false, 'interp', 'nearest'); %nearest to not include half-sat pixels

    
    load(fullfile(baseDir, 'OpenCode', 'PrecomputedData', sprintf('regops_%s_%s.mat', ...
        xpdb{xp}.mName, xpdb{xp}.expDat)))
    mImg_moving{xp} = ops1{randomPl}.mimg1; %average over planes.....

    mImg_moved{xp}  = imwarp(padarray(mImg_moving{xp},[200 200]),tf, ...
                        'OutputView',outView);
    %nearest to not include half-sat pixels
end

%%see xcorr with each of moving 
%%% look for one with a sharp peak

weightEa    = 1/NMaps;

newFx{1} = immap_moved{1}; %this is a misnomer because it's the first fixed im
for fx = 2:4
    output = dftregistration(fft2(immap_moved{1}),fft2(immap_moved{fx}),usfac); 
    newFx{fx} = shift(immap_moved{fx},[output(3),output(4)], 0); %pad with zeros

    newMimg{fx} = shift(mImg_moved{fx},[output(3),output(4)], 0); %pad with zeros
    allShifts(fx,:) = [output(3),output(4)];
end

comb1to4 = imlincomb(weightEa,newFx{1},weightEa,newFx{2},weightEa,newFx{3},weightEa,newFx{4});

load('tf1617v2.mat')
immap_moved{5} = imwarp(immap_moved{5},tf, ...
    'OutputView',outView, 'smoothedges', false, 'interp', 'nearest');

newFx{5} = immap_moved{5}; %yep
for fx = 6:9
    output = dftregistration(fft2(immap_moved{5}),fft2(immap_moved{fx}),usfac); 
    newFx{fx} = shift(immap_moved{fx},[output(3),output(4)], 0); %pad with zeros

    allShifts(fx,:) = [output(3),output(4)];
end

comb5to9 = imlincomb(weightEa,newFx{5},weightEa,newFx{6},weightEa,newFx{7},weightEa,newFx{8},weightEa,newFx{9});

output = dftregistration(fft2(comb1to4),fft2(comb5to9),usfac); 
for ii = 5:9
    finalImg{ii} = shift(newFx{ii},[output(3),output(4)], 0); %pad with zeros
end

for ii = 1:4
    finalImg{ii} = newFx{ii};
end

shifted5to9 = shift(comb5to9,[output(3),output(4)], 0); %pad with zeros
allShifts(5,:) = [output(3),output(4)];

combAll = imlincomb(weightEa*4, comb1to4, weightEa*5, shifted5to9);

figure;
imagesc(combAll)
axis image
colormap(orangeblue)
caxis([-0.2 0.2])
xticks('')
yticks('')
%% standard 512x512 FOV for scale
hold on

%dotted box showing FOV
plot([228 684], [684 684], 'k--', 'linewidth', 1.2)
plot([684 684], [228 684], 'k--', 'linewidth', 1.2)
plot([228 684], [228 228], 'k--', 'linewidth', 1.2)
plot([228 228], [228 684], 'k--', 'linewidth', 1.2)
set(gca, 'linewidth', 1.2)

