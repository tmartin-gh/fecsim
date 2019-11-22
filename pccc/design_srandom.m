clear all;
close all;

SEED_START = 1234;
S = 14;
K = 1032;
ATTEMPTS_UNTIL_FAIL = K*4;


seed = SEED_START;
done = 0;
while (done == 0)
   rng(seed);
   attempt = 0;
   x = transpose(1:K);
   y = zeros(K,1);
   idx = 1;
   K_remain = K;
   while ((idx <= K) && (attempt < ATTEMPTS_UNTIL_FAIL))
      c = randi(K_remain);
      xc = x(c);
      y(idx) = xc;
      if (test_s(y(1:idx),S,1))
         idx = idx + 1;
         K_remain = K_remain - 1;
         x = [x(1:c-1); x(c+1:end)];
         attempt = 0;
      else
         attempt = attempt + 1;
      end
   end
   if (idx == K+1)
      display(['Success for seed ',num2str(seed)]);
      done = 1;
   else
      display(['Failure for seed ',num2str(seed)]);
      seed = seed + 1;
   end
end
