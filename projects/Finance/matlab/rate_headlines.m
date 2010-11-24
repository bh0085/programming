function rate_headlines(strings)
filename = '/Users/bh0085/Programming/projects/Finance/matlab/training.mat';

if exist(filename)
    load(filename);
else
    training.evals = [];
    training.strs = {};
end

for i = 1: length(strings);
    str = strings{i};
    disp(str);
    eval= input('Rating?  (1 least, 9 best, 5 neutral)    :');
    training.evals(i) = eval;
    training.strs{i} = str;
    disp(i/length(strings));
end

save(filename, 'training');