clear all
clc

k = 4;    % number of input bits
M = 2^k;  % modulation order

%LNA settings
R = 50; 
gain = 5; 
IIP3 =  20;
P1dB = 10; 
[k1,k3,k5] = calcLNA(gain, IIP3, P1dB);

%dimensions
samples = 4; %window size
nb = 1000; %length of message to generate
nb_pred = 1000; %length of prediction sequence to generate
chunks = 10; %for generating sets of data
val_size = 1000;

%constellation diagram
constDiagram = comm.ConstellationDiagram('SamplesPerSymbol',1, ...
    'SymbolsToDisplaySource','Property','SymbolsToDisplay',100); 

%generate training files 
backOff = 1; 
for No = [-2, 0, 3, 10, 15, 23, 50] %SNR Values, units are dB
%for backOff = [1, 7, 30] %units are dB 
    [x_pred, y_pred, rx_pred, tx_pred] = getDVBSdata(M, samples, nb_pred, No, backOff);  %prediction data, only call once 
    [data, target, rx, tx ] = getDVBSdata(M, samples, nb, No, backOff);  %first set of data
    [data_val, target_val, ~, ~] = getDVBSdata(M, samples, val_size, No, backOff); %validation data
    
    %visually check data
    %figure
    %constDiagram([rx, tx]); 
    
    %create large array for training
    x_train= zeros(size(data,1),size(data,2)*chunks);
    y_train = zeros(size(target,1),size(target,2)*chunks);
    
    tic 
    for iter = 1:chunks
        %saves
        x_train(:,((iter-1)*size(data,2)+1):(iter*size(data,2))) = data;
        y_train(:,((iter-1)*size(target,2)+1):(iter*size(target,2))) = target;
        if iter ~= chunks
            [data, target, ~, ~] = getDVBSdata(M, samples, nb, No, backOff);
        end
    end
    toc

    x_train = x_train'; 
    y_train = y_train'; 

    x_pred = x_pred'; 
    y_pred = y_pred'; 
    
    data_val = data_val'; 
    target_val = target_val'; 

    %save to .mat file - split into two for size reasons
    path = 'C:\Users\Martha Ca$h\Desktop\School\Grad School\Research\Python Code\MAT Files\Data\AWGN Only3\'; 
    foldername = sprintf('SNR%d', No); 
    mkdir([path, foldername, '\']); 
    filename_train = sprintf('Data_SNR%d', No); %filename for saving data
    filename_test = sprintf('Data_SNR%dtest', No); 
    save([path,foldername,'\', filename_train], 'x_train', 'y_train', 'x_pred', 'data_val', 'target_val'); %save workspace 
    save([path,foldername,'\', filename_test],'rx_pred', 'tx_pred'); 
end 

function [k1, k3, k5] = calcLNA(gain, IIP3, P1dB)
R = 50; 
vip3 = sqrt(2*10^((IIP3-30)/10)*R); 
vp1dB = sqrt(2*10^((P1dB-30)/10)*R); 

%specifying polynomical coefficents 
k1 = 10^(gain/10); % linear gain 
k3 = -4/3*(k1/vip3^2); %cubic coefficent
k5 = -(0.10875*k1+(3/4)*(vp1dB^2))*((8/5)*(1/vp1dB^4)); %fifth order coefficent
end
