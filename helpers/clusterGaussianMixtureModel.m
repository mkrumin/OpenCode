%included for reference to show how the algorithm works
%precomputed cluster labels are included for example plot

%clusters TM vs SW activity statistics using a GMM

%GMModel initialises using kmeans++
%vs. normal k-means, k-means++ picks better initial centres,
%by iteratively choosing those with sufficient distance from the chosen ones
% otherwise startType = 'known', use prior knowledge that two clusters should be along the axes

%pi is the proportion each cluster is found in the population ("prior")
%mu and cov are the data mu and covariance of the neurons assigned to each cluster
%gamma is the "responsibilities" i.e. posterior, normalized to integrate(sum) to 1

function [labels,GMModel,errFlag] = clusterGaussianMixtureModel(NClust,mName,expDate,taskName,NPlanes)

errFlag = 0;
doPlotsIso = false;

dataDir = 'E:\OneDrive - University College London\16_Manuscripts\PPC\OpenCode\';
clustFN = fullfile(dataDir, sprintf('clusterlabels_N%d_%s_%s_%s.mat', NClust,mName,expDate));

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));

startType = 'default'

if exist(clustFN) && sum(ismember(whichTasks,{'TM', 'SW'}))==2
    load(clustFN)
else
    eachData    = calcIsolationDist(mName,expDate,taskName, NPlanes);
    allData     = horzcat(eachData{TMIdx},eachData{SWIdx});

    %use n=3 iters to ensure better convergence, should be enough?
    %fitgmdist picks the iter with the lowest negative log likelihood
    GMModel = fitgmdist(allData, NClust, 'Replicates', 10, 'Options', statset('MaxIter', 500)); 

    %predict labels
    pi = GMModel.ComponentProportion; %mixing proportions

    for cl = 1:NClust
        mu  = GMModel.mu(cl,:);
        cov = GMModel.Sigma(:,:,cl);
        likelihood = mvnpdf(allData,mu,cov);
        preds(:,cl) = pi(cl)*likelihood;
    end
    [~,labels] = max(preds,[],2);

end

%% view results if desired
figure('Position', [680 799 205 179])
scatter(allData(:,1),allData(:,2),10,labels, 'filled', 'markeredgecolor', 'k')
xlabel('T-maze activity')
ylabel('SW task activity')
axis square
axis([-0.15 4.5 -0.15 4.5])

end

