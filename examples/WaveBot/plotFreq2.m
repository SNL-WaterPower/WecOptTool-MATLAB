function plotFreq2(device)

    if nargin < 2 || isempty(fig)
                fig = figure;
    end
    set(fig,'Name','Performance.plotFreq');

    fns = {'F0','u','Fpto'};
    mrks = {'o','.','+','s'};

    n = length(device);
    
    for jj = 1:n
        
        for ii = 1:length(fns)
            
            if strcmp(fns{ii}, 'F0')
                fv = device(jj).motions.(fns{ii})(:,1); % use the first column if this is PS
            else
                fv = device(jj).performances.(fns{ii})(:,1); % use the first column if this is PS
            end

            % mag plot
            ax(jj,1) = subplot(2,n,sub2ind([n,2],jj,1));
            title(device(jj).controlType,'interpreter','none')
            hold on
            grid on
            
            % Only works for single sea-states?
            stem(ax(jj,1),device(jj).seaState.w, mag2db(abs(fv))...
                ,mrks{ii},...
                'DisplayName',fns{ii},...
                'MarkerSize',8,...
                'Color','b')

            % phase plot
            ax(jj,2) = subplot(2,n,sub2ind([n,2],jj,2));
            hold on
            grid on

            stem(ax(jj,2),obj(jj).w, angle(fv)...
                ,mrks{ii},...
                'DisplayName',fns{ii},...
                'MarkerSize',8,...
                'Color','b')

            ylim(ax(jj,2),[-pi,pi])
        end
        xlabel(ax(jj,2),'Frequency [rad/s]')
    end
    ylabel(ax(1,1),'Magnitude [dB]')
    ylabel(ax(1,2),'Angle [rad]')
    legend(ax(n,1))
    linkaxes(ax,'x')
    linkaxes(ax(:,1),'y')
end

