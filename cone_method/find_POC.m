function poc = find_POC(dirdiff,incone_start,incone_stop)
% Locates for each in-cone epoch the POC as the point from which dirdiff monotonically decreases
% until zero.

poc = nan(1,numel(incone_start));

% For each POC, the search space is confined between the end of the
% preceding in-cone epoch and the beginning of the upcoming in-cone epoch.
% If the POC belongs to the first in-cone epoch, the end of the preceding
% in-cone epoch is defined as first dirdiff datapoint post cut-off
incone_stop = [find(~isnan(dirdiff),1,'first') incone_stop]; 

dirdiff_drv1 = [nan; diff(dirdiff)];

for i = 1:numel(incone_start)
    if max(dirdiff_drv1(incone_stop(i):incone_start(i)))>0
        poc(i) = find(dirdiff_drv1(incone_stop(i):incone_start(i))>0,1,'last')+incone_stop(i)-1;
    else
        poc(i) = incone_stop(i);
    end
end

