getEOS_percentiles_EastAfrica

;5/13/14 similar to the geoEOS_WRSI_OND this script is going to look at the predicted EOS percentiles, hope to compare to FSOs
; ah, this old stuff is in binary vs the new netcdf
;6/3/14 update with re-done historic runs. still might be problems with the forecast? How would the forecasts work in LIS now?
;9/15/14  plots for Verdin's SERVIR meeting
;9/22/14  MAM plots too?
;11/18/14 revisit for Boulder meeting. Show WRSI percentiles/anomalies
;12/11/14 revisit to put OND and MAM anomalies into a single timeseries.

;Kenya HESS window
;hmap_ulx = 24. & hmap_lrx = 51.
;hmap_uly = 10. & hmap_lry = -10
;
;hulx = (hmap_ulx-22)*10.  & hlrx = (hmap_lrx-22)*10.-1
;huly = (11.75+hmap_uly)*10.   & hlry = (11.75+hmap_lry)*10.-1
;
;;kenya box 270.5 x 203
;hNX = hlrx - hulx + 1.5
;hNY = huly -hlry + 2

;********get the historical OND end-of-seasons so we can calculate percentiles/anomalies*****
;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
NX = lrx - ulx + 1.5
NY = lry - uly + 2

.compile /home/source/husak/idl_functions/make_wrsi_cmap.pro

ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/EA_MAY2NOV_WRSI_inst_CHIRPS_8114.nc')
fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
ncdf_varget,fileID, wrsiID, MAMwrsi
dims = size(MAMwrsi, /dimensions)

ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/EA_OCT2FEB_WRSI_inst_CHIRPS_8114.nc');AM I A YR OFF?
fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
ncdf_varget,fileID, wrsiID, ONDwrsi 
dims = size(ONDwrsi, /dimensions)

NX = dims[0]
NY = dims[1]
nz = dims[2]

;this makes the ocean blue and the mask white! and should make my percentiles turn out correctly.
;I reset this to a low number and get results more consistant w/ soil mositure anomalies
MAMWRSI(where(MAMWRSI eq -9999.0)) = !values.f_nan
MAMWRSI(where(MAMWRSI ge 254)) = -1
MAMWRSI(where(MAMWRSI gt 252)) = 10

ONDWRSI(where(ONDWRSI eq -9999.0)) = !values.f_nan
ONDWRSI(where(ONDWRSI ge 254)) = -1
ONDWRSI(where(ONDWRSI gt 252)) = 10

med_hond = median(ONDwrsi,dimension=3)
med_hmam = median(MAMwrsi,dimension=3)

;this map looks less optamistic that the one I made for previous WRSI 30yr presentation
P1 = IMAGE(CONGRID(BYTE(ONDWRSI[*,*,32]),NX*4,NY*4), IMAGE_DIMENSIONS=[NX/10,NY/10],IMAGE_LOCATION=[MAP_ULX+0.2,MAP_LRY+0.5], $
  RGB_TABLE=MAKE_WRSI_CMAP(),MIN_VALUE=0, TITLE = 'MEDIAN OND EOS (FEB 20th) LIS-WRSI')
  C = COLORBAR(TARGET=P1,ORIENTATION=1,FONT_SIZE=14)
TMPCLR = P1.RGB_TABLE
TMPCLR[*,0] = [28,107,160]
P1.RGB_TABLE = TMPCLR
P1 = MAP('GEOGRAPHIC',LIMIT = [MAP_LRY,MAP_ULX,MAP_ULY,MAP_LRX], /OVERPLOT) &$
P1.MAPGRID.LINESTYLE = 'NONE' &$  ; COULD ALSO USE 6 HERE
  P1.MAPGRID.COLOR = [150, 150, 150] &$
  P1.MAPGRID.FONT_SIZE = 0
  M1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2)
  
;*********67th percentile******************************
;for the forecasts comparisons ajust by eoswrsi[9:293,0:338,*]
dims = size(MAMWRSI,/dimensions)
nx = dims[0]
ny = dims[1]
nz = dims[2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;make percentile maps...why does the percentile map make 2013 weird?
  
Mpermap = fltarr(nx, ny, 3)
Opermap = fltarr(nx, ny, 3)

for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(MAMWRSI[x,y,*]),count) &$
    if count eq -1 then continue &$    
    ;look at one pixel time series at a time 
    Mpix = MAMWRSI[x,y,*] &$ 
    Opix = ONDWRSI[x,y,*] &$          
    Mpermap[x,y,*] = cgPercentiles(Mpix , PERCENTILES=[0.33,0.5,0.67]) &$   
    Opermap[x,y,*] = cgPercentiles(Opix , PERCENTILES=[0.33,0.5,0.67]) &$        
  endfor  &$;x
endfor;y

mpc = fltarr(nx,ny,nz)*!values.f_nan
opc = fltarr(nx,ny,nz)*!values.f_nan

;WHY IS 2013 WEIRD? it happens in the percentile calculation
for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(ONDwrsi[x,y,*]),count) &$
  ;print, count &$
  if count eq 0 then continue &$
 ;new vector of the indices,if less than 33rd = 25,if gt than 33rd and less than 67 = 50,if gt 67th then 75,
 ;then put the values back on the map
  MAMwrsi2 = MAMwrsi[x,y,*]*!values.f_nan &$
  MAMwrsi2(where(MAMwrsi[x,y,*] lt Mpermap[x,y,0])) = 25 &$
  MAMwrsi2(where(MAMwrsi[x,y,*] lt Mpermap[x,y,2] AND MAMwrsi[x,y,*] gt Mpermap[x,y,0] ))=50 &$
  MAMwrsi2(where(MAMwrsi[x,y,*] gt Mpermap[x,y,2]))=75 &$
  MPC[x,y,*] = MAMwrsi2 &$
  
  ;why is the last yr full of 75th percentile?
  ONDwrsi2 = ONDwrsi[x,y,*]*!values.f_nan &$
  ONDwrsi2(where(ONDwrsi[x,y,*] lt Opermap[x,y,0])) = 25 &$
  ONDwrsi2(where(ONDwrsi[x,y,*] lt Opermap[x,y,2] AND ONDwrsi[x,y,*] gt Opermap[x,y,0] ))=50 &$
  ONDwrsi2(where(ONDwrsi[x,y,*] gt Opermap[x,y,2]))=75 &$
  OPC[x,y,*] = ONDwrsi2 &$
 endfor &$
endfor

ts = mean(mean(pc[*,*,0:31],dimension=1,/nan), dimension=1,/nan)
wrsiPa = TS-mean(pc[*,*,0:31], /NAN)

;;;;;;;check to make sure the counts look right, should be 11 of each..why this there 1 - 75th?
;i think i have to live with it for now.
pc = mpc
cntmap25 = pc[*,*,0]
cntmap50 = pc[*,*,0]
cntmap75 = pc[*,*,0]

for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  cnt = where(pc[x,y,*] eq 25, count) &$
  cntmap25[x,y] = count  &$
  cnt = where(pc[x,y,*] eq 50, count) &$
  cntmap50[x,y] = count  &$   
  cnt = where(pc[x,y,*] eq 75, count) &$
  cntmap75[x,y] = count  &$
  endfor &$
endfor
temp = image(cntmap75,rgb_table=4, title = '25th percent cnt') 
c = COLORBAR(target=temp,ORIENTATION=1,/BORDER_ON, font_size=14)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;need a mask for 2013...
;remake plots in old presentation wet yr: 1982,1997, 2006
ncolors=3
for yyyy = 1981,2012 do begin &$
  yyyy = 2012
  yr = yyyy-1981 &$
  p1 = image(byte(congrid(pc[*,*,yr]*shortmask,nx*4,ny*4)), image_dimensions=[nx/10,ny/10],image_location=[map_ulx+0.2,map_lry+0.5], $
  RGB_TABLE=72,MIN_VALUE=0,max_value=100)  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,255] = [255,255,255] &$ ; set map values of zero to white, you can change the color
  rgbdump[*,0] = [255,255,255] &$
  p1.rgb_table = rgbdump &$ ; reassign the colorbar to the image
  p1.title = string(yyyy)+' LONG rain Percentiles' &$
  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON,tickvalues=[25,50,75], font_size=14) &$
  m1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly,map_lrx], /overplot) &$
  m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  m1.mapgrid.color = [150, 150, 150] &$
  m1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [0, 0, 0], THICK = 2) &$
  ;p1.save,strcompress('/home/sandbox/people/mcnally/jpg4gary_Aug14/'+p1.title.string+'.jpg', /remove_all),RESOLUTION=200 &$
endfor
;what is up with 2013? other than that these plots look similar/better than the previous version.
years = ['81','84','87','90','93','96','99','02','05','08','11','14']
mts = mean(mean(mpc[*,*,0:31],dimension=1,/nan), dimension=1,/nan)-mean(mpc[*,*,0:31], /NAN)
ots = mean(mean(opc[*,*,0:31],dimension=1,/nan), dimension=1,/nan)-mean(opc[*,*,0:31], /NAN)

;now I want to put these timeseries into a sparser-vector!
;good now i need the drought severity and BLWS indices....

moTA = fltarr(12,32)
moTA[1,*] = ots
moTA[8,*] = mts
a = reform(moTA,12*32)
p1 = barplot(a)



tmpplt = BARplot(a, xrange=[0,35], thick=3, 'b')
xticks = indgen(32)+1981 & print, xticks
tmpplt.xtickinterval = 3
tmpplt.xTICKNAME = YEARS
tmpplt.xminor = 2
tmpplt.yminor = 0
tmpplt.TITLE = 'WRSI percentile anomalies'
tmpplt.yrange = [-15,15]



 
 ;East Africa WRSI/Noah window
 map_ulx = 22.  & map_lrx = 51.35
 map_uly = 22.95  & map_lry = -11.75

 ulx = (180.+map_ulx)*10.  & lrx = (180.+map_lrx)*10.-1
 uly = (50.-map_uly)*10.   & lry = (50.-map_lry)*10.-1
; NX = lrx - ulx + 1.5
; NY = lry - uly + 2
 
;try this for the map11:
ncolors=13
MAP11(WHERE(MAP11 GE 20)) = !VALUES.F_NAN
p1 = image((map11), image_dimensions=[nx/10,ny/10],image_location=[map_ulx,map_lry], $
   RGB_TABLE=72,MIN_VALUE=0, title ='2010 OND SM Percentiles')  &$
   rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

  p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], THICK = 2)

;why does this one alighn ok?
ncolors = 10
  p1 = image(((map11+1)/32)*100, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=72, MIN_VALUE=0,max_value=100, title = 'observed percentile')
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18   
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)    
     
;******************FORECASTS*****************************************
exps1=['F00','F01','F02','F03','F04','F05','F06','F07','F08','F09','F10','F11','F12','F13','F14', 'F15','F16','F17','F18','F19', $
  'F20','F21','F22','F23','F24','F25','F26','F27','F28','F29' ]

;this grabs the end-of-season forecast from each of the simulations, maybe i should be looking at the 2nd dek in Feb just in case.

ifile = strarr(n_elements(exps1))
indir = '/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/'
for i = 0,n_elements(exps1)-1 do begin &$
  ff = file_search(strcompress(indir+'EXP'+exps1[i]+'/201402200000.d01.gs4r', /remove_all)) &$
  ifile[i] = ff &$
endfor

nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
feos1 = fltarr(nx,ny,n_elements(ifile))

for i=0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$

  feos1[*,*,i] = ingrid[*,*,3] &$
endfor

;looks better without this line. nice to see the no starts
;feos1(where(feos1 ge 253))=!values.f_nan
med_feos1 = median(feos1,dimension=3)

p1 = image(byte(med_feos1), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
  RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'median forecast LIS-WRSI: Nov 1')
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24)

tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])



;NYY is the Nov 15 forecast
exps15=['N00','N01','N02','N03','N04','N05','N06','N07','N08','N09','N10','N11','N12','N13','N14', 'N15','N16','N17','N18','N19', $
  'N20','N21','N22','N23','N24','N25','N26','N27','N28','N29' ]

;this grabs the end-of-season forecast from each of the simulations
ifile = strarr(n_elements(exps1))
for i = 0,n_elements(exps1)-1 do begin &$
  ff = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps15[i]+'/201402200000.d01.gs4r', /remove_all)) &$
  ifile[i] = ff &$
endfor

nx = 285
ny = 339
nz = 40
ingrid = fltarr(nx,ny,nz)
feos15 = fltarr(nx,ny,n_elements(ifile))

for i=0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$

  feos15[*,*,i] = ingrid[*,*,3] &$
endfor

;i don't want the flags in there when i compute the median...
;feos15(where(feos15 ge 253))=!values.f_nan

med_feos15 = median(feos15,dimension=3)
;
;;! figure out how to put back in the colors to match EROS (maybe take an average and impose that?)
p1 = image(byte(med_feos15), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
  RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'median forecast LIS-WRSI: Nov 15')
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
  POSITION=[0.3,0.04,0.7,0.07], font_size=24)

tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;ugh, too bad these images are not the same size....
;next calculate the anomalies and the differences.
diffNov15 = med_feos15 - OBSEOS[9:293,0:338]
diffNov1 = med_feos1 - OBSEOS[9:293,0:338]


ncolors = 10
p1 = image(diffNov15*mask, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[285/10,339/10],image_location=[22.95,-11.75], $
            min_value=-40, max_value=40, title='Nov15 vs OBS diff')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
 
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;calculate the anomalies...make sure this is right before using it....
;OBSEOS[9:293,0:338]
anom1 = (med_feos1/med_heos)*100
anom15 = (med_feos15/med_heos)*100
anomOBS = (obseos[9:293,0:338]/med_heos)*100

;anomaly plot
ncolors = 10
 p1 = image(byte(anomOBS), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MIN_VALUE=50, max_value=150,title = 'OBS anomalies LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

; diff between anoms
diff_anomNov1 =  anom1-anomOBS
diff_anomNov15 =  anom15-anomOBS

ncolors = 10
 p1 = image(diff_anomNov1, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),min_value=-100, max_value=100,title = 'Nov1 anom_diff LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


;ok, what do i want to do? what is the median outcome of the Nov1 forecasts?
;take the average of each map and sort them?

;exps=['083','084', '085','086','087','088','089','090','091','092','093','094', '095','096','097','098','099','100','101','102',$
;      '103','104','105','106','107','108','109','110','111','112']
;ifile = strarr(n_elements(exps))
;for i = 0,n_elements(exps)-1 do begin &$
;  ff = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/????02{28,29}0000.d01.gs4r', /remove_all)) &$
;  ifile[i] = ff &$
;endfor
;nx = 285 ;294, 348 ugh different dimensions
;ny = 339
;nz = 40
;ingrid = fltarr(nx,ny,nz)
;heos = fltarr(nx,ny,n_elements(ifile))
;for i=0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid  &$
;  close,1 &$
;  
;  heos[*,*,i] = ingrid[*,*,3] &$
;endfor

;i shouldn't need this part anymore..now that historic and actual matchup
;what percentile was the actual observed WRSI?
;CHIRPS
;ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/201402_WRSI_CHIRPS/LIS_HIST_201402280000.d01.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;obsEOSID = ncdf_varid(fileID,'WRSI_inst') &$
;ncdf_varget,fileID, obsEOSID, obsEOS 
;OBSeos(where(OBSeos ge 253))=!values.f_nan
;OBSeos(where(OBSeos lt 0))=!values.f_nan

;CHIRPS
;ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/201102_WRSI_CHIRPS/LIS_HIST_201102280000.d01.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;obsEOSID = ncdf_varid(fileID,'WRSI_inst') &$
;ncdf_varget,fileID, obsEOSID, obsEOS 
;OBSeos(where(OBSeos ge 253))=!values.f_nan
;OBSeos(where(OBSeos lt 0))=!values.f_nan

;;***********and the 'observed 2010/11 end-of-season**********
;;what percentile was the actual observed WRSI?
;
;;calculate percent of normal with historic...get this on the same grid (again)
;temp = image(obsEOS)
;;where is this calculation? above?
;
;ncolors = 10
;  p1 = image(pEOS, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
;            RGB_TABLE=72, MIN_VALUE=0,max_value=1, title = 'observed percentile in OND 2010/11')
;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
;;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;
;;  
;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
;p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18   
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2) 


;what was the green-brown color bar that i used for the pptx? 66? blue/red = 72
;ncolors = 15
;  p1 = image(map11, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
;            RGB_TABLE=66, MIN_VALUE=0,max_value=32, title = ' 2011 percent LIS-WRSI: Nov15')
;rgbind = reverse(FIX(FINDGEN(ncolors)*255./(ncolors-1)))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;;rgbdump[*,0] = [200,200,200]
;;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
;p1.rgb_table = reverse(rgbdump)  ; reassign the colorbar to the image
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;
;;
;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
;p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;***********and the 'observed 2014/2011 end-of-season**********
;this bit of code needs some work June 3, 2014
;obsEOS = eosWRSI[*,*,29]; 32=2013/2014 29=2010/11
;
;;show what percentile each pixel in 2013/14 is in in the context of the 30 yr record
;PEOS = fltarr(nx,ny)
;for x = 0, nx-1 do begin &$
;  for y = 0, nx-1 do begin &$
;    ;skip nans
;    test = where(finite(EOSwrsi[x,y,0:31]),count) &$
;    if count eq -1 then continue &$
;
;    ;look at one pixel time series at a time
;     pix = EOSwrsI[x,y,0:31] &$
;     pix = [transpose(pix),obsEOS[x,y] ] &$
;     ;this sorts the historic timeseries from smallest to largest
;        index = sort(pix) &$
;        sorted = pix(index) &$
;       val = where(obsEOS[x,y] eq sorted, count) &$
;       if val[0] eq -1 then continue &$
;       pEOS[x,y] = float(val[0])/n_elements(index) &$
;   endfor &$
; endfor


