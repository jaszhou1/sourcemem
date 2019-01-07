

It takes a big p vector 
[a1a, a2a, a1b, a2b, eta1a, eta2a, eta1b, eta2b, a, ter]

... split split split data into a and b
    
par_a = P([1, 2, 5, 6, 9, 10])
par_b = P([3, 4, 7, 8, 9, 10])
[ll_a, ~, preds_a] = fitsimpledcircle(par_a, data_a)
[ll_b, ~, preds_b] = fitsimpledcircle(par_b, data_b)

ll = ll_a + ll_b;

preds = {preds_a, preds_b};




%%% The thing I want at the end is...
full_data = open_data(filename)
data = split_data(full_data)
fit_data(data, starting_preds)
plot_data_preds(plot_filename, data, preds)