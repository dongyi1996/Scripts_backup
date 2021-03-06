%this script calls the function api.m which calculates the difference
%between the api model and the observations. then this script solves for
%the appropriate beta, gamma and constat parameters by minimizing the
%difference. 

load('/jabber/chg-mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')
rain = RFE_UBRFE_and_station_dekads(:,2);
load('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = observed_TKWK1WK2;
y = nanmean(soil,2);

%lsqnonlin arguments - write a function that calculates the residuals
%between non linear model and data (so that there is something to minimize!)
%, and an initial guess for parameters
x0 = [0.001 0.9 0.02];
result = lsqnonlin(@(x) api_sim(x,rain) - y, x0);
sim = api_sim(result,rain);

%% make a API maps!
NX = 720;
NY = 350;
NZ = 428; %396;
apimap=NaN(NX,NY,NZ);

%this file is huge, but worked. Maybe better to read in one at a time.
infile = '/jabber/LIS/Data/ubRFE2/dekads/sahel/sahel_200101_201232.img';
fid = fopen(infile,'r');
ndeks = fread(fid,NX*NY*NZ,'float');
fclose(fid);
ndeks=reshape(ndeks,NX,NY,NZ);
imagesc(ndeks(:,:,1)');

for X = 1:NX
    for Y = 1:NY
      rain=reshape(ndeks(X,Y,:),NZ,1);
      result = [0.0003 0.7027 0.0327];
      sim2=api_sim(result,rain);
      %plot(sim2)
      apimap(X,Y,:)=sim2;
    end
end

clims=[ 0.001 0.2];
imagesc(apimap(:,:,245)',clims); colorbar;

fid = fopen('/jabber/LIS/Data/ubRFE2/dekads/sahel_API_200101_201232.img', 'w');
fwrite(fid, apimap, 'float');
fclose(fid); 



