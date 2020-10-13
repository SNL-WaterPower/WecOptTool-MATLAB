classdef Performance < handle
    
    properties
        w (:,:) double {mustBeFinite,mustBeReal,mustBePositive}
        ph (:,:) double {mustBeFinite,mustBeReal}
        eta (:,:) double {mustBeFinite}
        F0 (:,:) double {mustBeFinite}
        u (:,:) double {mustBeFinite}
        pos (:,:) double {mustBeFinite}
        Zpto (:,:) double {}
        Fpto (:,:) double {mustBeFinite}
        pow (:,:) double {mustBeFinite}
        name (1,:) char = 'tmp'
        date (1,1) double {mustBeFinite,mustBePositive} = now
    end
    
    methods
        
        function plotTime(obj ,t)
            
            if nargin < 2
                trep = obj(1).getRepeatPer();
                t = 0:0.05:trep;
            end
            
            fig = figure('Name','Performance.plotTime');
            fig.Position = fig.Position.*[1 1 1 1.5];
            
            % fields for plotting
            fns = {'eta','F0','pos','u','Fpto','pow'};
            
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
            
            if length(obj) > 1
                legend(ax(1),{obj.name})
            end 
            
        end
        
        function plotFreq(obj,fig)
            
            if nargin < 2 || isempty(fig)
                fig = figure;
            end
            set(fig,'Name','Performance.plotFreq');
            
            fns = {'F0','u','Fpto'};
            mrks = {'o','.','+','s'};
            
            n = length(obj);
            for jj = 1:n
                for ii = 1:length(fns)
                    
                    fv = obj(jj).(fns{ii})(:,1); % use the first column if this is PS
                    
                    % mag plot
                    ax(jj,1) = subplot(2,n,sub2ind([n,2],jj,1));
                    title(obj(jj).name,'interpreter','none')
                    hold on
                    grid on
                    
                    stem(ax(jj,1),obj(jj).w, mag2db(abs(fv))...
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
        
        function T = summary(obj)
            
            if length(obj) > 1
                for ii = 1:length(obj)
                    Tr(ii,:) = summary(obj(ii));
                end
                
                % augment names if they are the same
                if any(strcmp(obj(1).name, {obj(2:end).name}))
                    for ii = 1:length(obj)
                        rnames{ii} = [obj(ii).name, '_', num2str(ii)];
                    end
                else
                    rnames = {obj.name};
                end
                
                Tr.Properties.RowNames = rnames;
                mT = Tr;
                
                if nargout
                    T = mT;
                else
                    disp(mT)
                end
                
                return
                
            else
                rnames = {obj.name};
            end
            
            trep = obj.getRepeatPer();
            t = linspace(0,trep,1e3);

            for jj = 1:size(obj.ph,2) % for each phase in PS cases

                tmp.pow_avg(jj) = sum(real(obj.pow(:,jj)));

                pow_t = getTimeRes(obj, 'pow', t, jj);
                tmp.pow_max(jj) = max(abs(pow_t));

                try
                    tmp.pow_thd(jj) = thd(pow_t);
                catch ME
                    warning(ME.message)
                    tmp.pow_thd(jj) = NaN;
                end

                pos_t = getTimeRes(obj, 'pos', t, jj);
                tmp.pos_max(jj) = max(abs(pos_t));

                vel_t = getTimeRes(obj, 'u', t, jj);
                tmp.vel_max(jj) = max(abs(vel_t));

                Fpto_t = getTimeRes(obj, 'Fpto', t, jj);
                tmp.Fpto_max(jj) = max(abs(Fpto_t));
            end

            fn = fieldnames(tmp);
            for kk = 1:length(fn)
                out.(fn{kk}) = mean(tmp.(fn{kk}), 2);
            end
                
            rnames = reshape(rnames,[],1);
            
            mT = table(out.pow_avg(:),out.pow_max(:),out.pow_thd(:),...
                out.pos_max(:),out.vel_max(:),out.Fpto_max(:),...
                'VariableNames',...
                {'AvgPow','|MaxPow|','PowTHD_dBc','MaxPos','MaxVel','MaxPTO'},...
                'RowNames',rnames);
            
            if nargout
                T = mT;
            else
                disp(mT)
            end
            
        end
        
    end
    
    methods (Access=protected)
        
        function [tRep] = getRepeatPer(obj)
            tRep = 2*pi/(obj.w(2) - obj.w(1));
        end
        
        function [timeRes] = getTimeRes(obj, fn, t_vec, ph_idx)
            if nargin < 4
                ph_idx = 1;
            end
            
            if strcmp(fn,'pow')
                vel = obj.getTimeRes('u',t_vec);
                f = obj.getTimeRes('Fpto',t_vec);
                timeRes = vel .* f;
            else
                timeRes = zeros(size(t_vec));
                fv = obj.(fn)(:,ph_idx); % use the first column if this is PS
                for ii = 1:length(obj.w) % for each freq. TODO - use IFFT
                    timeRes = timeRes ...
                        + real(fv(ii) * exp(1i * obj.w(ii) * t_vec));
                end
            end
        end
        
%         function checkSizes(varargin) % TODO
%             n = length(varargin);
%             for ii = 1:n
%                 if ~isequal(varargin(varargin{ii}),size(varargin{1}))
%                     error('Frequency vectors must have same size')
%                 end
%             end
%         end
        
    end
end

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
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public
%     License along with WecOptTool.  If not, see
%     <https://www.gnu.org/licenses/>.
