clear all;
close all;

M = 6;
n = 2^M-1;
k = 57;
t = bchnumerr(n,k);

EbNo = [0:1:6];            % Eb/No values to loop over
maxNumBlkErrs = 50;          % maximum number of errors per Eb/No value
maxNumBlks = 1e6;          % maximum number of blocks per Eb/No value
rng(1234);


chan = comm.AWGNChannel('NoiseMethod', 'Variance', 'Variance', 1);
BER = comm.ErrorRate('ResetInputPort',true);

ber = zeros(length(EbNo),1);
numBlks = ber;
numBitErrs = ber;
numBlkErrs = ber;
bler = ber;
R = k/n;

for ebNoIdx = 1:length(EbNo)
    disp(['Processing EbNo = ' num2str(EbNo(ebNoIdx))]);
    noiseVar = 1./(2*R*10.^(EbNo(ebNoIdx)/10));
    chan.Variance = noiseVar;

    while (numBlkErrs(ebNoIdx) < maxNumBlkErrs && numBlks(ebNoIdx) < maxNumBlks)
        data = gf(randi([0 1], 1, k));
        s = bchenc(data,n,k);

        r = chan(1-2*double(s.x));
        r_hard = gf(r < 0); 
        decData = bchdec(r_hard,n,k);

        berTemp = BER(transpose(data.x), transpose(decData.x), 1);
        numBitErrs(ebNoIdx) = numBitErrs(ebNoIdx) + berTemp(2);
        if (berTemp(2) > 0)
            numBlkErrs(ebNoIdx) = numBlkErrs(ebNoIdx) + 1;
        end
        numBlks(ebNoIdx) = numBlks(ebNoIdx) + 1;
        display(['EbNo: ',num2str(EbNo(ebNoIdx)),' numBlks: ',num2str(numBlks(ebNoIdx)),' numBlkErrs: ',num2str(numBlkErrs(ebNoIdx)),' numBitErrs: ',num2str(numBitErrs(ebNoIdx)),' BLER: ',num2str(numBlkErrs(ebNoIdx)/numBlks(ebNoIdx)),' BER: ',num2str(numBitErrs(ebNoIdx)/(numBlks(ebNoIdx)*k))]);
    end

    ber(ebNoIdx) = numBitErrs(ebNoIdx)/(k*numBlks(ebNoIdx));
    bler(ebNoIdx) = numBlkErrs(ebNoIdx)/(numBlks(ebNoIdx));
end

berub = bercoding(EbNo,'block','hard',n,k,2*t+1);

figure; semilogy(EbNo, ber, '*-'); hold on;
plot(EbNo,berub,'k');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BER'); title('RS Coding');
axis([-0.5 4.5 9e-10 1]);
legend(['K = ' num2str(k)],'Theory');

figure; semilogy(EbNo, bler, '*-');
grid on; xlabel('E_b/N_0 (dB)'); ylabel('BLER'); title('RS Coding');
axis([-0.5 4.5 9e-10 1]);
legend(['K = ' num2str(k)]);
