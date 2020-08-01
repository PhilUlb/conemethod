function [dirdiff_corrected] = tolerance_criterion(dirdiff,incone_start,tolerance)
% Searches in between two in-cone epochs whether dirdiff does not exceed
% tolerance. If this is the case, dirdiff is set to 0 for this period (i.e.
% the current direction is treated as "in-cone").

dirdiff_corrected = dirdiff;

if numel(incone_start)>1 % Not applicable if there's only one in-cone epoch
    for i = 2:numel(incone_start)
        if max(dirdiff(incone_start(i-1):incone_start(i)))<tolerance
            dirdiff_corrected(incone_start(i-1):incone_start(i)) = 0;
        end
    end
end