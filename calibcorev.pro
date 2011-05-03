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
;03/05/2011
;if pixlist is given with renumeration, indices after planar should
;have been increased. 
;
;pixlist original must be kept! create npixlist

IF NOT keyword_set(pln) then pln=0
IF NOT keyword_setx(renumerate) THEN renumerate=1

IF NOT keyword_set(pixlist) THEN BEGIN
   npix=calib.maxc
   IF renumerate THEN pixlist=where(indgen(npix+1) NE pln) ELSE $
      npixlist=indgen(npix)
ENDIF ELSE BEGIN     ;here we need to be careful with planar again
   npix=n_elements(pixlist)
   IF renumerate THEN npixlist[where(pixlist GE pln)]=pixlist[where(pixlist GE pln)]+1 ELSE npixlist=pixlist
ENDELSE

evc=float(ev)
sz=size(ev)


;if not renumerated planar is already in the calibration file
; guaranteed by wrapcalib_mp
FOR i=0, npix-1 DO BEGIN
   print,'i: ',i
   print,'npixlist[i]: ',npixlist[i]
   print,calib.ach2e(i,1)
   print,calib.ach2e(i,0)
   zeros=where(ev[npixlist[i],*] eq 0) ;zeros remain zero
   evc[npixlist[i],*]=ev[npixlist[i],*]*calib.ach2e(i,1)+calib.ach2e(i,0)+randomu(s,sz[2])-0.5
   evc[npixlist[i],zeros]=0.
ENDFOR

;for planar, special handling only necessary for renumerated case

IF renumerate THEN BEGIN
   zeros=where(ev[pln,*] eq 0)
   evc[pln,*]=ev[pln,*]*calib.pch2e(1)+calib.pch2e(0)+randomu(s,sz[2])-0.5
   evc[pln,zeros]=0.
ENDIF

END
