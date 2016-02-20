%this just calculates/simulates the API for a specific location of interest
%calling api_SIM

%this script calls the function api.m which calculates the difference
%between the api model and the observations. then this script solves for
%the appropriate beta, gamma and constat parameters by minimizing the
%difference. 

%load('/jabber/Data/mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
load('/jabber/Data/mcnally/AMMARain/Mpala_KLEE_ubRFE2011_2012.csv')

%rain = RFE_UBRFE_and_station_dekads(:,2);
rain = [Mpala_KLEE_ubRFE2011_2012(:,2)', NaN, NaN, NaN]';
%load('/jabber/Data/mcnally/AMMASOIL/observed_TKWK1WK2.csv')
load('/jabber/Data/mcnally/AMMASOIL/KLEE_dekad.csv')
%load('/jabber/Data/mcnally/AMMASOIL/Mpala_dekad.csv')
%soil = observed_TKWK1WK2;
soil = KLEE_dekad;
%soil = Mpala_dekad;
%y = soil(25:66);    
y = soil(28:68);
%rain = rain(25:66); 
rain = rain(28:68);
%%%%%%%only run this if you want to fit new parameters (in 'result')%%%%%%%

% %lsqnonlin arguments - write a function that calculates the residuals
% %between non linear model and data (so that there is something to minimize!)
% %, and an initial guess for parameters
x0 = [0.001 0.9 0.02];
result = lsqnonlin(@(x) api_sim(x,rain) - y, x0);
sim = api_sim(result,rain);

%% make a API maps!

%this file is huge, but worked. Maybe better to read in one at a time.
 %rain = rain
 %result = [0.0003 0.7027 0.0327];
 sim2 = api_sim(result,rain);
 plot(sim2); hold on
 plot(y,'black')

 %bummer this doesn't work in zippy's matlab :(
 me = goodnessOfFit(sim2,y,'NRMSE')
 
 %write out to a csv file so that I can plot it in IDL
csvwrite('/jabber/Data/mcnally/AMMASOIL/API_ubrf_niger',sim2)