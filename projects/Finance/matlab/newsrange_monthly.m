function newsrange_monthly( name, year)

for m = 1:11
    ms = sprintf('%2.2i',m);
    mf = sprintf('%2.2i',m+1);

    yr = sprintf('%2.4i',year);
    start = [ms,'/01/',yr];
    finish = [mf,'/01/',yr];


    news = newsrange(name,start,finish);
    fname = [name,'_',ms,yr];
    save(fname, 'news')
end