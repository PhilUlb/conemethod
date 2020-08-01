% Cluster permutation test - embedded t-test to compare two time series, based on
% Maris & Oostenveld (2007; DOI: https://doi.org/10.1016/j.jneumeth.2007.03.024)

% This function was written by Benjamin Dann (Dann et al., 2016; DOI: http://dx.doi.org/10.7554/eLife.15719.001)


function [h,pValCont] = ClusterPermtTest(Cond1,Cond2,nRand,alpha)
if ~exist('nRand','var') || isempty(nRand)
    nRand = 1000;
end
if ~exist('alpha','var') || isempty(alpha)
    alpha = 0.05;
end

n1 = size(Cond1,1);
n2 = size(Cond2,1);
CondAll = [Cond1;Cond2]; %combine both samples
    
tic
Maxclustertval = nan(nRand,1);
parfor randi=1:nRand
    
    randvec=randperm(n1+n2); %generate random vector
    
    Cond1Perm = CondAll(randvec(1:n1),:,:);      % take n random samples and put in pot a and Take only highest cluster
    Cond2Perm = CondAll(randvec(n1+1:n1+n2),:,:);
    
    [~,p,~,stats] = ttest2(Cond1Perm,Cond2Perm,alpha);
    [sigPermpos NUMpos] = bwlabeln(p <= alpha & stats.tstat > 0);
    [sigPermneg NUMneg] = bwlabeln(p <= alpha & stats.tstat < 0);
    
    clustertval = nan(NUMpos+NUMneg,1);
    for i = 1 : NUMpos;
        clustertval(i) = sum(abs(stats.tstat(sigPermpos == i)));
    end
    for i = 1 : NUMneg;
        clustertval(i+NUMpos) = sum(abs(stats.tstat(sigPermneg == i)));
    end
    
    if isempty(clustertval)
        Maxclustertval(randi) = 0;
    else
        Maxclustertval(randi) = max(clustertval);
    end
end
clear randvec Cond1Perm Cond2Perm p stats clustertval 
 toc
[~,p,~,stats] = ttest2(Cond1,Cond2,alpha);
[sigRealpos NUMpos] = bwlabeln(p <= alpha & stats.tstat > 0);
[sigRealneg NUMneg] = bwlabeln(p <= alpha & stats.tstat < 0);

clustertvalReal = nan(NUMpos+NUMneg,1);
for i = 1 : NUMpos;
    clustertvalReal(i) = sum(abs(stats.tstat(sigRealpos == i)));
end
for i = 1 : NUMneg;
    clustertvalReal(i+NUMpos) = sum(abs(stats.tstat(sigRealneg == i)));
end

pvalCluster = nan(length(clustertvalReal),1);
pValCont = ones(size(Cond1,2),1);
for i = 1 : length(clustertvalReal)
    pvalCluster(i) = sum(Maxclustertval >= clustertvalReal(i))/nRand;
    if i <= NUMpos
        pValCont(sigRealpos == i) = pvalCluster(i);
    else
        pValCont(sigRealneg == i-NUMpos) = pvalCluster(i);
    end
end
h = pValCont < alpha;

h = h';
pValCont = pValCont';