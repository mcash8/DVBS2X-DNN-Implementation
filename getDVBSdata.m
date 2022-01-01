function [data, target] = getDVBSdata(M, samples, nb, chunks)
%generate a sequence of DVBS modulated bits
%apply windowing over the bits to create a matrix

%awgnChan = comm.AWGNChannel('BitsPerSymbol', 4, 'EbNo', EbNo); %create awgn channel object
txfilter = comm.RaisedCosineTransmitFilter(); %tx srrc
rxfilter = comm.RaisedCosineReceiveFilter(); %rx srrc
LO = dsp.SineWave("Frequency", 1.5e9, "ComplexOutput", true, "SampleRate", (1e-6)/8, "SamplesPerFrame", 8*nb); 
y = LO();

rng(0); %repeatability
data = randi([0 (M - 1)],nb,1); %create a sequence of random integers of size nbx1
modData = dvbsapskmod(data,M, 's2x', '2/3'); %modulate data, DVBS2X
%---add HPA here---
txfilterData = txfilter(modData); %SRRC filter
txData = txfilterData.*y; %upconvert

%channel impairments here

rxData = txData.*conj(y); %down convert
rx = rxfilter(rxData); %SRRC filter
%rx = agc(rx); %uncomment for hpa

data = window(rx, samples); %train data
target = round([real(modData), imag(modData)]', 5); %labels

end 
