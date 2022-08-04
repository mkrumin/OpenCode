% fig 1

tsk = find(strcmp(taskName, 'TM')); %or SW
[ccTM,ppTM,nnTM] = getPCdata(session{tsk})
plotPC(session{tsk})
