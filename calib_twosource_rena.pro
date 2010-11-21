pro calib_twosource_rena, pix, instr1, instr2, outpar, binsize=binsize, pens=pens, ratrange=ratrange,$
 maxc=maxc, hv=hv, st=st, gain=gain, nch=nch, planar=planar

; This program takes 2 input structures with 2 different lines and planar electrode,  
; detector number 
; and  the ranges for peaks for the given detector as inputs and finds 
; calibration parameters as output (outpar)and plots the calibrated 
; spectrum in keV
; This is the version for RENA, it does calibration pixel by pixel and do not loop for all pixels
; and does not create a calib file.

IF NOT keyword_set(binsize) THEN binsize=1
IF NOT keyword_set(pens) THEN pens=[59.5, 122.1]
IF NOT keyword_set(ratrange) then ratrange=[0.8,0.95]
IF NOT keyword_set(planar) then planar=0

;system parameters
;IF NOT keyword_set(maxc) THEN maxc=36
;IF NOT keyword_set(hv) THEN hv=250.
;IF NOT keyword_set(st) THEN st=1.1
;IF NOT keyword_set(cgain) THEN gain=5.
;IF NOT keyword_set(nch) THEN nch=8192

peakch=fltarr(2)
outpar=fltarr(2)

!p.multi=0
FOR j=0,1 DO BEGIN
 IF j eq 0 THEN instr=instr1 ELSE instr=instr2
 print, 'DO THE FIT FOR ',strtrim(string(pens[j]),1),' keV peak'

IF planar THEN BEGIN
    aa = where((instr.flag eq 'single' ) and (instr.det[0] eq pix)) 
    evl=instr[aa].caten[0]
    spe = histogram(evl, binsize=binsize, min=0)
    ENDIF ELSE BEGIN
    aa = where((instr.flag eq 'single') and (instr.det[0] eq pix) and $
    ((instr.car gt ratrange[0]) and (instr.car le ratrange[1]))) ;do the depth cut here
    evl=instr[aa].en[0]
    spe = histogram(evl, binsize=binsize, min=0)
  ENDELSE
  IF j eq 0 THEN spe0=spe ELSE spe1=spe
  x_range = [1e2, 8e3]/binsize ;just provide an initial guess
  y_range = [1, MAX(spe[1:*])*1.2] ;start from 1 for logarithmic scale
  r1 = !x.crange ; initial range is the plot window

  cond1='No'

  WHILE cond1 EQ 'No' DO BEGIN

  PLOT, spe, xrange = x_range, yrange = y_range, xstyle = 1, ystyle = 1
    oplot,[r1[0],r1[0]], !y.crange, line = 2
    oplot,[r1[1],r1[1]], !y.crange, line = 2
    XYOUTS, 0.8, 0.8, 'Pixel ' + STRTRIM(pix,1), /NORMAL, charsize = 1.5

  cond2 = 'No' ;Set initial prompt response.
  ;READ, cond2, PROMPT='Are you happy with the range you chose? (y/n)'

  WHILE cond2 EQ 'No' do begin

  print,'Please set the range using your mouse on the plot'
  print,'Please set the range using your mouse on the plot'
    print,'Move the mouse to the startpoint of region and click'
    cursor, x1, y1, /down
    oplot,[x1,x1],!y.crange,line=1
    print,'Move the mouse to the endpoint of region and click'
    if !mouse.button ne 4 then cursor, x2, y2, /down
    oplot,[x2,x2],!y.crange,line=0
    wait,0.25
    r1=[x1,x2]
    cond2 = DIALOG_MESSAGE('Are you happy with the range you chose?', /Ques)

  ENDWHILE

  fitspe=peakfind2(spe,r1[0],r1[1],/show,npol=1)
  peakch[j]=(fitspe.par[1]+r1[0])*binsize

  cond1 = DIALOG_MESSAGE('Are you happy with the fit', /Ques)  

ENDWHILE
ENDFOR

outpar = poly_fit(peakch,pens, 1)

enspe0=lonarr(400)
enspe1=enspe0

for k= 10, 198 do begin 
  initialch = floor(((k + 0.5 - outpar[0])/outpar[1])+0.5)/binsize
  finalch = floor(((k + 1.5 - outpar[0])/outpar[1]) + 0.5)/binsize
  if finalch ge n_elements(spe0) then finalch0=n_elements(spe0)-1L else finalch0=finalch
  if finalch ge n_elements(spe1) then finalch1=n_elements(spe1)-1L else finalch1=finalch
  envalue1 = 0
;   print, initialch, finalch
  if initialch gt 0 then begin
  for m= initialch, finalch0 do begin
  envalue1 = envalue1 + spe0[m]
  endfor
  endif
  enspe0[k+1]= envalue1
   envalue1 = 0
;   print, initialch, finalch
  if initialch gt 0 then begin
  for m= initialch, finalch1 do begin
  envalue1 = envalue1 + spe1[m]
  endfor
  endif
 enspe1[k+1]= envalue1
ENDFOR

!p.multi=[0,1,2]
plot, enspe0, xr=[0,200]

oplot,[pens[0],pens[0]],[0,max(enspe0)*1.2]
oplot,[pens[1],pens[1]],[0,max(enspe0)*1.2]

oplot,[136.5,136.5],[0,max(enspe0)*1.2]
oplot,[14.4,14.4],[0,max(enspe0)*1.2]

plot, enspe1,xr=[0,200]

oplot,[pens[0],pens[0]],[0,max(enspe1)*1.2]
oplot,[pens[1],pens[1]],[0,max(enspe1)*1.2]

oplot,[136.5,136.5],[0,max(enspe1)*1.2]
oplot,[14.4,14.4],[0,max(enspe0)*1.2]

wait,0.25

condlast = DIALOG_MESSAGE('Are you happy with the fit', /Ques)



 ;cond3='No'
 ;WHILE cond3 eq 'No' DO BEGIN
 ;   PRINT, 'These are the default parameters to be saved'
 ;   PRINT, '1. High Voltage: ',hv
 ;   PRINT, '2. Shaping Time: ',st
 ;   PRINT, '3. Coarse Gain: ',cgain
 ;   PRINT, '4. Fine Gain: ',fgain
 ;   PRINT, '5. Offset: 65', offset
 ;   PRINT, '6. Pole Zero Adj.', pza
 ;   PRINT, '7. Numer of ADC Channels: ',nch
 ;   wait,0.25
 ;   inp=''
 ;   READ, 'TYPE the number of parameter to be changed, or PRESS any other key to exit:',inp
 ;   CASE inp OF
 ;     '1': READ,'New High Voltage: ',hv
 ;     '2': READ,'New shaping time (us): ',st
 ;     '3': READ,'New Coarse Gain: ',cgain
 ;     '4': READ,'New Fine Gain: ',fgain
 ;     '5': READ,'New Offset: ',offset
 ;     '6': READ,'New Pole Zero Adjustment: ',pza
 ;     '7': READ,'New number of ADC channels: ',nch
 ;  ELSE: cond3 = 'Yes'
 ;  ENDCASE
 ;ENDWHILE 
;calib=create_struct('maxc',maxc,'hv',hv,'st',st,'cgain',cgain,'fgain',fgain,$
;                    'offset',offset,'pza',pza,'nch',nch,'ach2e',outpar[1:maxc,*],'pch2e',outpar[0,*])

;IF NOT keyword_set(fname) then PRINT,'fit parameters are not saved' ELSE BEGIN
;  PRINT,'Saving under default variable name calib'
;  save,calib,filename=fname 
;  ENDELSE

END
