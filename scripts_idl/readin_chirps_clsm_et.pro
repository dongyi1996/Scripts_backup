pro readin_CHIRPRS_CLSM_ET
;this reads in the CHIPRS+NOAH time series 1982-present at 0.1 degree
;taken from noahvSSEB

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

startyr = 2003 ;start with 1982 since no data in 1981, or 2003 if for SSEB compare
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_SA/post/'
;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'

Evap = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
  ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
  
  ;variable of interest
  VOI = 'Evap_tavg' &$ 
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  Evap[*,*,i,yr-startyr] = Qs &$

endfor &$
endfor
Evap(where(Evap lt 0)) = 0
;i use the mean in cdo but this could be changed to total if desired.
;Evap_annual = mean(Evap, dimension = 3, /nan) & help, evap_annual
EvapE = Evap
;EvapS = Evap
;EvapW = Evap


delvar, Qs