function out = googlenewsread(str)

[splits] = regexp(str,'<tr><td><a[^>]*>','split');

headlines = cell(length(splits) -1,1);
n_related = zeros(length(splits) -1, 1);
links = headlines;
for j= 2:length(splits)
    i = j - 1;
    sub=splits{j};
    headsub = regexp(sub,'</a','split');
    title = headsub{1};
    title = regexprep(title,'<[^<]*>','');
    title = regexprep(title,'&[^a-zA-Z]*;','');
    title = regexprep(title,'[^a-zA-Z0-9 ]','');    
    headlines{i} =title;
    tokens = regexp(headsub,'<a[^=]*=([^>]*)>.*All([^a-zA-Z]*)related','tokens'); 
    
    rel_idx = 0;
    for k = 1:length(tokens)
        if length(tokens{k})~=0
            rel_idx = k;
            break;
        end
    end
    
   
    if rel_idx == 0
        link = '';
        n_rel=0;
    else
        t = tokens{rel_idx};
        t = t{1};
        link  =t{1};
        link = ['http://news.google.com',link];
        n_rel =str2double(t{2});
    end
    
    n_related(i) = n_rel;
    links{i} = link;    
end

out.links = links;
out.n_related = n_related;
out.headlines = headlines;
