function [data, target, rx, modData] = getDVBSdata(M, samples, nb, EbNo, backOff)
%generate a sequence of DVBS modulated bits
%apply windowing over the bits to create a matrix

awgnChan = comm.AWGNChannel('BitsPerSymbol', 4, 'EbNo', EbNo); %create awgn channel object
txfilter = comm.RaisedCosineTransmitFilter(); %tx srrc
rxfilter = comm.RaisedCosineReceiveFilter(); %rx srrc
LO = dsp.SineWave("Frequency", 1.5e9, "ComplexOutput", true, "SampleRate", (1e-6)/8, "SamplesPerFrame", 8*nb); 
y = LO();

if backOff == 1
    GindB = -1.626571802255640;
    GoutdB = 3.911826101838731;
elseif backOff == 7
    GindB = -7.626571802255640;
    GoutdB = 9.911826101838731;
else 
   GindB = -30.626571802255640;
   GoutdB = 32.911826101838731;
end 

%saleh = comm.MemorylessNonlinearity('Method', 'Saleh model', 'AMAMParameters', [2.1587, 1.1517], "AMPMParameters", [4.0033, 9.1040],'InputScaling', GindB , 'OutputScaling', GoutdB);
%agc = comm.AGC("AveragingLength", 256);

rng(0); %repeatability
msg = randi([0 (M - 1)],nb,1); %create a sequence of random integers of size nbx1
modData = dvbsapskmod(msg,M, 's2x', '2/3'); %modulate data, DVBS2X
%HPAOut = saleh(modData); %power amplifier
txfilterData = txfilter(modData); %SRRC filter
txData = txfilterData.*y; %upconvert

%channel impairments - noise
txData = awgnChan(txData);

rxData = txData.*conj(y); %down convert
rx = rxfilter(rxData); %SRRC filter
%rx = agc(rx); %gain control 

%account for delay from filter 
delay = txfilter.FilterSpanInSymbols;
rx = rx(delay+1:end); 
modData = modData(1:end-delay); 

%window signal
data = window(rx, samples); %NN input, noisy signal
target = round([real(modData), imag(modData)]', 5); %labels

end 
