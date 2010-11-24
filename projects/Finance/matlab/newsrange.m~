function data = newsrange(search,startdate,enddate)
%eg:  http://news.google.com/archivesearch?...
%    as_q=apple&...                          %search term
%    num=100&hl=en&btnG=Search+Archives&as_epq=&as_oq=&as_eq=&ned=us&...
%    as_user_ldate=12/01/2008&...            %start data
%    as_user_hdate=12/31/2008&...            %end date
%    lr=&as_src=&as_price=p0&as_scoring=a    %....

%startdate & enddate should be input in the format:
%mm/dd/yyyy

url = ['http://news.google.com/archivesearch?',...
        'as_q=',search,'&',...                          %search term
        'num=100&hl=en&btnG=Search+Archives&as_epq=&as_oq=&as_eq=&ned=us&',...
        'as_user_ldate=',startdate,'&',...            %start data
        'as_user_hdate=',enddate,'&',...            %end date
        'lr=&as_src=&as_price=p0&as_scoring=a' ];  
str = urlread(url);
data = googlenewsread(str);

related = cell(length(data.links),1);
for i = 1: length(data.links)
   disp(i);
   url = data.links{i};
   if length(url) ~= 0
        str = urlread(url);
   end
  
   related{i} =googlenewsread(str);
end
data.related = related;
display = 1;
if display
    for i = 1:length(data.headlines)
        disp([sprintf('%d ',data.n_related(i)),data.headlines{i}]);
    end
end

