pro calibrena_temp

;This program is a template for obtaining calibration parameters for
;a RENA dataset. Copy this file to your local directory under another
;name and do not touch the original. Change the appropriate parameters
;and run the necessary components. This is intended for future
;reference plus first time fits

;input variables for data reading, if necessary

;04/05/11
;changes are implemented to make it parallel with mpa case

;16/06/11
;further changes are implemented to make it parallel, read_rena_bin changed to
;read_rena_binary
;
;22/06/11
;a small bug was fixed to be used with a second file.

data_dir='' ;directory name for the event list data
infile1=data_dir+'/' ;event list file for input 1
infile2=data_dir+'/' ;event list file for input 2, if necessary

;read files if necessary

an_thr=50.      ;anode threshold in channels
cat_thr=50.     ;cathode threshold in channels
pln=2           ;which pixel is planar?
renumerate=1    ;renumarate pixel sequence taking cathode out?

;read by choosing the file from the directory

;read_rena_bin, ev1, pln, data_dir=data_dir

;or better read using the filenames so that a record is kept for which
;file has been used

read_rena_binary, infile1, ev1,pln
reorganize_wc,ev1,an_thr,cat_thr,clean1,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;do the same for second file if necessary

;read_rena_bin, ev2, pln, data_dir=data_dir

;or better read using the filenames so that a record is kept for which
;file has been used

read_rena_binary, infile2, ev2, pln
reorganize_wc,ev2,an_thr,cat_thr,clean2,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;===============================

;Now create the structure for calibration

maxc=35  ; number of pixels to be created numbered from 0
hv=300   ; high voltage
st=1.1   ; shaping time
fc=15    ; feedback capacitor
fr=200   ;feedback resistor
fet=450  ; fet size

crcalib_mp_rena, calstr, hv=hv, st=st, fc=fc, fr=fr,$
 fet=fet, maxc=maxc

;=============================

;now find the calibration parameters

;First anodes

maxpix=35  ; anodes to fit from 0, ignored if pixlist is given
binsize=[1.,1.]  ; binsizes for two lines
inst2=clean2     ; second structure if necessary
pens=[122.1,136.4]  ; peak energies
npol=1  ; degree of polynomial 
;pixlist=[0,1,2,3]  ; pixel list to be calibrated
planar=0  ; anodes only 
renumerate=1 ; renumerate

wrapcalib_mp,  clean1, maxpix, calstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar, renumerate=renumerate

;then planar

planar=1 ; do the planar
maxpix=0  ; use pixel 0 to get cathode spectrum

wrapcalib_mp,  clean1, maxpix, calstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar, renumerate=renumerate


;=============================

;save the calibration structure with an appropriate filename

hvs=strtrim(string(calstr.hv),1)
sts=strtrim(string(calstr.st),1)
fcs=strtrim(string(calstr.fc),1)
frs=strtrim(string(calstr.fr),1)
fets=strtrim(string(calstr.fet),1)

;mind / \ for unix windows
fnamestr=data_dir+'/cal_mpa_hv'+hvs+'_st'+sts+'_fc'+fcs+'_fr'+frs+'_fet'+$
         fets+'.sav'
save,calstr,filename=fnamestr

;============================

;do the calibration to the eventlists

calibcorev, ev1, calstr, evc1, pln=pln, pixlist=pixlist, renumerate=renumerate

;if necessary do the same for file 2

calibcorev, ev2, calstr, evc2, pln=pln, pixlist=pixlist, renumerate=renumerate

;===========================

;recreate calibrated structures if necessary

ane_thr=8.
cate_thr=8. 

reorganize_wc,evc1,ane_thr,cate_thr,cleanc1,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;if necessary the second file

reorganize_wc,evc2,ane_thr,cate_thr,cleanc2,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;==================

;save the calibrated event lists and files if necessary

neweventlistname1=evc1 ;your appropriate names
neweventlistname2=evc1 ;your appropriate names
newstrname1=cleanc1 ;your appropriate names
newstrname2=cleanc2 ;your appropriate names


fevc1=''
fevc2=''
fstrc1=''
fstrc2=''

save, newevenlistname1, filename=fevc1
save, newevenlistname2, filename=fevc2
save, newstrname1, filename=fstrc1
save, newstrname2, filename=fstrc2

;===================

END
