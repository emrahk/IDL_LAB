pro calib_twosource_rena, pix, instr1, instr2, outpar, binsize=binsize, pens=pens, ratrange1=ratrange1,$
 ratrange2=ratrange2,maxc=maxc, planar=planar


; This program takes 2 input structures with 2 different lines and planar electrode,  
; detector number 
; and  the ranges for peaks for the given detector as inputs and finds 
; calibration parameter as output (outpar)and plots the calibrated 
; spectrum in keV

; input parameters
;pix : anode no from RENA 3
;instr1 : cleaned input structure with one of the lines
;instr2 : cleaned input structure with the other line
;
;optional parameters
;binsize : to bin the spectra for better fitting, default 1
;pens : line energies of the input structures, default [59.5,122], Am and Co
;ratrange1 : cathode to anode ratio range for input 1, default 0.8,0.95
;ratrange1 : cathode to anode ratio range for input 1, default 0.8,0.95
;maxc : total number of channels
;planar : if chosen calibrates the planar spectrum with the given anode number
;
;output parameters
;outpar : channel to keV parameters, energy = outpar(0)+channel*outpar(1)


IF NOT keyword_set(binsize) THEN binsize=1
IF NOT keyword_set(pens) THEN pens=[59.5, 122.1]
IF NOT keyword_set(ratrange1) then ratrange1=[0.8,0.95]
IF NOT keyword_set(ratrange2) then ratrange2=[0.8,0.95]
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

condlast = 'No'

WHILE condlast EQ 'No' DO BEGIN
  FOR j=0,1 DO BEGIN
    IF j eq 0 THEN BEGIN
      instr=instr1 
      ratrange=ratrange1
    ENDIF ELSE BEGIN
      instr=instr2
      ratrange=ratrange2
    ENDELSE
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

;get the entire spectrum, first eventlists

IF NOT planar then BEGIN
    aa = where((instr1.flag eq 'single') and (instr1.det[0] eq pix))
    evl0=instr1[aa].en[0]
    aa = where((instr2.flag eq 'single') and (instr2.det[0] eq pix))
    evl1=instr2[aa].en[0]
ENDIF

;convert to energy list with 1 keV resolution
enl0=floor((evl0*outpar(1))+outpar(0)+0.5)
enl1=floor((evl1*outpar(1))+outpar(0)+0.5)

enspe0=histogram(enl0,min=0,binsize=1)
enspe1=histogram(enl1,min=0,binsize=1)

!p.multi=[0,1,2]

plot, enspe0, xr=[0,150],psym=10, xtickname = replicate(' ',5),ytitle='Counts',pos=[0.1,0.53,0.96,0.96]
oplot,[pens[0],pens[0]],[0,max(enspe0)*1.2]
oplot,[pens[1],pens[1]],[0,max(enspe0)*1.2]

oplot,[136.5,136.5],[0,max(enspe0)*1.2]
oplot,[14.4,14.4],[0,max(enspe0)*1.2]

plot, enspe1,xr=[0,150],psym=10, ytitle='Counts',pos=[0.1,0.10,0.96,0.53],xtitle='Energy (keV)'

oplot,[pens[0],pens[0]],[0,max(enspe1)*1.2]
oplot,[pens[1],pens[1]],[0,max(enspe1)*1.2]

oplot,[136.5,136.5],[0,max(enspe1)*1.2]
oplot,[14.4,14.4],[0,max(enspe0)*1.2]

wait,0.25

condlast = DIALOG_MESSAGE('Are you happy with the fit', /Ques)

ENDWHILE

END
