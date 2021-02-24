%% Clear Workspace
clc
clear
close all

%% Import data

fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_05.csv';
% fileB = '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_06.csv';

% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_10.csv';
% fileB = '1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_11.csv';

% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_23.csv';
% fileB = '1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_24.csv';

% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_30.csv';
% fileB = '1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_31.csv';

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

%% Start loop for all subcarriers
%% Unwrapped Phase
sub = 8; % subcarrier
Bpha_uw = unwrap(angle(Bcsi(:,sub)));
figure;
labelArr(sub) = "ch"+(sub-1);
plot(Bt, Bpha_uw, 'k','LineWidth',1);
grid on
set(gca,'FontSize',12,'Color',[245, 245, 245]/255);
set(gca, 'Xtick', 0:5:60)

%% Compute EMD and obtain IMF
[imf, residual, info] = emd(Bpha_uw);
% emd(Bpha_uw)

%% Calculate the power of each IMF [eq. 10] **optional**
% power = (1/size(imf, 1)) .* sum(imf.^2, 1);

%% Identify the "coarse" reconstruction index K' [eq. 11] **optional**
% [~, k_prime] = max(power);

%% Calculate Mutual Information MI(k) [eq. 8]
MI = zeros(size(imf,2)-1,1);
Xr = zeros(size(imf,1),1); % deterministic component (respiratory)
Xn = zeros(size(imf,1),1); % stochastic component (noise)

% Via Fast MI function
for idx = 1:size(MI,1)
    K_temp = idx + 1;
    figure;
    plot(Bt, Bpha_uw, 'g');
    grid on;
    Xr = sum(imf(:, (K_temp:size(imf,2))), 2)+residual; % add imfs k through m
    Xn = sum(imf(:, (1:K_temp-1)), 2)+residual; % add imfs 1 through k-1
    hold on;
    plot(Bt,Xr, 'r'); 
    MI(idx) = mi(Xr,Xn); % Fast MI
end


% Via Naive Equidistant Binning Estimator (ED)
% for idx = 1:size(MI,1)-1
%     K_temp = idx + 1;
%     Xr = sum(imf(:, (K_temp:size(imf,2))), 2); % add imfs k through m
%     Xn = sum(imf(:, (1:K_temp-1)), 2); % add imfs 1 through k-1
%     
%     XrXn_jp = 0; % joint probability
%     Xr_mp = 0; % marginal probability of respiratory 
%     Xn_mp = 0; % marginal probability of noise
%     
%     MI(idx) = sum(XrXn_jp*log(XrXn_jp/(Xr_mp*Xn_mp)), 'all');
%     
% end

% Via Adaptive Partioning (AD)? will look into later

%% Calculate Mutual Information Ratio MIR(k) [eq. 9]
MIR = zeros(size(MI,1)-1,1);
for idx = 1:size(MI,1)-1
%     K_temp = idx + 1;
    MIR(idx) = MI(idx+1) / MI(idx);
end

%% Find optimal K value (w/ highest MIR)
[~, K_optim] = max(MIR);
K_optim = K_optim+1;

%% Reconstruct the filtered signal [eq. 6]
signal = sum(imf(:, (K_optim:size(imf,2))), 2)+residual;

%% Plot the Reconstructed Signal
figure;
plot(Bt, signal);
grid on
set(gca, 'Xtick', 0:5:60)

%% Compute Periodicity (verify formula is correct)
periodicity = max(pwelch(signal)) / mean(pwelch(signal));

%% Compute Sensitivity (verify formula is correct)
sensitivity = sum((signal - mean(signal)).^2 / length(signal));

%% End loop for all subcarriers
%% Output P and S for each subcarrier








