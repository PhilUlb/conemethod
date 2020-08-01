function dirdiff_corrected = overshoot_criterion(dirdiff,incone_start,incone_stop,overshoot_target_ind)

dirdiff_corrected = dirdiff;


for i = 1:size(dirdiff,2) % Loop over every target
    if length(incone_start{i})>1 % overshoot possible
        for j = 2:length(incone_start{i})
            % 1. Define the search space (1/2): out-of-cone periods in between in-cone periods
            s_ind = incone_stop{i}(j-1)+1;
            e_ind = incone_start{i}(j)-1;
            
            % 2. Rate of increase of direction - cone surface difference
            chosen_drv = diff(dirdiff{i}(s_ind:e_ind)); % Chosen target cone
            opp_drv    = diff(dirdiff{overshoot_target_ind(i)}(s_ind:e_ind)); % Opposite target cone
            
            % 3. Define search space (2/2): Within the search space as defined under 1.
            %    we only consider the portion where the dirdiff slope is positive
            e_ind2 = find(chosen_drv>0,1,'last');
            
            chosen_drv = chosen_drv(1:e_ind2);
            opp_drv    = opp_drv(1:e_ind2);
            
%             Debugging
%             figure
%             plot(chosen_drv)
%             hold on
%             plot(opp_drv)
%             hold off
            
            % 4. If the rate of increase is smaller for the chosen target than
            %    for the opposite target --> overshoot
            if mean(chosen_drv<opp_drv)==1
                dirdiff_corrected{i}(s_ind:e_ind) = 0; % Overshoot out-of-cone segments are treated as in-cone
            end
        end
    end
end