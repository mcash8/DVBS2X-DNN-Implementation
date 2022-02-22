%Generate testing data, similar to above code but only one sequence of
%integers are generated. 
 
awgnChan = comm.AWGNChannel('BitsPerSymbol', 4, 'EbNo', 10); %create awgn channel object
M=16;
window = 4;
for nb = [5000, 10000, 50000]
    msg = randi([0 sum(M)-1], nb, 1);
    symbols = dvbsapskmod(msg, M, 's2x'); 
    txfilterData = txfilter(symbols); 
    txData = txfilterData.*y; %upconvert
    txData = awgnChan(txData);
    
    rxData = txData.*conj(y); %down convert
    rx = rxfilter(rxData); %SRRC filter
    
    %constDiagram([symbols, rx]); 
    
    d = finddelay(symbols, rx); %need to remove delay before windowing
    rx = rx((d+1):end); %get rid of filter delay 
    symbols = symbols(1:(end-d));
    
    train_data = makeInputMat(rx,window);
    train_data = train_data(:,1:end-window);
    symbols = symbols(1+window:end);
    target = round([real(symbols) imag(symbols)],5)';
    
    train_data = train_data'; 
    
    filename_test = 'DVBSAPSK_pred_SRRC_10k'; 
    save(filename_test, 'train_data', 'target'); 
end 
