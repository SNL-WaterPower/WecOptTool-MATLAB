function plotFreq(device)
            
    % Look at first sea state only

    figure('Name','SimRes.plotFreq')
    ax(1) = subplot(2,1,1);
    hold on
    grid on
    ax(2) = subplot(2,1,2);
    hold on
    grid on

    fns = ["eta", "F0", "u", "Fpto"];
    vrs = {device.motions(1).eta_fd    ...
           device.motions(1).F0        ...
           device.performances(1).u    ...
           device.performances(1).Fpto};
    mrks = {'o','.','+','s'};

    for ii = 1:length(fns)

        stem(ax(1),device.motions(1).w, abs(vrs{ii}), mrks{ii},...
            'DisplayName', fns{ii})
        stem(ax(2),device.motions(1).w, angle(vrs{ii}), mrks{ii},...
            'DisplayName', fns{ii})
    end

    ylabel(ax(1),'Magnitude')
    ylabel(ax(2),'Angle [rad]')
    xlabel('Frequency [rad/s]')

    legend(ax(1))
    linkaxes(ax,'x')

end