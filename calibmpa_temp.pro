pro calibmpa_temp

;This program is a template for obtaining calibration parameters for
;an MPA dataset. Copy this file to your local directory under another
;name and do not touch the original. Change the appropriate parameters
;and run the necessary components. This is intended for future
;reference plus first time fits

;input variables for data reading, if necessary

data_dir='' ;directory name for the event list data
infile1=data_dir+'/' ;event list file for input 1
infile2=data_dir+'/' ;event list file for input 2, if necessary

;read files if necessary

an_thr=50.      ;anode threshold in channels
cat_thr=50.     ;cathode threshold in channels
pln=0           ;which pixel is planar?
renumerate=1    ;renumarate pixel sequence taking cathode out?

;read by choosing the file from the directory

;clean1=pickreadorg_wp(an_thr=an_thr,cat_thr=cat_thr, $
;                       pln=pln, data_dir=data_dir, renumerate=renumerate)

;or better read using the filenames so that a record is kept for which
;file has been used

read_singlempalist, infile1, ev1, adc_mode=adc_mode, active_adc=active_adc
reorganize_wc,ev1,an_thr,cat_thr,clean1,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;do the same for second file if necessary

;clean2=pickreadorg_wp(an_thr=an_thr,cat_thr=cat_thr, $
;                       pln=pln, data_dir=data_dir, renumerate=renumerate)

;or better read using the filenames so that a record is kept for which
;file has been used

read_singlempalist, infile2, ev2, adc_mode=adc_mode, active_adc=active_adc
reorganize_wc,ev2,an_thr,cat_thr,clean2,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;===============================

;Now create the structure for calibration



maxc=15
hv=300
st=1
cgain=0
fgain=6
offset=65
pza=50
nch=8192

crcalib_mp_mpa, calstr, hv=hv, st=st, cgain=cgain, fgain=fgain,$
 offset=offset, pza=pza, nch=nch, maxc=maxc

;=============================

;now find the calibration parameters

;First anodes

maxpix=15
binsize=[1.,1.]
inst2=clean2
pens=[122.1,136.4]
npol=1
;pixlist=[0,1,2,3]
planar=0
renumerate=1

wrapcalib_mp,  clean1, maxpix, calstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar, renumerate=renumerate

;then planar

planar=1
maxpix=0

wrapcalib_mp,  clean1, maxpix, calstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar, renumerate=renumerate


;=============================

;save the calibration structure with an appropriate filename

hvs=strtrim(string(calib.hv),1)
sts=strtrim(string(calib.st),1)
cgs=strtrim(string(calib.cgain),1)
fgs=strtrim(string(calib.fgain),1)
nchs=strtrim(string(calib.nch),1)
offs=strtrim(string(calib.offset),1)
pzas=strtrim(string(calib.pza),1)

fnamestr='cal_mpa_hv'+hvs+'_st'+sts+'_cg'+cgs+'_fg'+fgs+'_nch'+$
         nchs+'_off'+offs+'_pza'+pzas+'.sav'
save,calstr,filename=fnamestr

;============================

;do the calibration to the eventlists

pln=planar

calibcorev, ev1, calstr, evc1, pln=pln, pixlist=pixlist, renumerate=renumerate

;if necessary do the same for file 2

calibcorev, ev2, calstr, evc2, pln=pln, pixlist=pixlist, renumerate=renumerate

;===========================

;recreate calibrated structures if necessary

ane_thr=8.
cate_thr=8. 

reorganize_wc,evc1,ane_thr,cate_thr,cleanc1,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

;if necessary the second file

reorganize_wc,evc1,ane_thr,cate_thr,cleanc1,catn=pln,maxc=n_elements(active_adc),renumerate=renumerate

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
