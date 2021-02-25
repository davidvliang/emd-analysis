%% Clear Workspace
clc
clear
close all

%% Import data
fileB = {'1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_05.csv'; ...
    '1.1m_2.78m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_06.csv'; ...
	'1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_10.csv'; ...
	'1.1m_2.78m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_11.csv'; ...
	'1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_23.csv'; ...
	'1.1m_2.733m_2mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_24.csv'; ...
	'1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_30.csv'; ...
	'1.1m_2.733m_4mm_28-GHz_1M-IQ/BER_CSI_B_21_02_05_02_31.csv'};

%% Initialize Periodicity and Sensitivity Collections
Pmat = zeros(32, length(fileB));
Smat = zeros(32, length(fileB)); 

%% Start Loop for trials
for tt = 1:length(fileB)
    B = readtable(fileB{tt});

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

    % Init figure
    figure;
    name_str = strrep(fileB{tt},'.csv',''); % Figure Title
    labelArr = strings(32,1); % Init Subplot Titles

    %% Start loop for all subcarriers
    for sub = 1:32
        %% Unwrapped Phase
        Bpha_uw = unwrap(angle(Bcsi(:,sub)));

        %% Compute EMD and obtain IMF
        [imf, residual, info] = emd(Bpha_uw);

        %% Calculate Mutual Information MI(k) via Fast MI function
        MI = zeros(size(imf,2)-1,1);
        Xr = zeros(size(imf,1),1); % deterministic component (respiratory)
        Xn = zeros(size(imf,1),1); % stochastic component (noise)

        for idx = 1:size(MI,1)
            K_temp = idx + 1;
            Xr = sum(imf(:, (K_temp:size(imf,2))), 2)+residual; % add imfs k through m
            Xn = sum(imf(:, (1:K_temp-1)), 2)+residual; % add imfs 1 through k-1
            MI(idx) = mi(Xr,Xn); % Fast MI
        end

        %% Calculate Mutual Information Ratio MIR(k) [eq. 9]
        MIR = zeros(size(MI,1)-1,1);
        for idx = 1:size(MI,1)-1
            MIR(idx) = MI(idx+1) / MI(idx);
        end

        %% Find optimal K value (w/ highest MIR)
        [~, mir_argmax] = max(MIR);
        K_optim = mir_argmax+1;

        %% Reconstruct the filtered signal [eq. 6]
        signal = sum(imf(:, (K_optim:size(imf,2))), 2)+residual;

        %% Compute Periodicity and Sensitivity (verify formulas are correct)
        periodicity = max(pwelch(signal)) / mean(pwelch(signal));
        sensitivity = sum((signal - mean(signal)).^2 / length(signal));

        %% Store P & S in Collection
        Pmat(sub, tt) = periodicity;
        Smat(sub, tt) = sensitivity;

        %% Plot the Reconstructed Signal against Original Signal
        subplot(8,4,sub);
        labelArr(sub) = "ch"+(sub-1)+"  p="+periodicity+"  s="+sensitivity+"  k="+K_optim;
        plot(Bt, Bpha_uw, 'c'); 
        hold on;
        plot(Bt, signal, 'r'); 
        title(labelArr{sub});
        grid on;
        set(gca,'FontSize',12,'Color',[245, 245, 245]/255);
        set(gca, 'Xtick', 0:5:60);
        hold off;

    end % End loop for all subcarriers
    sgtitle(['EMD Filtering for Trial: ', name_str], 'Interpreter', 'None');
    fig = get(groot,'CurrentFigure');
    fig.PaperPositionMode = 'auto';
    fig.Color = [245, 245, 245]/255;
    % fig.Position = get(0, 'Screensize');
    % saveas(fig, ['images/' name_str, '.png'],'png');

end







