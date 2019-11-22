clear all;

% Step 1
LTCinp = 12282;
n = 9;

% Step 2
INadr = 0:(2^(n+5)-1); %initialization of decadic addresses
INbinAll = dec2bin(INadr, (n+5)); %decadic to binary conversion for next step

% Step 3
nMSBs = INbinAll(:,1:n); %extract n MSB bits
nMSBdec = bin2dec(nMSBs); %binary to decadic conversion
nMSBdec1 = nMSBdec+1; %add one to form a new value
nMSBbin1 = dec2bin(nMSBdec1); %decadic to binary conversion
[~,b] = size(nMSBbin1); %obtaining the number of bits in word
nMSBbin1 = nMSBbin1(:,(b-n+1):end); %obtaining the n least significant bits

% Step 4
look_up = [13 335 87 15 15 1 333 11 13 1 121 155 1 175 421 5 509 215 47 425 295 229 427 83 409 387 193 57 501 313 489 391];
LSBs5 = INbinAll(:,(n+1):end); %5 LSBs bits
LSBdec = bin2dec(LSBs5); %binary to decadic conversion
for indx = 1:(2^(n+5))
   look_out(indx,1) = look_up((LSBdec(indx)+1));%n bit output of the look up table
end

% Step 5
nMSB1dec = bin2dec(nMSBbin1); %binary to decadic conversion
multiply = nMSB1dec .* look_out; %1by1 multiplication
muliplyBin = dec2bin(multiply); %decadic to binary conversion
[~,b] = size(muliplyBin);
LSBsn = muliplyBin(:,(b-n+1):end); %obtaining the n least significant bits

% Step 6
reverse = [5 4 3 2 1];
LSBs5reverse = LSBs5(:,reverse);

% Step 7
tentAdr = [LSBs5reverse,LSBsn]; %forming the tentative addresses
tentOutAdr = bin2dec(tentAdr); %binary to decadic conversion

% Step 8
indxx = 1;
for indx = 1:(2^(n+5))
   if tentOutAdr(indx) < LTCinp %accept addresses < LTCinp
      IntOutAdr(indxx) = tentOutAdr(indx); %interleaver output addresses
      indxx = indxx + 1; %addresses in the range 0:12281
   end
end
