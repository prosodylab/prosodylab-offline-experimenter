function [counts, uns] = test(ids)
uns= unique(ids);
counts = arrayfun(@(x)sum(ids == x), uns);

end


