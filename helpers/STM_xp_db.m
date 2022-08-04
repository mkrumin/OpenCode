%database of experimental sessions that include the hybrid task
function xpdb = STM_xp_db();
i = 0;
%% JL022
i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-05-21';
xpdb{i}.taskName        = {'SW', 'STM', 'SWreplay', 'STMreplay'};
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-06-08';
xpdb{i}.taskName        = {'SW', 'STM', 'blankwheel', 'TM', 'blankball'};
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-06-13';
xpdb{i}.taskName        = {'TM', 'blankball', 'STM', 'SW', 'blankwheel', 'SN'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-06-14';
xpdb{i}.taskName        = {'SW', 'blankwheel', 'STM', 'scrambledSTMreplaywheel', 'blankball'};  
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-06-16';
xpdb{i}.taskName        = {'STM', 'SW', 'blankwheel', 'scrambledSTMreplaywheel', 'TM', 'blankball'}; 
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'JL022';
xpdb{i}.expDate 		= '2018-06-18';
xpdb{i}.taskName        = {'STM', 'blankwheel', 'SW', 'STMreplay'}; 
xpdb{i}.NPlanes         = 2;


%% LEW_002
i = i + 1;
xpdb{i}.mName 			= 'LEW_002';
xpdb{i}.expDate 		= '2018-06-13';
xpdb{i}.taskName        = {'STM', 'SW', 'blankwheel', 'SN'};
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'LEW_002';
xpdb{i}.expDate 		= '2018-06-14';
xpdb{i}.taskName        = {'SW', 'STM', 'blankwheel', 'scrambledSTMreplaywheel'};
xpdb{i}.NPlanes         = 2;

i = i + 1;
xpdb{i}.mName 			= 'LEW_002';
xpdb{i}.expDate 		= '2018-06-15';
xpdb{i}.taskName        = {'STM', 'blankwheel', 'SW', 'scrambledSTMreplaywheel', 'SN'};
xpdb{i}.NPlanes         = 2;
