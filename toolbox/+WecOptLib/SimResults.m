classdef SimResults < handle
    % SimResults   simulation results class for WecOptTool
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
        date
        Vo
        wec
    end
    methods
        function obj = SimResults(name)
            
            if nargin > 0
                obj.name = name;
            else
                obj.name = 'tmp';
            end
            obj.date = now;
        end
        
        function plotTime(obj ,t)
            
            if nargin < 2
                trep = 2*pi/(obj(1).w(2) - obj(1).w(1));
                t = 0:0.05:trep;
            end
            
            figure('Name','SimRes.plotTime')
            
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
        
        function plotFreq(obj,fig)
            
            if nargin < 2 || isempty(fig)
                fig = figure;
            end
            set(fig,'Name','SimRes.plotFreq');
            
            fns = {'Fe','u','Fpto'};
            mrks = {'o','.','+','s'};
            
            n = length(obj);
            for jj = 1:n
                
                
                
                for ii = 1:length(fns)
                    
                    ax(jj,1) = subplot(2,n,sub2ind([n,2],jj,1));
                    title(obj(jj).name,'interpreter','none')
                    hold on
                    grid on
                    ax(jj,2) = subplot(2,n,sub2ind([n,2],jj,2));
                    hold on
                    grid on
                    
                    stem(ax(jj,1),obj(jj).w, mag2db(abs(obj(jj).(fns{ii}))),mrks{ii},...
                        'DisplayName',fns{ii},'MarkerSize',8,'Color','b')
                    stem(ax(jj,2),obj(jj).w, angle(obj(jj).(fns{ii})),mrks{ii},...
                        'DisplayName',fns{ii},'MarkerSize',8,'Color','b')
                    
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
        
        function T = summary(obj)
            
            avgpow = arrayfun(@(x) sum(real(x.pow)), obj);
            
            if any(strcmp(obj(1).name, {obj(2:end).name}))
                for ii = 1:length(obj)
                    rnames{ii} = [obj(ii).name, '_', num2str(ii)];
                end
            else
                rnames = {obj.name};
            end
            rnames = reshape(rnames,[],1);
            
            T = table(avgpow(:),'VariableNames',{'AvgPow'},...
                'RowNames', rnames);
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
