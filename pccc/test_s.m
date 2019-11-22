function b = test_s(x,S,last_only)

if (last_only)
   k = length(x);
   for l = -S:-1;
      if ((k+l) >= 1)
         d = x(k) - x(k+l);
         if (abs(d) < S)
            b = 0;
            display([num2str(k),':',num2str(x(k)),' vs ',num2str(k+l),':',num2str(x(k+l)),' is distance ',num2str(d),' at offset ',num2str(l)]);
            return;
         end
      end
   end
else
   l_range = [-S:-1 1:S];
   K = length(x);
   for k=1:K
      for l=l_range
         if (((k+l) >= 1) && ((k+l) <= K))
            d = x(k) - x(k+l);
            if (abs(d) < S)
               b = 0;
               display([num2str(k),':',num2str(x(k)),' vs ',num2str(k+l),':',num2str(x(k+l)),' is distance ',num2str(d),' at offset ',num2str(l)]);
               return;
            end
         end
      end
   end
end

b = 1;
return;
