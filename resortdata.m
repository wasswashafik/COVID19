function [allcountries,databycountry] = resortdata(covid)

allcountries = unique(covid.country);

for i = 1:length(allcountries)
    ind = strcmp(covid.country,allcountries{i}) & strcmpi(covid.type,'confirmed');
    
    curdates = unique(covid.datenum(ind));
    curcases = zeros(1,length(curdates));
    currentcountrycases = covid.numcases(ind);
    currentcountrydates = covid.datenum(ind);
%     curinds = find(ind);
    for c = 1:length(curdates)
        curcases(c) = nansum(currentcountrycases(currentcountrydates == curdates(c)));
    end
    
    databycountry{i}.country = allcountries{i}; %#ok<*AGROW>
    databycountry{i}.cases = curcases;
    databycountry{i}.dates = curdates;

end