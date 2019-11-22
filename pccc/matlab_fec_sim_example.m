%% Parallel Concatenated Convolutional Coding: Turbo Codes
%
% MATLAB(R) version of the Turbo coding example.
% Refer to <html/commpccc.html> for system details.

% Notice: Supply of this software does not convey a license nor imply any
% right to use any Turbo codes patents owned by France Telecom,
% Telediffusion de France and/or Groupe des Ecoles des Telecommunications
% except in connection with use of the software for the purposes of design,
% simulation and analysis. Code generated from Turbo codes technology in
% this software is not intended and/or suitable for implementation or
% incorporation in any commercial products.
%
% Please contact France Telecom for information about Turbo Codes Licensing
% program at the following address: France Telecom R&D - PIV/TurboCodes
% 38-40, rue du General Leclerc 92794 Issy-les-Moulineaux Cedex 9, France.

%   Copyright 2010-2016 The MathWorks, Inc.

%% System configuration includes Communications System Object constructions
numIter = 6;               % Number of decoding iterations
%blkLength = 1536;          % Block length
%blkLength = 1146;          % Block length
%blkLength = 12282;
blkLength = 8*129; %256; %8*129;
EbNo = [0.5:0.1:2.0];            % Eb/No values to loop over
maxNumBlkErrs = 50;          % maximum number of errors per Eb/No value
maxNumBlks = 1e6;          % maximum number of blocks per Eb/No value

% Turbo Encoder
%   Internal Interleaver indices

%intrlvrIndices = commExamplePrivate('lteIntrlvrIndices', blkLength);
%intrlvrIndices = ileave_dvbsh(blkLength);

intrlvrIndices = load(['ileave_',num2str(blkLength),'.mat']);
intrlvrIndices = intrlvrIndices.y;

turboEnc = comm.TurboEncoder(...
        'TrellisStructure', poly2trellis(4, [13 15], 13),...
        'InterleaverIndices', intrlvrIndices);

% AWG Noise - with variance to be reset in the processing loop
chan = comm.AWGNChannel('NoiseMethod', 'Variance', 'Variance', 1);

% Turbo Decoder
turboDec  = comm.TurboDecoder(...
         'TrellisStructure', poly2trellis(4, [13 15], 13),...
         'InterleaverIndices', intrlvrIndices, 'NumIterations', numIter);

% BER measurement
BER = comm.ErrorRate('ResetInputPort',true);

%% Processing loop
ber = zeros(length(EbNo),1);
numBlks = ber;
numBitErrs = ber;
numBlkErrs = ber;
bler = ber;
R   = blkLength/(3*blkLength + 3*6);

for ebNoIdx = 1:length(EbNo)

    disp(['Processing EbNo = ' num2str(EbNo(ebNoIdx))]);
    noiseVar = 1./(2*R*10.^(EbNo(ebNoIdx)/10));
    chan.Variance = noiseVar;

    while (numBlkErrs(ebNoIdx) < maxNumBlkErrs && numBlks(ebNoIdx) < maxNumBlks)
        data = randi([0 1], blkLength, 1);
        % Encode random data bits
        yEnc = turboEnc(data);

        % Add noise to real bipolar data
        rData = chan(1-2*yEnc);

        % Convert to log-likelihood ratios for decoding
        llrData = (-2/noiseVar).*rData;

        % Turbo Decode
        decData = turboDec(llrData);

        % Calculate errors - for the final iteration only
        berTemp = BER(data, decData, 1);
        numBitErrs(ebNoIdx) = numBitErrs(ebNoIdx) + berTemp(2);
        if (berTemp(2) > 0)
            numBlkErrs(ebNoIdx) = numBlkErrs(ebNoIdx) + 1;
        end
        numBlks(ebNoIdx) = numBlks(ebNoIdx) + 1;
        display(['EbNo: ',num2str(EbNo(ebNoIdx)),' numBlks: ',num2str(numBlks(ebNoIdx)),' numBlkErrs: ',num2str(numBlkErrs(ebNoIdx)),' numBitErrs: ',num2str(numBitErrs(ebNoIdx)),' BLER: ',num2str(numBlkErrs(ebNoIdx)/numBlks(ebNoIdx)),' BER: ',num2str(numBitErrs(ebNoIdx)/(numBlks(ebNoIdx)*blkLength))]);
    end

    ber(ebNoIdx) = numBitErrs(ebNoIdx)/(blkLength*numBlks(ebNoIdx));
    bler(ebNoIdx) = numBlkErrs(ebNoIdx)/(numBlks(ebNoIdx));
end

%% Display results
figure; semilogy(EbNo, ber, '*-');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER'); title('LTE Turbo-Coding');
axis([-0.5 4.5 9e-10 1]);
legend(['N = ' num2str(blkLength) ', ' num2str(numIter) ' iterations']);

figure; semilogy(EbNo, bler, '*-');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BLER'); title('LTE Turbo-Coding');
axis([-0.5 4.5 9e-10 1]);
legend(['N = ' num2str(blkLength) ', ' num2str(numIter) ' iterations']);

% [EOF]
