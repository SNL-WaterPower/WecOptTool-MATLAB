classdef simResults
    % simResults   simulation results class for WecOptTool
    % TODO
    %
    % simResults Properties:
    %   ph - phase
    %   w - frequency vector
    %   eta - complex wave elevation spectrum
    %   Fe - complex excitation spectrum
    %   pow - real power spectrum (tot_avg_pow = sum(simResults.pow)
    %   u - complex velocity spectrum
    %   Zpto - PTO impedance
    %   Fpto - complex PTO force spectrum
    %   name - unique name for plot legends, etc.
    %
    % simResults Methods:
    %   plotTime - plots realization of time domain results
    %   plotFreq - plots frequency domain results
    %   summary - producing a table of summary results
    %
    % See also WECOPTLIB.MODELS.WAVEBOT
    %
    % Copyright 2020 National Technology & Engineering Solutions of Sandia,
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    %
    %     WecOptTool is free software: you can redistribute it and/or
    %     modify it under the terms of the GNU General Public License as
    %     published by the Free Software Foundation, either version 3 of
    %     the License, or (at your option) any later version.
    %
    %     WecOptTool is distributed in the hope that it will be useful, but
    %     WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %     General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with WecOptTool.  If not, see
    %     <https://www.gnu.org/licenses/>.
    
    properties
        ph
        w
        eta
        Fe
        u
        pos
        Zpto
        Fpto
        pow
        name
    end
    methods
        function obj = simResults(name)
            obj.name = name;
        end
        
        function plotTime(obj ,t)
            
            if nargin < 2
                trep = 2*pi/(obj(1).w(2) - obj(1).w(1));
                t = 0:0.05:trep;
            end
            
            figure('Name','simRes.plotTime')
            
            for ii = 1:5
                ax(ii) = subplot(5, 1, ii);
                hold on
                grid on
            end
            
            
            for jj = 1:length(obj)
                fns = {'eta','Fe','u','Fpto'};
                for ii = 1:length(fns)
                    timeRes.(fns{ii}) = getTimeRes(obj(jj),fns{ii}, t);
                end
                timeRes.pow = timeRes.u .* timeRes.Fpto;
                
                fns = [fns(:)', {'pow'}];
                
                for ii = 1:length(fns)
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
            
        end
        
        function plotFreq(obj)
            
            if length(obj) > 1
                error('Not implemented') % TODO
            end
            
            figure('Name','simRes.plotFreq')
            ax(1) = subplot(2,1,1);
            hold on
            grid on
            ax(2) = subplot(2,1,2);
            hold on
            grid on
            
            fns = {'eta','Fe','u','Fpto'};
            mrks = {'o','.','+','s'};
            
            for ii = 1:length(fns)
                
                stem(ax(1),obj.w, abs(obj.(fns{ii})),mrks{ii},...
                    'DisplayName',fns{ii})
                stem(ax(2),obj.w, angle(obj.(fns{ii})),mrks{ii},...
                    'DisplayName',fns{ii})
            end
            
            ylabel(ax(1),'Magnitude')
            ylabel(ax(2),'Angle [rad]')
            xlabel('Frequency [rad/s]')
            
            legend(ax(1))
            linkaxes(ax,'x')
            
        end
        
        function T = summary(obj)
            
            avgpow = arrayfun(@(x) sum(real(x.pow)), obj);
            T = table(avgpow','VariableNames',{'AvgPow'},'RowNames', {obj.name});
            % TODO add more columns
            
        end
        
    end
    
    methods (Access=protected)
        function [timeRes] = getTimeRes(obj, fn, t_vec)
            timeRes = zeros(size(t_vec));
            for ii = 1:length(obj.w) % for each freq. TODO - use IFFT
                timeRes = timeRes ...
                    + real(obj.(fn)(ii) * exp(1i * obj.w(ii) * t_vec));
            end
        end
    end
end