clc
clear
close all

%% **** Load Data

fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_05.csv';
% fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_06.csv';

% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_10.csv';
% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_11.csv';

% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_23.csv';
% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_24.csv';

% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_30.csv';
% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_31dd.csv';

B = readtable(fileB);

%% Get RSS, Time, BER, Magnitude, and Phase Data
[Brss, Bt, Bber, Bmag, Bpha] = getInfo2(B);

% convert Bt to relative time
Bt = Bt(:,1) - Bt(1,1); 


%% Get CSI for Data Set c
c = 1;
Bcsi = Bmag .* exp(1i.*Bpha);

for ii = 1:32
    if ii == 32
        Bcsi(:,ii) = 1 ./ Bcsi(:,ii);
    else
        Bcsi(:,ii) = 1 ./ ((Bcsi(:,ii+1)-Bcsi(:,ii))/5 * c + Bcsi(:,ii));
    end
end

%% Initialize Trial Name and Channel Names
% name_str = strrep(fileparts(fileB), './',''); % use dir name as title
name_str = strrep(fileB,'.csv','');
labelArr = strings(32,1);

% %% Plot BER and RSS on Same Figure
% 
% % Plot BER
% figure
% subplot(2,1,1)
% plot(Bt, Bber, 'k','LineWidth',1)
% title('BER')
% ylabel('BER')
% xlabel('Time (s)')
% set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
% grid on
% 
% % Plot RSS 
% subplot(2,1,2)
% plot(Bt, Brss, 'k','LineWidth',1)
% title( 'RSS')
% ylabel('RSS')
% xlabel('Time (s)')
% set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
% grid on
% 
% fig = get(groot,'CurrentFigure');
% fig.PaperPositionMode = 'auto';
% fig.Color = [245, 245, 245]/255;

%% Plot Phase of CSI for Channels 0 to 31

figure
for ii=1:32
    subplot(8,4,ii);
    labelArr(ii) = "ch"+(ii-1);
    plot(Bt, unwrap(angle(Bcsi(:,ii))), 'k','LineWidth',1);
    title(labelArr{ii});
    hold on
    grid on
    set(gca,'FontSize',12,'Color',[245, 245, 245]/255);
    
%     set(gca, 'Xtick', 0:3:30)
%     set(gca, 'Xtick', 0:3:60)
    set(gca, 'Xtick', 0:5:60)
    
end

sgtitle(['Phase of CSI vs. Time (s) for Trial: ', name_str], 'Interpreter', 'None')
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
% fig.Position = get(0, 'Screensize');
% saveas(fig, ['./images/' name_str],'png');

%% Plot Magnitude of CSI for channels 0 to 31

figure
for ii=1:32 
    subplot(8,4,ii);
    labelArr(ii) = "ch"+(ii-1);
    plot(Bt, abs(Bcsi(:,ii)), 'k','LineWidth',1);
    title(labelArr{ii});
    hold on
    grid on
    set(gca,'FontSize',12,'Color',[245, 245, 245]/255);
    
%     set(gca, 'Xtick', 0:3:30)
%     set(gca, 'Xtick', 0:3:60)
    set(gca, 'Xtick', 0:5:60)

end

sgtitle(['Magnitude of CSI vs. Time (s) for Trial: ', name_str], 'Interpreter', 'None')
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;