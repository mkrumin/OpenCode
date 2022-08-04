%regi.regi_xp_db_prs pairs of sessions with same cells over days

pr = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pr = pr+1;
mName{pr} 			= 'JL022';
NPlanes{pr}         = 2;

i = 0;
i = i+1;
expDates{pr}{i} 	= '2018-06-15';
taskName{pr}{i}     = {'TM', 'blankball', 'SW', 'blankwheel', 'STM'}; 

i = i+1;
expDates{pr}{i} 	= '2018-06-17';
taskName{pr}{i}     = {'blankball', 'TM', 'blankwheel', 'SW', 'STM'};

pr = pr+1;
mName{pr} 			= 'JL008';
NPlanes{pr}         = 2;

i = 0;
i = i + 1;
expDates{pr}{i} 	= '2017-09-23';
taskName{pr}{i}     = {'TM', 'SW'};

i = i + 1;
expDates{pr}{i} 	= '2017-09-24';
taskName{pr}{i}     = {'TM', 'SW'};

pr = pr+1;
i = 0;
mName{pr} 		= 'JL035';
NPlanes{pr}     = 2;

i = i + 1;
expDates{pr}{i}     = '2019-06-22';
taskName{pr}{i}     = {'TM', 'blankball', 'SW', 'blankwheel'}; 

i = i + 1;
expDates{pr}{i}    = '2019-06-23';
taskName{pr}{i}    = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 

pr = pr+1;
i = 0;
mName{pr} 		= 'JL035';
NPlanes{pr}     = 2;

i = i + 1;
expDates{pr}{i}     = '2019-06-25';
taskName{pr}{i}     = {'SW', 'blankwheel', 'TM', 'blankball', 'passiveBall'}; 

i = i + 1;
expDates{pr}{i}     = '2019-06-26';
taskName{pr}{i}     = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 
