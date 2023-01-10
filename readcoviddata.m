function covid = readcoviddata(filename)

fid = fopen(filename);
fgetl(fid); %ignore header line


%reading each line in file
i = 0;
while ~feof(fid)
    i = i + 1;
    line = fgetl(fid);
    line = strsplit(line,',');
    
    %correcting for S Korea
    %line{1} = line{1}(2:end-1);
    if strcmpi(line{1},'"Korea')
        line{1} = 'South Korea';
    end
    
    covid.datestr{i} = line{1};
    covid.country{i} = line{2};
    covid.state{i} = line{3};
    covid.type{i} = line{4};
    covid.numcases(i) = str2double(line{5});
    covid.datenum(i) = datenum(covid.datestr{i},'mm/dd/yyyy');
end

fclose(fid);