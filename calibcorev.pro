pro calibcorev, ev, calib, evc, pln=pln, pixlist=pixlist, renumerate=renumarate

;this program takes an MPA eventlist file, a calibration file, which
;is a structure that holds calibration parameters, and converts to
;energy all items in channel. Output is evc. This program only handles
;the cases with planar!!!

;INPUTS
;ev: input event list array
;calib: input structure that holds the calibration
;information. Calibration may or may have not have
;planar information. Planar calibration is written seperately.
;
;OUTPUT
;
;evc: calibrated event list
;
;OPTIONAL INPUTS
;
;pln: ADC that holds the planar information. 
;
;pixlist: pixel list to be calibrated
;
;renumerate: if set, then input calibration file is renumerated
;

IF NOT keyword_set(pln) then pln=0
IF NOT keyword_setx(renumerate) THEN renumerate=1

IF NOT keyword_set(pixlist) THEN BEGIN
   npix=calib.maxc
   IF renumerate THEN pixlist=where(indgen(npix+1) NE pln) ELSE $
      pixlist=indgen(npix)
ENDIF ELSE npix=n_elements(pixlist)

evc=float(ev)
sz=size(ev)


;if not renumerated planar is already in the calibratino file
; guaranteed by wrapcalib_mp
FOR i=0, npix-1 DO BEGIN
   print,'i: ',i
   print,'pixlist[i]: ',pixlist[i]
   print,calib.ach2e(i,1)
   print,calib.ach2e(i,0)
   zeros=where(ev[pixlist[i],*] eq 0) ;zeros remain zero
   evc[pixlist[i],*]=ev[pixlist[i],*]*calib.ach2e(i,1)+calib.ach2e(i,0)+randomu(s,sz[2])-0.5
   evc[pixlist[i],zeros]=0.
ENDFOR

;for planar, special handling only necessary for renumerated case

IF renumerate THEN BEGIN
   zeros=where(ev[pln,*] eq 0)
   evc[pln,*]=ev[pln,*]*calib.pch2e(1)+calib.pch2e(0)+randomu(s,sz[2])-0.5
   evc[pln,zeros]=0.
ENDIF

END
