function [num_computed_paths] = adaptive_threshold(eigenvalue_matrix,smoothed_csi_y,source_num,ii)

% [Utmp,D] = eig(X*X');
D = abs(eigenvalue_matrix);
[Dtmp,I] = sort(diag(D), 'descend');
D = diag(Dtmp);
% U = Utmp(:,I);

minMP = 1;
useMDL = 1;
useDiffMaxVal = 0; % Default value is 1. If set to 1, it considers only those eignevalues who are above a certain threshold when compared to the maximum eigenvalue

% % % MDL criterion based 
MDL = [];
lambdaTot = diag(D);
subarraySize = size(squeeze(smoothed_csi_y(1,:,:)),1);
nSegments = size(squeeze(smoothed_csi_y(1,:,:)),2);
maxMultipath = length(lambdaTot); % previously used 6 for maximum number of multipath
for k = 1:maxMultipath
    MDL(k) = -nSegments*(subarraySize-(k-1))*log(mean(lambdaTot(k:end))/mean(lambdaTot(k:end))) + 0.5*(k-1)*(2*subarraySize-k+1)*log(nSegments);
end

% % Another attempt to take the number of multipath as minimum of MDL
[~, SignalEndIdxTmp] = min(MDL);


EigDiffCutoff = source_num;


if useMDL
    SignalEndIdx = max(SignalEndIdxTmp-1, 2);
else
    VecForSignalEnd = wkeep(diag(D),5,'l'); % latest last used is 5 % Previously used 8 which means allow upto 8 eigenvalues
    diag(D(1:floor(length(D)/2)));
    Criterion1 = diff(db(VecForSignalEnd))<=max(-EigDiffCutoff,min(diff(db(VecForSignalEnd))));
    Criterion3 = (VecForSignalEnd(1:end-1)/VecForSignalEnd(1)>0.03); %  Previously used 0.165 and right now using 0.065

    SignalEndIdx = find(Criterion1 & Criterion3,1,'last');
    if isempty(SignalEndIdx)
        SignalEndIdx = find(Criterion3,1,'last');
    end
end


num_computed_paths = min(SignalEndIdx, EigDiffCutoff);

if min(SignalEndIdx, EigDiffCutoff) == EigDiffCutoff
  o = 1;
end
    
