function covid = pullgitdata(type)

%OUTPUT:
%covid structure (all variables same length):
%covid.country: cell
%covid.state: cell
%covid.type: cell (type = input type)
%covid.numcases
%covid.datenum

%INPUT:
%type: type of statistic to pull: either Confirmed, Deaths, Recovered (MUST
%BE CASE SENSITIVE)

% %delete previous directory
% rmdir COVID-19 s
% 
% %clone repository from git- JHU data stream (using system command)
% %Link to data: https://github.com/CSSEGISandData/COVID-19
% !git clone https://github.com/CSSEGISandData/COVID-19

%relative path to file- name depends on type
csvfile = ['COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-',type,'.csv'];
fid = fopen(csvfile);

%pulling header, reading dates
header = fgetl(fid);
header = strsplit(header,',');
d_off = 5;
for d = d_off:length(header)
    dates(d-d_off+1) = datenum(header{d},'mm/dd/yy'); %#ok<AGROW>
end

%pulling information for each country
i = 0;
while ~feof(fid)
    
    %read line, split by commas
    line = fgetl(fid);
    line = strsplit(line,',');
    
    %some country/state names have commas in them (surrounded by quotes)
    coff = 0;
    curstate = line{1};
    if ~isempty(line{1}) %because state field might be empty
        if strcmp(line{1}(1),'"') && strcmp(line{2}(end),'"')
            coff = coff + 1;
            curstate = [line{1}(2:end),', ',line{2}(1:end-1)];
        end
    end
    
    if strcmp(line{2+coff}(1),'"') && strcmp(line{3+coff}(end),'"')
        curcountry = [line{2+coff}(2:end),', ',line{3+coff}(1:end-1)];
        coff = coff + 1; %set offset AFTER pulling by index
    else
        curcountry = line{2+coff};
    end
    
    if isempty(curstate)
        curstate = '';
    end
    
    %correcting for certain countries to match previously used templates
    switch(curcountry)
        case 'Korea, South'
            curcountry = 'South Korea';
    end
    
    for d = d_off:length(dates)
        i = i + 1;
        covid.country{i} = curcountry;
        covid.state{i} = curstate;
        covid.datenum(i) = dates(d-d_off+1);
        covid.numcases(i) = str2double(line{d+coff});
        covid.type{i} = type;
    end
end