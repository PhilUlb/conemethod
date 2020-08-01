function poc_corrected = speed_criterion(hspeed,incone_start,poc)
% Search for minima in hspeed between raw POC and beginning of in-cone
% epoch

hspeed = -hspeed; % To search for minima with findpeaks

poc_corrected = nan(1,numel(incone_start));
    
for i = 1:numel(incone_start) % Speed criterion application per POC
    incone_start(i) = incone_start(i)-1;
    if incone_start(i)~=0 && incone_start(i)-poc(i) > 1 % At least 3 datapoints in search space to find a minimum
        [pks,pot_pocs] = findpeaks(hspeed(poc(i):incone_start(i)));
        
        if ~isempty(pot_pocs)
                poc_corrected(i) = poc(i) + pot_pocs(pks==max(pks)) -1; % POC with speed minimum at highest peak (lowest speed minimum) in case of multiple peaks
            else
                poc_corrected(i) = poc(i); % If there's no speed minimum, POC remains at POC raw
        end
    else
        poc_corrected(i) = poc(i); % If there's no speed minimum, POC remains at POC raw
    end
end