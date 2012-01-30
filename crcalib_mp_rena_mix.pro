pro crcalib_mp_rena_mix, iocstr, hv=hv, st=st, fr=fr, fc=fc,$
 fet=fet, maxan=maxan, maxca=maxca, maxse=maxse

;This program creates or modifies an input output structure for
;calibration of RENA event lists or structures with mixed anode,
;cathode, steering electrode distribution


;INPUT/OUTPUT
;iocstr : The structure that holds all the relevant info for
;calibration
;
;OPTIONAL INPUTS/OUTPUTS
;
;hv: High voltage for the measurements 
;
;st: shaping time
;
;fr: Feedback Resistor
;
;fc: Feedback Capacitor
;
;fet: FET size
;
;st,fr,fc,and fet are arrays with number of relevant pixels
;
;maxan: number of anodes
;
;maxca: number of cathodes
;
;maxse: number of steering electrodes
;
;
;
;Used by:
;
;NONE
;
;Uses
;
;NONE
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES

IF NOT keyword_set(maxan) THEN maxan=16
IF NOT keyword_set(maxca) THEN maxca=16
IF NOT keyword_set(maxse) THEN maxse=2

maxp=maxan+maxca+maxse

IF NOT keyword_set(hv) THEN hv=500
IF NOT keyword_set(st) THEN st=replicate(1.1,maxp)
IF NOT keyword_set(fc) THEN fc=replicate(15,maxp)
IF NOT keyword_set(fr) THEN fr=replicate(200,maxp)
IF NOT keyword_set(fet) THEN fet=replicate(450,maxp)

IF NOT keyword_set(iocstr) THEN BEGIN
   calib=create_struct('hv',hv,'st',st,$
                       'fr',fr,'fc',fc,'fet',fet,$
                       'ach2e',fltarr(maxan,2),'cch2e',fltarr(maxca,2),$
                      'sech2e',fltarr(maxse,2))
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
    PRINT, '1. High Voltage: ',calib.hv
    PRINT, '2. Shaping Time: ',calib.st
    PRINT, '3. Feedback Capacitor: ',calib.fc
    PRINT, '4. Feedback Resistor: ',calib.fr
    PRINT, '5. Fet size', calib.fet
    wait,0.25
    PRINT,'If you enter new parameters, make sure that the array matches and provide the values as x1,x2,x3,....'
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
         READ,'New Feedback Capacitor: ',fc
         calib.fc=fv
         END
      '4': BEGIN
         READ,'New Feedback Resistor: ',fr
         calib.fr=fr
         END
      '5': BEGIN
         READ,'New FET Size ',fet
         calib.fet=fet
         END
   ELSE: cond3 = 'Yes'
   ENDCASE
 ENDWHILE 

iocstr=calib
ENDIF ELSE print,'Nothing to be done!'

END
