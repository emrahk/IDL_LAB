;pro calibrena_temp_mix

;This program is a template for obtaining calibration parameters for
;a RENA dataset with mixed anode and cathodes. Copy this file to your
;local directory under another name and do not touch the original. 
;Change the appropriate parameters
;and run the necessary components. This is intended for future
;reference plus first time fits

;input variables for data reading, if necessary
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES
;


;set the data directories and filenames

setup=0

IF setup THEN BEGIN

data_dir='' ;directory name for the event list data
infile1=data_dir+'' ;event list file for input 1
;infile2=data_dir+'' ;event list file for input 2 if necessary

;read files if necessary

an_thr=50.      ;anode threshold in channels
cat_thr=50. 
se_thr=50.    ;cathode threshold in channels
pln=indgen(16)+1           ;which pixels are planar?

;read by choosing the file from the directory

;read_rena_bin, ev1, pln, data_dir=data_dir
;read_rena_bin, ev2, pln, data_dir=data_dir
;

;or better read using the filenames so that a record is kept for which
;file has been used

read_rena_binary, infile1a, ev1,pln
;read_rena_binary, infile2a, ev2,pln ;if necessary

ENDIF

reorganize=0

IF reorganize THEN BEGIN

reorganize_mix,ev1,an_thr,cat_thr,se_thr,clean1,catn=pln
;reorganize_mix,ev2,an_thr,cat_thr,se_thr,clean2,catn=pln ;if necessary

ENDIF

;===============================

;Now create the structure for calibration

crstr=0

IF crstr THEN BEGIN

maxan=16  ; number of anode pixels to be created numbered from 0
maxca=16  ; number of cathodes
maxse=2   ; number of steering electrodes
hv=500   ; high voltage
st=replicate(1.9,35)   ; shaping time
fc=replicate(15,35)    ; feedback capacitor
fr=[replicate(200,16),replicate(1000,19)]   ;feedback resistor
fet=[replicate(1000,16),replicate(450,19)]  ; fet size

crcalib_mp_rena_mix, calstr, hv=hv, st=st, fc=fc, fr=fr,$
 fet=fet, maxan=maxan, maxca=maxca, maxse=maxse

ENDIF
;=============================

;now find the calibration parameters

;First anodes

calibano=0

IF calibano THEN BEGIN

maxpix=15  ; anodes to fit from 0, ignored if pixlist is given
binsize=[8.,8.]  ; binsizes for two lines
;inst2=clean2     ; second structure if necessary
pens=[122.1,136.4]  ; peak energies
npol=1  ; degree of polynomial 
pixlist=[0,1,2,3,4,5,6,8,9,10,11,12,13,14,15]  ; pixel list to be calibrated

wrapcalib_mp_mix,  clean1, maxpix, calstr, binsize=binsize, $
pens=pens, npol=npol, pixlist=pixlist,/ans

;wrapcalib_mp_mix,  clean1, maxpix, calstr, binsize=binsize, $
;instr2=inst2, pens=pens, npol=npol, pixlist=pixlist,/ans ;if two structures 


ENDIF

calibcat=0
IF calibcat THEN BEGIN
;then cathodes

binsize=[32,32]
maxpix=7  ; use pixel 0 to get cathode spectrum
pixlist=[9,10,11,12,13,14,15]  ; pixel list to be calibrated


wrapcalib_mp_mix,  clean, maxpix, calstr, binsize=binsize, $
pens=pens, npol=npol, pixlist=pixlist,/cats

;wrapcalib_mp_mix,  clean, maxpix, calstr, binsize=binsize, instr2=inst2, $
;pens=pens, npol=npol, pixlist=pixlist,/cats


ENDIF

;=============================
savecalib=0

IF savecalib THEN BEGIN

;save the calibration structure with an appropriate filename

;hvs=strtrim(string(calstr.hv),1)
;sts=strtrim(string(calstr.st),1)
;fcs=strtrim(string(calstr.fc),1)
;frs=strtrim(string(calstr.fr),1)
;fets=strtrim(string(calstr.fet),1)

;mind / \ for unix windows
fnamestr=data_dir+'/cal_mpa_hv'+'500'+'_st'+'50'+'_fc'+'15'+'_fr'+'mix'+'_fet'+$
         'mix'+'.sav'
save,calstr,filename=fnamestr

ENDIF
;============================

;do the calibration to the eventlists

appcalib=0

IF appcalib THEN BEGIN

   calibcorev_mix, ev1, calstr, evc1, catlist=indgen(16)+1, anlist=indgen(16)+17
;   calibcorev_mix, ev2, calstr, evc2, catlist=indgen(16)+1, anlist=indgen(16)+17


ENDIF

;=======

;recreate calibrated structures if necessary

ane_thr=8.
cate_thr=8. 

reorganizec=0


IF reorganizec THEN BEGIN

reorganize_mix,evc1,ane_thr,cate_thr,se_thr,clean1c,catn=pln
;reorganize_mix,evc2,ane_thr,cate_thr,se_thr,clean2c,catn=pln


ENDIF

;==================
saveevts=0

IF saveevts THEN BEGIN

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
ENDIF

END
