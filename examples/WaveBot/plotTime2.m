function plotTime2(device ,t)
            
    if nargin < 2
        trep = getRepeatPer(device(1));
        t = 0:0.05:trep;
    end

    fig = figure('Name','Performance.plotTime');
    fig.Position = fig.Position.*[1 1 1 1.5];

    % fields for plotting
    fns = {'eta_fd','F0','pos','u','Fpto','powPerFreq'};

    for ii = 1:length(fns)
        ax(ii) = subplot(length(fns), 1, ii);
        hold on
        grid on
    end

    for jj = 1:length(device)
        
        if any(strcmp(fns{ii}, ['eta_fd', 'F0']))
            fv = device(jj).motions.(fns{ii})(:,1); % use the first column if this is PS
        else
            fv = device(jj).performances.(fns{ii})(:,1); % use the first column if this is PS
        end

        for ii = 1:length(fns)
            
            if strcmp(fns{ii}, 'powPerFreq')
                timeRes.(fns{ii}) = getTimeResPow(device(jj), t);
            else
                timeRes.(fns{ii}) = getTimeRes(device(jj),fv, t);
            end
            
            plot(ax(ii),t,timeRes.(fns{ii}))
            ylabel(ax(ii),fns{ii})
        end

        for ii = 1:length(ax) - 1
            set(ax(ii),'XTickLabel',[])
        end
        linkaxes(ax,'x')
        xlabel(ax(end),'Time [s]')
    end
    xlim([t(1), t(end)])

    if length(device) > 1
        legend(ax(1),{device.controlType})
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
    fv = fv(:,ph_idx); % use the first column if this is PS
    for ii = 1:length(device.motions.w) % for each freq. TODO - use IFFT
        timeRes = timeRes ...
            + real(fv(ii) * exp(1i * device.motions.w(ii) * t_vec));
    end
    
end

function [timeRes] = getTimeResPow(device, t_vec)
    
    u = device.performances.u(:,1);
    fpto = device.performances.Fpto(:,1);
    
    vel = getTimeRes(device, u, t_vec);
    f = getTimeRes(device, fpto, t_vec);
    timeRes = vel .* f;
    
end
