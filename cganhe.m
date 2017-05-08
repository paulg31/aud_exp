function data = cganhe(data,iBlock,num_trials)
for ii = 1:num_trials
    if data.mat{iBlock}(ii,2) == data.mat{iBlock}(ii,4)
        data.mat{iBlock}(ii,5) = 1;
    else
        data.mat{iBlock}(ii,5) = 0;
    end
end
end