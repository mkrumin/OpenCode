
%this takes neural frame times of session of cell(NTasks,1) 
%counts number of frames in each task, and returns cumulative for later indexing of a catPlanes matrix

%doesn't work on a plane-by-plane basis, because takes the minimum.

%if want to take in dat.Fcell and count in each *within plane*, need to implement later. 

function [NCumulFrames,NFramesEachTask] = countTaskFrames(inputData) %assumes session is cell(NTasks,1)
	NTasks = length(inputData); %assumed
    if isstruct(inputData{1})
        session = inputData;
        for tsk = 1:NTasks
			try
            	NFramesEachTask(tsk) = min(cell2mat(cellfun(@length, session{tsk}.fFT, 'UniformOutput', 0))); 
        	catch
        		NFramesEachTask(tsk) = min(cell2mat(cellfun(@(x) size(x,2), session{tsk}.fData, 'UniformOutput', 0))); 
			end        		
        end
    elseif iscell(inputData{1})
        for tsk = 1:NTasks
            NFramesEachTask(tsk) = min(cell2mat(cellfun(@(x) size(x,2), inputData{tsk}, 'UniformOutput', 0))); 
        end
    end

	NCumulFrames = cumsum([1 NFramesEachTask]);
