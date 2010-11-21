pro calib_onesource, instr1, calib, binsize=binsize, pens=pens, ratrange=ratrange, fname=fname, maxc=maxc, $
                     hv=hv, st=st, cgain=cgain, fgain=fgain, offset=offset, pza=pza, nch=nch, ratprange=ratprange


; This program takes 1 input structure with 2 different lines and planar electrode,  
; detector number 
; and  the ranges for peaks for the given detector as inputs and finds 
; calibration parameters as output (outpar)and plots the calibrated 
; spectrum in keV

IF NOT keyword_set(binsize) THEN binsize=1
IF NOT keyword_set(pens) THEN pens=[32.1, 80.9]
IF NOT keyword_set(ratrange) then ratrange=[0.8,0.95]
;if you want specific range for planar, it can also be specified, otherwise it is the same for all channels
IF NOT keyword_set(ratprange) then ratprange=ratrange

;system parameters
IF NOT keyword_set(maxc) THEN maxc=16
IF NOT keyword_set(hv) THEN hv=300.
IF NOT keyword_set(st) THEN st=1.
IF NOT keyword_set(cgain) THEN cgain=0.
IF NOT keyword_set(fgain) THEN fgain=6.
IF NOT keyword_set(offset) THEN offset=65.
IF NOT keyword_set(pza) THEN pza=50.
IF NOT keyword_set(nch) THEN nch=4096

peakch=fltarr(2)
outpar=fltarr(maxc+1,2)

FOR pixel = -1, maxc-1 DO BEGIN
!p.multi=0
FOR j=0,1 DO BEGIN

 print, 'DO THE FIT FOR ',strtrim(string(pens[j]),1),' keV peak'

 IF pixel eq -1 THEN BEGIN
    aa = where((instr1.car gt ratprange[0]) and (instr1.car le ratprange[1]) and (instr1.flag eq 'single')) ;do the depth cut here
    evl=instr1[aa].caten[0]
    spe = histogram(evl, binsize=binsize, min=0)
    ENDIF ELSE BEGIN
    aa = where((instr1.flag eq 'single') and (instr1.det[0] eq pixel) and $
    ((instr1.car gt ratrange[0]) and (instr1.car le ratrange[1]))) ;do the depth cut here
    evl=instr1[aa].en[0]
    spe = histogram(evl, binsize=binsize, min=0)
  ENDELSE
  
  x_range = [1e2, 1.5e3] ;just provide an initial guess
  y_range = [1, MAX(spe[1:*])*1.2] ;start from 1 for logarithmic scale
  r1 = !x.crange ; initial range is the plot window

  cond1='No'

  WHILE cond1 EQ 'No' DO BEGIN

  PLOT, spe, xrange = x_range, yrange = y_range, xstyle = 1, ystyle = 1
    oplot,[r1[0],r1[0]], !y.crange, line = 2
    oplot,[r1[1],r1[1]], !y.crange, line = 2
    XYOUTS, 0.8, 0.8, 'Pixel ' + STRTRIM(pixel,1), /NORMAL, charsize = 1.5

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

  fitspe=peakfind2(spe,r1[0]/binsize,r1[1]/binsize,/show,npol=1)
  peakch[j]=fitspe.par[1]*binsize+r1[0]

  cond1 = DIALOG_MESSAGE('Are you happy with the fit', /Ques)  

ENDWHILE
ENDFOR

outpar[pixel+1,*] = poly_fit(peakch,pens, 1)

enspe=lonarr(400)

for k= 10, 198 do begin 

  initialch = floor(((k + 0.5 - outpar[pixel+1,0])/outpar[pixel+1,1])+0.5)/binsize
  finalch = floor(((k + 1.5 - outpar[pixel+1,0])/outpar[pixel+1,1]) + 0.5)/binsize
  if finalch ge n_elements(spe) then finalch=n_elements(spe)-1L
  envalue1 = 0
 print, initialch, finalch
  if initialch gt 0 then begin
  for m= initialch, finalch do begin
  envalue1 = envalue1 + spe[m]
  endfor
  endif
  enspe[k+1]= envalue1

endfor

plot, enspe

oplot,[pens[0],pens[0]],[0,max(enspe)*1.2]
oplot,[pens[1],pens[1]],[0,max(enspe)*1.2]

;oplot,[136.5,136.5],[0,max(enspe[1,*])]

wait,0.25

condlast = DIALOG_MESSAGE('Are you happy with the fit', /Ques)

ENDFOR



 cond3='No'
 WHILE cond3 eq 'No' DO BEGIN
    PRINT, 'These are the default parameters to be saved'
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
      '1': READ,'New High Voltage: ',hv
      '2': READ,'New shaping time (us): ',st
      '3': READ,'New Coarse Gain: ',cgain
      '4': READ,'New Fine Gain: ',fgain
      '5': READ,'New Offset: ',offset
      '6': READ,'New Pole Zero Adjustment: ',pza
      '7': READ,'New number of ADC channels: ',nch
   ELSE: cond3 = 'Yes'
   ENDCASE
 ENDWHILE 
calib=create_struct('maxc',maxc,'hv',hv,'st',st,'cgain',cgain,'fgain',fgain,$
                    'offset',offset,'pza',pza,'nch',nch,'ach2e',outpar[1:maxc,*],'pch2e',outpar[0,*])

IF NOT keyword_set(fname) then PRINT,'fit parameters are not saved' ELSE BEGIN
  PRINT,'Saving under default variable name calib'
  save,calib,filename=fname 
  ENDELSE

END
