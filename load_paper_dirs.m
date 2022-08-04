function baseDir = load_paper_dirs()

%where the "OpenCode" and "OpenData" folders are kept
try
    baseDir = 'D:\Lee_etal'; % enter your base directory here
catch
    error('please fill in baseDir in load_paper_dirs() in the root folder')
end
