function ileave_lut = ileave_dvbsh(Ltc_input)
%clear all;
%close all;

%Ltc_input = 12282;
%Ltc_input = 1146;
%Ltc_input = 1152;

ileave_lut = zeros(Ltc_input,1);
good_addr = 1;

LUT_N9 = [
   13,
   335,
   87,
   15,
   15,
   1,
   333,
   11,
   13,
   1,
   121,
   155,
   1,
   175,
   421,
   5,
   509,
   215,
   47,
   425,
   295,
   229,
   427,
   83,
   409,
   387,
   193,
   57,
   501,
   313,
   489,
   391
];

LUT_N6 = [
   3,
   27,
   15,
   13,
   29,
   5,
   1,
   31,
   3,
   9,
   15,
   31,
   17,
   5,
   39,
   1,
   19,
   27,
   15,
   13,
   45,
   5,
   33,
   15,
   13,
   9,
   15,
   31,
   17,
   5,
   15,
   33
];

% Step 1) Determine N such that Ltc_input < 2^(N+5)
N = ceil(log(Ltc_input)/log(2))-5;

% Step 2) Initialize n+5 bit counter to 0
NP5_MAX = 2^(N+5);
N_MAX = 2^N;
count_np5 = 0;

%for trial = 1:10
while (good_addr <= Ltc_input)
   %display(['Count: ',num2str(count_np5),' Good: ',num2str(good_addr)]);
   % Step 3) Extract the N MSBs and add one, then discard all except the n LSBs
   count_nmsb = floor(count_np5/2^5) + 1;
   count_nmsb_p1_nlsb = mod(count_nmsb,N_MAX);

   % Step 4) Obtain the n-bit output of the lookup table using the 5 LSBs of the counter
   count_5lsb = mod(count_np5,32);
   if (N == 6)
      lut_value = LUT_N6(count_5lsb+1);
   elseif (N == 9)
      lut_value = LUT_N9(count_5lsb+1);
   end

   % Step 5) Multiply the values in step 3 and 4, discard all except the N lsbs
   mult_nlsb = mod(lut_value*count_nmsb_p1_nlsb,N_MAX);

   % Step 6) Bit-reverse the five LSBs of the counter
   count_5lsb_reverse = bin2dec(fliplr(dec2bin(count_5lsb,5)));

   % Step 7) Form a tentative output address that has its MSBs equal to the value obtained in Step 6 and its LSBs equal to the value obtained in Step 5
   tentative_count_np5 = count_5lsb_reverse*N_MAX + mult_nlsb;

   % Step 8)
   if (tentative_count_np5 < Ltc_input)
      ileave_lut(good_addr) = tentative_count_np5;
      good_addr = good_addr+1;
   end

   count_np5 = count_np5 + 1;
end

% Matlab indexing
ileave_lut = ileave_lut + 1;
