%test if generating one long sequence is equivalent to generating m packets that sum to 
%length of long sequence

%parameters
k = 4;
M = 16; 
ni_long = 1e6; 
packets = 10; 
ni_pack = ni_long/packets;
stdSuffix = 's2x';

awgnchan = comm.AWGNChannel('EbNo', -2, 'BitsPerSymbol', 4);

%generate long sequence and modulate
x = randi([0 M-1],ni_long,1);               %size ni_long x 1
y = dvbsapskmod(x,M,stdSuffix);

%add noise
y_out = awgnchan(y); 

%demod 
z = dvbsapskdemod(y_out,M,stdSuffix);

data_bit = int2bit(x, k); %convert to bit
output_bit = int2bit(z, k);%convert to bit
d = finddelay(data_bit,output_bit); %delay
errorRate = comm.ErrorRate('ReceiveDelay', d);

err = errorRate(data_bit, output_bit); %get bit error
bit_err = err(1)*100

%packet generation
ber_pack = zeros(1,packets); 

for i = 1:packets
    x = randi([0 M-1], ni_pack, 1); 
    y = dvbsapskmod(x,M,stdSuffix);

    %add noise
    y_out = awgnchan(y); 
    
    %demod 
    z = dvbsapskdemod(y_out,M,stdSuffix);
    
    data_bit = int2bit(x, k); %convert to bit
    output_bit = int2bit(z, k);%convert to bit
    d = finddelay(data_bit,output_bit); %delay
    errorRate = comm.ErrorRate('ReceiveDelay', d);
    
    err = errorRate(data_bit, output_bit); %get bit error
    ber_pack(i)= err(1)*100;
end 

ber_short = mean(ber_pack)
