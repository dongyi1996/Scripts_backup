pro daily_total_gs4r_A03,year,date,expdir,nx,ny,nband

;this program calls 'flip..' which removes the header and rotates the image. Instead of a loop
;it calls the file run_daily_total which has a list of the year and date arguments that are needed
; as input both here and 'flip_'. That list is created with /source/mcnally/scripts_bash/run_daily_list.sh (4/9/11?)
;modified on 11/15/11 for catchment land surface model runs

flip_AF_gs4r_A03,date,year,expdir,nx,ny,nbands ;does commenting this out go straight to deyuck?

close,/ALL

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/"+year+"/"+date+"/deyuk/",/remove_all)
FILE_MKDIR,wdir

cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)
buffer = fltarr(nx,ny,nbands)
data_in = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; read all of the data (all days all bands) into data_in
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

day_file = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/", /remove_all)
FILE_MKDIR,day_file

data_in[where(data_in lt -9998)] = !VALUES.F_NAN

;I decided to keep the list intact and just comment out not interesting vars
of0 = strcompress(day_file+"SWnt_" +date+".img",/remove_all)
of1 = strcompress(day_file+"LWnt_" +date+".img",/remove_all)
of2 = strcompress(day_file+"Qlhf_" +date+".img",/remove_all)
of3 = strcompress(day_file+"Qshf_" +date+".img",/remove_all)
of4 = strcompress(day_file+"Qgrd_" +date+".img",/remove_all)
of5 = strcompress(day_file+"rain_" +date+".img",/remove_all)
of6 = strcompress(day_file+"evap_" +date+".img",/remove_all)
of7 = strcompress(day_file+"Qsuf_" +date+".img",/remove_all)
of8 = strcompress(day_file+"Qsub_" +date+".img",/remove_all)
of9 = strcompress(day_file+"Tsuf_" +date+".img",/remove_all)
of10 = strcompress(day_file+"Albd_" +date+".img",/remove_all)
of11= strcompress(day_file+"sm01_" +date+".img",/remove_all)
of12 = strcompress(day_file+"sm02_" +date+".img",/remove_all)
of13 = strcompress(day_file+"sm03_" +date+".img",/remove_all)
of14 = strcompress(day_file+"sm04_" +date+".img",/remove_all)
;soiltemp1
;soiltemp2
;soiltemp3
;soiltemp4
of15 = strcompress(day_file+"PoET_" +date+".img",/remove_all)
of16 = strcompress(day_file+"Ecan_" +date+".img",/remove_all)
of17 = strcompress(day_file+"TVeg_" +date+".img",/remove_all)
of18 = strcompress(day_file+"ESol_" +date+".img",/remove_all)
;intercept
;wind
;rain
of19 = strcompress(day_file+"tair_" +date+".img",/remove_all)
of20 = strcompress(day_file+"qair_" +date+".img",/remove_all)
of21 = strcompress(day_file+"pres_" +date+".img",/remove_all)
of22 = strcompress(day_file+"SWin_" +date+".img",/remove_all)
of23 = strcompress(day_file+"LWin_" +date+".img",/remove_all)
of24 = strcompress(day_file+"humd_" +date+".img",/remove_all)

close,/ALL

openw,1,of0 ;i could change this first one and then the rest would line up...
openw,2,of1
openw,3,of2
openw,4,of3
openw,5,of4
openw,6,of5
openw,7,of6
openw,8,of7
openw,9,of8
openw,10,of9
openw,11,of10
openw,12,of11
openw,13,of12
openw,14,of13
openw,15,of14
openw,16,of15
openw,17,of16
openw,18,of17
openw,19,of18
openw,20,of19
openw,21,of20
openw,22,of21
openw,23,of22
openw,24,of23
openw,25,of24

;initalize arrays
SWnt = fltarr(nx,ny)
LWnt = fltarr(nx,ny)
Qlhf = fltarr(nx,ny)
Qshf = fltarr(nx,ny)
Qgrd = fltarr(nx,ny)
rain = fltarr(nx,ny)
evap = fltarr(nx,ny)
Qsuf = fltarr(nx,ny)
Qsub = fltarr(nx,ny)
Tsuf = fltarr(nx,ny)
Albd = fltarr(nx,ny)
sm01 = fltarr(nx,ny)
sm02 = fltarr(nx,ny)
sm03 = fltarr(nx,ny)
sm04 = fltarr(nx,ny)
PoET = fltarr(nx,ny)
Ecan = fltarr(nx,ny)
TVeg = fltarr(nx,ny)
ESol = fltarr(nx,ny)
tair = fltarr(nx,ny)
qair = fltarr(nx,ny)
pres = fltarr(nx,ny)
SWin = fltarr(nx,ny)
LWin = fltarr(nx,ny)
humd = fltarr(nx,ny)

for x=0,nx-1 do for y=0,ny-1 do begin
;pull out the band that corrosponds with a spp variable from each 3hrly file
;check variable index in NOAHstats.d01.stats and find average rate of the day...
Swnt[x,y] = mean(data_in[x,y,0,*],/NAN)
LWnt[x,y] = mean(data_in[x,y,1,*],/NAN)
Qlhf[x,y] = mean(data_in[x,y,2,*],/NAN)
Qshf[x,y] = mean(data_in[x,y,3,*],/NAN)
Qgrd[x,y] = mean(data_in[x,y,4,*],/NAN)
rain[x,y] = mean(data_in[x,y,5,*],/NAN)
evap[x,y] = mean(data_in[x,y,6,*],/NAN)
Qsuf[x,y] = mean(data_in[x,y,7,*],/NAN) 
Qsub[x,y] = mean(data_in[x,y,8,*],/NAN)
Tsuf[x,y] = mean(data_in[x,y,9,*],/NAN)
Albd[x,y] = mean(data_in[x,y,10,*],/NAN)
sm01[x,y] = mean(data_in[x,y,11,*],/NAN)
sm02[x,y] = mean(data_in[x,y,12,*],/NAN)
sm03[x,y] = mean(data_in[x,y,13,*],/NAN)
sm04[x,y] = mean(data_in[x,y,14,*],/NAN)

PoET[x,y] = mean(data_in[x,y,19,*],/NAN)
Ecan[x,y] = mean(data_in[x,y,20,*],/NAN)
TVeg[x,y] = mean(data_in[x,y,21,*],/NAN)
ESol[x,y] = mean(data_in[x,y,22,*],/NAN) 
tair[x,y] = mean(data_in[x,y,26,*],/NAN) 
qair[x,y] = mean(data_in[x,y,27,*],/NAN)
pres[x,y] = mean(data_in[x,y,28,*],/NAN)
SWin[x,y] = mean(data_in[x,y,29,*],/NAN)
LWin[x,y] = mean(data_in[x,y,30,*],/NAN) 
humd[x,y] = mean(data_in[x,y,31,*],/NAN)

end
writeu,1,SWnt 
writeu,2,LWnt
writeu,3,Qlhf 
writeu,4,Qshf
writeu,5,Qgrd
writeu,6,rain
writeu,7,evap
writeu,8,Qsuf
writeu,9,Qsub
writeu,10,Tsuf
writeu,11,Albd
writeu,12,sm01
writeu,13,sm02 
writeu,14,sm03  
writeu,15,sm04
writeu,16,PoET
writeu,17,Ecan   
writeu,18,Tveg 
writeu,19,ESol 
writeu,20,tair 
writeu,21,qair
writeu,22,pres   
writeu,23,SWin 
writeu,24,LWin 
writeu,25,humd 

print,"wrote " + of1
; end program
end
