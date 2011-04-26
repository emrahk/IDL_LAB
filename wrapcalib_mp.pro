pro wrapcalib_mp,  instr, maxpix, iocstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar

; This program is a wrapper for wrapcalib_str_sp to calibrate many pixel
; from either the MPA system, or the RENA system. In fact, this is a
; more general program 

;INPUTS
;
;instr: input structure
;
;maxpix: maximum input anode channel, it will calibrate all from
;channel 0 to maxpis. Ignored if pixlist is given.
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
;planar: If chosen, only planar is calibrated.
;
;pens: peak energies for calibration, floating array [en1,en2]
;
;instr2: if there are two spectra for two different peaks, instr2 
;is the second structure
;
;binsize: bin parameter to aid fitting. if one spectrum a float, if two spectra fltarr[2]
;
;npol: polynomial degree in fitting. 

IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inst2=0 
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1
IF NOT keyword_set(pixlist) THEN pixlist=indgen[maxpix]
IF NOT keyword_set(planar) THEN planar=0

npix=n_elements(pixlist) ; Number of pixels to calibrate

IF planar THEN BEGIN
   
   wrapcalib_str_sp, instr, pix, outpar, ps=ps, filename=filename,$ 
binsize=binsize, instr2=inst2, pens=pens, npol=npol, /planar

   iocstr.pch2e=outpar ; check the format of the structure

ENDIF ELSE BEGIN

   FOR i=0,npix-1 DO BEGIN
      condl='No'
      WHILE condl eq 'No' DO BEGIN
        print,'Doing the fit for pixel ',pixlist[i]
        wrapcalib_str_sp, instr, pixlist[i], outpar, binsize=binsize,$
 instr2=inst2, pens=pens, npol=npol
        condl = DIALOG_MESSAGE('Are you happy with the calibration',/Ques)
      ENDWHILE
      iocstr.ach2e[i,*]=outpar
   ENDFOR
ENDELSE



END
