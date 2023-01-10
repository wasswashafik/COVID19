% bar graph driver

% clearvars
clearvars -except covid allcountries databycountry
close all
clc

%% settings

daysbefore = 0; %days prior to crossing threshold to be included on plot
day0cases = 500; %cases required for a country's day 0

% setting important dates
%Italy, France, Spain, USA
% quarantinestart = [datenum(2020,1,23);datenum(2020,3,9);datenum(2020,3,15);datenum(2020,3,15);NaN];

%Note- solid lines correspond to major efforts (Italy/Spain quarantine
%entire country, France closes all public places other than grocery stores)
% Dashed lines are more minor responses (US declares national emergency,
% Italy quarantines Lombardy, spain cancels all events w/ more than 1000
% people

%% pulling data

% covid = readcoviddata('Spreadsheets/COVID19_18MAR.csv');
% % covid = pullgitdata('Confirmed'); %Confirmed, Recovered, or Deaths
% [allcountries,databycountry] = resortdata(covid);

%% organizing bars

allcountries{1} = 'South Korea';

countries = {'China','Japan','US'};
for c = 1:length(countries)
    index = find(strcmpi(allcountries,countries{c}));
    data.cases{c} = databycountry{index}.cases;
    data.dates{c} = databycountry{index}.dates;
    data.day0(c) = find(data.cases{c} >= day0cases,1);
end

%figuring out size
maxlen = 0;
for c = 1:length(countries)
    clen = length(data.cases{c}) - data.day0(c) + daysbefore;
    if clen > maxlen
        maxlen = clen;
    end
end

%preallocating
legendstr = {};
cases = zeros(maxlen,length(countries));

%pulling data into bar graph matrix
for c = 1:length(data.day0)
    cdata = data.cases{c}(data.day0(c)-daysbefore:end);
    cases(1:length(cdata),c) = cdata;
    legendstr{c} = [countries{c},' cases, Day 0 = ',datestr(data.dates{c}(data.day0(c)))]; %#ok<SAGROW>
end
    

%% plotting

fig = figure(); clf
ax = gca;
hold on

%bar and line colors corresponding to countries
colors = [0.8, 0.4, 0;... %orange : China
    0.4940    0.1840    0.5560; ... %purple: Spain
    0    0.4470    0.7410]; %blue: USA

%adding bar graph, adjusting color
b = bar(ax,-daysbefore:size(cases,1)-1-daysbefore,cases);
for c = 1:size(colors,1)
    b(c).FaceColor = colors(c,:);
end

% ylim(ax,[0,25000])

% %plotting quarantine dates
ylims = ax.YLim;
% offsets = [-0.3:0.2:0.3];
% for c = 1:length(countries)
%     cmajordate = quarantinestart(c) - data.dates{c}(data.day0(c));
%     plot(ax,[cmajordate,cmajordate],ylims,'color',colors(c,:),'linewidth',2,'linestyle','--')
% %     plot(ax,[cmajordate,cmajordate]+offsets(c),ylims,'color',colors(c,:),'linewidth',2,'linestyle','--')
% end


%% getting decay scales

%only calculate decay scale over period for which all countries have data
maxlen = 1E9;
for c = 1:length(countries)
    cdata = cases(:,c);
    cdata(cdata == 0) = [];
    if length(cdata) < maxlen
        maxlen = length(cdata);
    end
end

ft = fittype('a*exp(x./b)');
for c = 1:length(countries)
    cdata = cases(1:maxlen,c);
    cdata(cdata == 0) = [];
    cdays = (0:length(cdata)-1) - daysbefore;
    cfit = fit(cdays',cdata,'exp1');
    decayscale(c) = 1./cfit.b;
    coeff(c) = cfit.a;
end

% Adding text to plot- uncomment lines to include best-fit plots on figure.
% WARNING- this will definitely freak people out if you share it (why I
% left it off the post)
t = -daysbefore:maxlen-daysbefore-1;
for c = 1:length(countries)
    plot(t,coeff(c).*exp(t./decayscale(c)),'color',colors(c,:),'linestyle',':','linewidth',2);
    plottext{c} = [countries{c},': \alpha = ',num2str(decayscale(c),'%3.2f')];
end
text(ax,1,20000,'C = C_oe^{d/\alpha}','fontsize',14)
text(ax,1,14000,plottext,'fontsize',14)
% text(ax,1,52000,'C = C_oe^{d/\alpha}','fontsize',14)
% text(ax,1,39000,plottext,'fontsize',14)

xlim([0,15])
ylim([0,40000])

%% plot formatting
ylabel(ax,'Confirmed COVID-19 Cases')
ylim(ax,[0,35000])
xlabel(ax,['Days Since Exceeding ',num2str(day0cases),' Cases'])
set(ax,'fontsize',14,'xtick',0:5:500)
grid on
legend(ax,b,legendstr,'location','northwest')
ax.YAxis.Exponent = 0;

%% saving figure
saveas(fig,'COVID19_USvsAsia','png')
