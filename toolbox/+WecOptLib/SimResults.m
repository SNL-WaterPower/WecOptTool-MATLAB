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
                trep = obj(1).getRepeatPer();
                t = 0:0.05:trep;
            end
            
            fig = figure('Name','SimRes.plotTime');
            fig.Position = fig.Position.*[1 1 1 1.5];
            
            
             fns = {'eta','Fe','pos','u','Fpto','pow'};
            
            for ii = 1:length(fns)
                ax(ii) = subplot(length(fns), 1, ii);
                hold on
                grid on
            end
            
            for jj = 1:length(obj)
                
                for ii = 1:length(fns)
                    timeRes.(fns{ii}) = getTimeRes(obj(jj),fns{ii}, t);
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
            
            trep = obj(1).getRepeatPer();
            t = linspace(0,trep,1e3);
            
            for ii = 1:length(obj)
            
                pow_avg(ii) = sum(real(obj(ii).pow));
                
                pow_t = getTimeRes(obj(ii), 'pow', t);
                pow_max(ii) = max(abs(pow_t));
                pow_thd(ii) = thd(pow_t);
                
                pos_t = getTimeRes(obj(ii), 'pos', t);
                pos_max(ii) = max(abs(pos_t));
                
                vel_t = getTimeRes(obj(ii), 'u', t);
                vel_max(ii) = max(abs(vel_t));
                
                Fpto_t = getTimeRes(obj(ii), 'Fpto', t);
                Fpto_max(ii) = max(abs(Fpto_t));
            end
            
            % augment names if they are the same
            if any(strcmp(obj(1).name, {obj(2:end).name}))
                for ii = 1:length(obj)
                    rnames{ii} = [obj(ii).name, '_', num2str(ii)];
                end
            else
                rnames = {obj.name};
            end
            rnames = reshape(rnames,[],1);
            
            T = table(pow_avg(:),pow_max(:),pow_thd(:),pos_max(:),...
                vel_max(:),Fpto_max(:),...
                'VariableNames',...
                {'AvgPow','|MaxPow|','PowTHD_dBc','MaxPos','MaxVel','MaxPTO'},...
                'RowNames',...
                rnames);
            % TODO add more columns
            
        end
        
    end
    
    methods (Access=protected)
        function [tRep] = getRepeatPer(obj)
            tRep = 2*pi/(obj.w(2) - obj.w(1));
        end
        
        function [timeRes] = getTimeRes(obj, fn, t_vec)
            
            if strcmp(fn,'pow')
                vel = obj.getTimeRes('u',t_vec);
                f = obj.getTimeRes('Fpto',t_vec);
                timeRes = vel .* f;
            else
                timeRes = zeros(size(t_vec));
                for ii = 1:length(obj.w) % for each freq. TODO - use IFFT
                    timeRes = timeRes ...
                        + real(obj.(fn)(ii) * exp(1i * obj.w(ii) * t_vec));
                end
            end
        end
    end
end
