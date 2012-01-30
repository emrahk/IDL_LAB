pro wrapcalib_mp_mix,  instr, maxpix, iocstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,canoc=canoc, anoc=anoc, ans=ans, $
cats=cats, ses=ses

; This program is a wrapper for wrapcalib_str_sp to calibrate many pixel
; from either the MPA system, or the RENA system. In fact, this is a
; more general program. It can handle different number of anodes,
; cathodes and steering electrodes

;INPUTS
;
;instr: input structure
;
;maxpix: maximum input channel, it will calibrate all from
;channel 0 to maxpix. Ignored if pixlist is given.
;
;
;iocstr: input/output structure for calibrating event lists
;further. it is both input and output to preserve measurements 
;from earlier OUTPUTS
;
;
;OPTIONAL INPUTS
;
;pixlist: You can choose just the channels you like to calibrate
;
;ans: If chosen, only anodes are calibrated.
;canoc: cathode number to aid in calibration (to choose ratios is
;anodes are chosen). If not chosen all single cathodes are used.
;
;cats: if chosen, only cathodes are calibrated
;anoc: anode number to aid in calibration, if not given all single 
;anodes are used
;
;ses: if chosen, only steering electrodes are calibrated (not
;implemented yet)
;
;pens: peak energies for calibration, floating array [en1,en2]
;
;instr2: if there are two spectra for two different peaks, instr2 
;is the second structure
;
;binsize: bin parameter to aid fitting. if one spectrum a float, if two spectra fltarr[2]
;
;npol: polynomial degree in fitting. 
;
;
;Used by:
;
;NONE
;
;Uses
;
;wrapcalib_sp_mix.pro
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES

IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inst2=0 
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1
IF NOT keyword_set(ans) THEN ans=0
IF NOT keyword_set(cats) THEN cats=0
IF NOT keyword_set(ses) THEN ses=0
IF (ans+cats+ses) NE 1 THEN BEGIN
   print,'You can only choose one of anodes, cathodes or steering electrodes, nothing to be done'
ENDIF

IF NOT keyword_set(canoc) THEN canoc=-1
IF NOT keyword_set(anoc) THEN anoc=-1

IF NOT keyword_set(pixlist) THEN pixlist=indgen(maxpix)

npix=n_elements(pixlist) ; Number of pixels to calibrate

IF ans THEN BEGIN
   FOR i=0,npix-1 DO BEGIN
      condl='No'
      WHILE condl eq 'No' DO BEGIN
        print,'Doing the fit for pixel ',pixlist[i]
        wrapcalib_str_sp_mix, instr, pixlist[i], outpar, binsize=binsize,$
 instr2=inst2, pens=pens, npol=npol,/ans, canoc=canoc
        condl = DIALOG_MESSAGE('Are you happy with the calibration',/Ques)
      ENDWHILE
      iocstr.ach2e[pixlist[i],*]=outpar
   ENDFOR
ENDIF

IF cats THEN BEGIN
   FOR i=0,npix-1 DO BEGIN
      condl='No'
      WHILE condl eq 'No' DO BEGIN
        print,'Doing the fit for pixel ',pixlist[i]
        wrapcalib_str_sp_mix, instr, pixlist[i], outpar, binsize=binsize,$
 instr2=inst2, pens=pens, npol=npol,/cats, anoc=anoc
        condl = DIALOG_MESSAGE('Are you happy with the calibration',/Ques)
      ENDWHILE
      iocstr.cch2e[pixlist[i],*]=outpar
   ENDFOR
ENDIF



END
