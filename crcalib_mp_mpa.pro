pro crcalib_mp_mpa, iocstr, hv=hv, st=st, cgain=cgain, fgain=fgain,$
 offset=offset, pza=pza, nch=nch, maxc=maxc

;This program creates or modifies an input output structure for
;calibration of MPA event lists or structures.

;INPUT/OUTPUT
;iocstr : The structure that holds all the relevant info for
;calibration
;
;OPTIONAL INPUTS/OUTPUTS
;
;hv: High voltage for the measurements
;st: shaping time
;cgain: Coarse Gain
;fgain: Fine Gain
;offset: Offset
;pza: point zero
;nch: number of channels in the spectrum
;maxc: number of pixels

IF NOT keyword_set(maxc) THEN maxc=15
IF NOT keyword_set(hv) THEN hv=300.
IF NOT keyword_set(st) THEN st=1.
IF NOT keyword_set(cgain) THEN cgain=0.
IF NOT keyword_set(fgain) THEN fgain=6.
IF NOT keyword_set(offset) THEN offset=65.
IF NOT keyword_set(pza) THEN pza=50.
IF NOT keyword_set(nch) THEN nch=4096

IF NOT keyword_set(iocstr) THEN BEGIN
   calib=create_struct('maxc',maxc,'hv',hv,'st',st,'cgain',cgain,$
                       'fgain',fgain,'offset',offset,'pza',pza,$
                       'nch',nch,'ach2e',fltarr(maxc,2),'pch2e',[0.,0.])
   cont=1
ENDIF ELSE BEGIN
   ques = DIALOG_MESSAGE('Warning, you are about to modify an existing structure, are you sure you want to continue?', /Ques)
   IF Ques eq 'Yes' THEN cont=1 ELSE cont=0
   calib=iocstr
ENDELSE

IF cont THEN BEGIN
   
 cond3='No'
 WHILE cond3 eq 'No' DO BEGIN
    PRINT, 'These are the parameters to be saved'
    PRINT, '1. High Voltage: ',hv
    PRINT, '2. Shaping Time: ',st
    PRINT, '3. Coarse Gain: ',cgain
    PRINT, '4. Fine Gain: ',fgain
    PRINT, '5. Offset: 65', offset
    PRINT, '6. Pole Zero Adj.', pza
    PRINT, '7. Numer of ADC Channels: ',nch
    wait,0.25
    inp=''
    READ, 'TYPE the number of parameter to be changed, or PRESS any other key to exit:',inp
    CASE inp OF
      '1': BEGIN
         READ,'New High Voltage: ',hv
         calib.hv=hv
         END
      '2': BEGIN
         READ,'New shaping time (us): ',st
         calib.st=st
         END
      '3': BEGIN
         READ,'New Coarse Gain: ',cgain
         calib.cgain=cgain
         END
      '4': BEGIN
         READ,'New Fine Gain: ',fgain
         calib.fgain=fgain
         END
      '5': BEGIN
         READ,'New Offset: ',offset
         calib.offset=offset
         END
      '6': BEGIN
         READ,'New Pole Zero Adjustment: ',pza
         calib.pza=pza
         END
      '7': BEGIN
         READ,'New number of ADC channels: ',nch
         calib.nch=nch
      END      
   ELSE: cond3 = 'Yes'
   ENDCASE
 ENDWHILE 

iocstr=calib
ENDIF ELSE print,'Nothing to be done!'

END
