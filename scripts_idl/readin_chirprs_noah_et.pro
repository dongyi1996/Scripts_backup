pro readin_CHIRPRS_NOAH_ET
;this reads in the CHIPRS+NOAH time series 1982-present at 0.1 degree
;taken from noahvSSEB

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;rainfall = 'RFE2'

;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 2003 ;start with 1982 since no data in 1981, or 2003 if for SSEB compare
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'SA'
params = get_domain01(domain)
;params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
if rainfall eq 'CHIRPS' then $
   data_dir = strcompress(indir+'Noah33_CHIRPS_MERRA2_'+domain+'/post/', /remove_all) else $
   data_dir = strcompress(indir+'Noah33_RFE_GDAS_'+domain+'/post/', /remove_all) & print, data_dir
if rainfall eq 'CHIRPS' then V = 'C' else V = 'A'
fname = 'FLDAS_NOAH01_'+V+'_'+domain+'_M.A'
print, fname
;ifile = file_search(data_dir+fname+STRING(FORMAT='(I4.4,I2.2,''.001.nc'')',y,m)) &$

;intialize the evap output var
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
  ifile = file_search(data_dir+fname+STRING(FORMAT='(I4.4,I2.2,''.001.nc'')',y,m)) &$
  
  ;variable of interest
  VOI = 'Evap_tavg' &$ 
  Qs = get_nc(VOI, ifile) &$
  ;print, ifile, VOI &$
  Evap[*,*,i,yr-startyr] = Qs &$

endfor &$
endfor
;don't use nan since i guess there are neg values in there...
Evap(where(Evap lt 0)) = !values.f_nan
;i use the mean in cdo but this could be changed to total if desired.
Evap_annual = mean(Evap, dimension = 3, /nan) & help, evap_annual
;EvapE = Evap
;EvapS = Evap
;EvapW = Evap
;CHIRPS_ET = evap
;RFE_ET = evap

delvar, Qs