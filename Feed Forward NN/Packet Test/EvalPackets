%Evaluation script for packet size test
%DVBS-16APSK
rng(0);
for nb = [5000, 10000, 50000]
    ber = zeros(1,10);
    for i = 1:10
        f_og = sprintf('DVBSAPSK_pred_SRRC_%dpck_%d.mat', [nb,i]); %test sequence, generated above
        f_test = sprintf('DVBSAPSK_pred_%dpck_%d.mat', [nb, i]); %from NN
        
        load(f_og); 
        load(f_test);
        
        constDiagram = comm.ConstellationDiagram('SamplesPerSymbol',1, ...
            'SymbolsToDisplaySource','Property','SymbolsToDisplay',500, ...
            'ChannelNames', {'Ideal', 'NN Output', 'Training Points'});
        
        awgnChan = comm.AWGNChannel('BitsPerSymbol', 4, 'EbNo', 10); %create awgn channel object
        
        pred = complex(pred(:,1), pred(:, 2));
        target = target';
        target_cp= complex(target(:,1), target(:, 2));
        
        j = nb-14;
        M=16; 
        msg = randi([0 15], j, 1);
        symbols = dvbsapskmod(msg, M, 's2x'); 
        noisySig = awgnChan(symbols); 
        
        %constDiagram([target_cp, pred, noisySig]); 
        
        %BER
        demodData_NN = dvbsapskdemod(pred, M, 's2x'); 
        demodData_ideal = dvbsapskdemod(target_cp, M, 's2x');
        
        demodData_NN = cast(demodData_NN,'like',demodData_ideal); %matching type
        
        %calculate BER
        data_bit = int2bit(demodData_ideal, 4); %convert to bit
        output_bit = int2bit(demodData_NN, 4);%convert to bit
        
        d = finddelay(data_bit,output_bit); 
        errorRate = comm.ErrorRate('ReceiveDelay', abs(d));
        err = errorRate(data_bit, output_bit); %get bit error
        ber(i)= err(1)*100;
    end
   mean(ber)
end 
