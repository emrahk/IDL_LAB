pro wrapcalib_mp,  instr, maxpix, iocstr, binsize=binsize, instr2=inst2, $
pens=pens, npol=npol, pixlist=pixlist,planar=planar, renumerate=renumerate

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
;IF planar is set then maxpix corresponds to channel with which the
;planar spectrum is created!
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
;
;renumerate: check if the input structure is renumerated
;
;Original committed: 26/04/2011
;
;changes
;
;28/04/2011
;Original version assumes renumarated input structure, should be
;changed to include non-renumerated cases
;
;02/05/2011
;A bug is fixed such that planar case works fine
;

IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inst2=0 
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1
IF NOT keyword_set(planar) THEN planar=0
IF NOT keyword_setx(renumerate) THEN renumerate=1
IF NOT keyword_set(pixlist) THEN BEGIN
   IF renumerate THEN pixlist=indgen[maxpix] ELSE $
      pixlist=where(indgen[maxpix+1] NE planar)
ENDIF


npix=n_elements(pixlist) ; Number of pixels to calibrate

IF planar THEN BEGIN
   
   wrapcalib_str_sp, instr, maxpix, outpar, ps=ps, filename=filename,$ 
binsize=binsize, instr2=inst2, pens=pens, npol=npol, /planar

   iocstr.pch2e=outpar 

;This part should guarantee that without renumerate calibcorev works right
   IF NOT renumerate THEN iocstr.ach2e[planar,*]=outpar ;just for completeness

ENDIF ELSE BEGIN

   FOR i=0,npix-1 DO BEGIN
      condl='No'
      WHILE condl eq 'No' DO BEGIN
        print,'Doing the fit for pixel ',pixlist[i]
        wrapcalib_str_sp, instr, pixlist[i], outpar, binsize=binsize,$
 instr2=inst2, pens=pens, npol=npol
        condl = DIALOG_MESSAGE('Are you happy with the calibration',/Ques)
      ENDWHILE
      iocstr.ach2e[pixlist[i],*]=outpar
   ENDFOR
ENDELSE



END
