function T = summary(device)
            
    trep = getRepeatPer(device(1));
    t = linspace(0,trep,1e3);

    for ii = 1:length(device)

        for jj = 1:size(device(ii).performances.ph,2) % for each phase in PS cases

            tmp.pow_avg(ii,jj) = sum(real(device(ii).performances.powPerFreq(:,jj)));
            
            pow_t = getTimeResPow(device(ii), t, jj);
            tmp.pow_max(ii, jj) = max(abs(pow_t));
            
            pos_t = getTimeRes(device(ii), device(ii).performances.pos, t, jj);
            tmp.pos_max(ii, jj) = max(abs(pos_t));

            vel_t = getTimeRes(device(ii), device(ii).performances.u, t, jj);
            tmp.vel_max(ii, jj) = max(abs(vel_t));

            Fpto_t = getTimeRes(device(ii), device(ii).performances.Fpto, t, jj);
            tmp.Fpto_max(ii, jj) = max(abs(Fpto_t));
        end

        fn = fieldnames(tmp);
        for kk = 1:length(fn)
            out.(fn{kk}) = mean(tmp.(fn{kk}), 2);
        end

    end

    % augment names if they are the same
    if any(strcmp(device(1).controlType, {device(2:end).controlType}))
        for ii = 1:length(device)
            rnames{ii} = [device(ii).name, '_', num2str(ii)];
        end
    else
        rnames = {device.controlType};
    end
    rnames = reshape(rnames,[],1);

    mT = table(out.pow_avg(:),out.pow_max(:),...
        out.pos_max(:),out.vel_max(:),out.Fpto_max(:),...
        'VariableNames',...
        {'AvgPow','|MaxPow|','MaxPos','MaxVel','MaxPTO'},...
        'RowNames',rnames);

    if nargout
        T = mt;
    else
        disp(mT)
    end

end

function [tRep] = getRepeatPer(device)
    tRep = 2*pi/(device.motions.w(2) - device.motions.w(1));
end

function [timeRes] = getTimeRes(device, fv, t_vec, ph_idx)
    if nargin < 4
        ph_idx = 1;
    end

    timeRes = zeros(size(t_vec));
    ph_idx
    size(fv)
    fv = fv(:,ph_idx); % use the first column if this is PS
    for ii = 1:length(device.motions.w) % for each freq. TODO - use IFFT
        timeRes = timeRes ...
            + real(fv(ii) * exp(1i * device.motions.w(ii) * t_vec));
    end
    
end

function [timeRes] = getTimeResPow(device, t_vec, ph_idx)
    
    if nargin < 4
        ph_idx = 1;
    end

    u = device.performances.u(:,1);
    fpto = device.performances.Fpto(:,1);
    
    vel = getTimeRes(device, u, t_vec, ph_idx);
    f = getTimeRes(device, fpto, t_vec, ph_idx);
    timeRes = vel .* f;
    
end
