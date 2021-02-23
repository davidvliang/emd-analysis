%% Clear Workspace
clc
clear
close all

%% Import data

% fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_05.csv';
fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_06.csv';

% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_10.csv'
% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_11.csv'

% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_23.csv'
% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_24.csv'

% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_30.csv'
% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_31dd.csv'


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

%% Unwrapped Phase

sub = 1; % subcarrier
Bpha_uw = unwrap(angle(Bcsi(:,sub)));
figure;
labelArr(sub) = "ch"+(sub-1);
plot(Bt, Bpha_uw, 'k','LineWidth',1);
grid on
set(gca,'FontSize',12,'Color',[245, 245, 245]/255);

%% Compute EMD and obtain IMF
[imf, residual, info] = emd(Bpha_uw);

%% Find optimal K value (with highest mutual information ratio)
mir = 0;
for k_idx = 2:size(imf, 2)-1
    temp_mir = mutual_info(k_idx+1, imf) / mutual_info(k_idx, imf);
    if (temp_mir > mir)
        mir = temp_mir;
        k_optim = k_idx;
    end 
end
k_optim = 4;

%% Use optimal K to find filtered signal
signal = zeros(size(imf(:,1)));
for idx = k_optim:size(imf,2)
    signal = signal + imf(:, idx);

end

%% 
figure;
plot(Bt, signal);


%% Compute Periodicity 
periodicity = max(pwelch(signal)) / mean(pwelch(signal));


%% Compute Sensitivity
sensitivity = sum((signal - mean(signal)).^2 / length(signal));


%% repeats for all subcarriers







