function data = stockread(name)
%data = stockread(name)
%input: stock name. eg: 'aapl'
%
%only yahoo tickers are implemented as yet.

type =0;

%yahoo historical reading:
if type == 0
    %default settings
    if ~exist('name','var'),name ='aapl';end
    
    if ~exist('startmonth','var'), startmonth = 1; end
    if ~exist('startday','var'),startday=1;end
    if ~exist('startyear','var'),startyear=1930;end
    if ~exist('endmonth','var'),endmonth=12;end
    if ~exist('endday','var'),endday=365;end
    if ~exist('endyear','var'),endyear=2008;end
    if ~exist('frequency','var'),frequency = 'd'; end
    
    
    startmonth=sprintf('%1.2i',startmonth);
    startday=sprintf('%1.3i',startday);
    startyear=sprintf('%1.4i',startyear);
    endmonth=sprintf('%1.2i',endmonth);
    endday=sprintf('%1.3i',endday);
    endyear=sprintf('%1.4i',endyear);
    
    
    
    url ='http://ichart.finance.yahoo.com/table.csv?';
    url =[url,'s=',name,'&a=',startmonth,'&b=',startday,'&c=',startyear,...
            '&d=',endmonth,'&e=',endday,'&f=',endyear,'&g=',frequency];
    str = urlread(url);
    lines = regexp(str,'[^\n]*\n','match');
    
    years = zeros(length(lines)-1,1);
    months= zeros(length(lines)-1,1);
    days = zeros(length(lines)-1,1);
    net_days = zeros(length(lines)-1,1);
    
    open = zeros(length(lines)-1,1);
    high = zeros(length(lines)-1,1);
    low = zeros(length(lines)-1,1);
    close = zeros(length(lines)-1,1);
    volume = zeros(length(lines)-1,1);
    adj_close = zeros(length(lines)-1,1);
    
    tokens = regexp(lines,'([^,]*)','tokens');
    
    for i = 2:length(tokens)
        j = i-1;
        cur = tokens{i};
        dstring = cur{1};
        ts = regexp(dstring,'([^-]*)','tokens');
        ts = ts{1};
        years(j) = str2double(ts{1});
        months(j) = str2double(ts{2});
        days(j) = str2double(ts{3});
        
        open(j) =str2double(cur{2});
        high(j) =str2double(cur{3});
        low(j) =str2double(cur{4});
        close(j) =str2double(cur{5});
        volume(j) =str2double(cur{6});
        adj_close(j) =str2double(cur{7});

    end
    data.name = name;
    data.years = years;
    data.months = months;
    data.days = days;
    data.open = open;
    data.high = high;
    data.low = low;
    data.close = close;
    data.volume = volume;
    data.adj_close = adj_close;
    
end