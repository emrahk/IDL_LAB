pro crcalib_mp_rena, iocstr, hv=hv, st=st, fr=fr, fc=fc,$
 fet=fet, maxc=maxc

;This program creates or modifies an input output structure for
;calibration of RENA event lists or structures.

;INPUT/OUTPUT
;iocstr : The structure that holds all the relevant info for
;calibration
;
;OPTIONAL INPUTS/OUTPUTS
;
;hv: High voltage for the measurements
;st: shaping time
;fr: Feedback Resistor
;fc: Feedback Capacitor
;fet: FET size
;maxc: number of pixels
;
;May 3 2011
;
;A bug was fixed so that if input structure is provided, it prints the 
;parameters from the input structure, not the defaults
;


IF NOT keyword_set(maxc) THEN maxc=36
IF NOT keyword_set(hv) THEN hv=300
IF NOT keyword_set(st) THEN st=1.1
IF NOT keyword_set(fc) THEN fc=15
IF NOT keyword_set(fr) THEN fr=200
IF NOT keyword_set(fet) THEN fet=450

IF NOT keyword_set(iocstr) THEN BEGIN
   calib=create_struct('maxc',maxc,'hv',hv,'st',st,'st',st,$
                       'fr',fr,'fc',fc,'fet',fet,$
                       'ach2e',fltarr(maxc,2),'pch2e',[0.,0.])
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
