pro calib_sp, inspe, outpar, pens=pens, inspe2=insp2, binsize=binsize,npol=npol

; This program takes a one or two spectra as an input array and
; produce an output for calibration in the form of [a,b] energy=a+b*channel
;This program is independent of the system used to obtain the spectrum.

;INPUTS
;inspe : input spectrum 1
;
;OUTPUTS:
;outpar: calibration parameters in the form of [a,b] energy=a+b*channel
;
;OPTIONAL INPUTS
;pens: peak energies for calibration, floating array [en1,en2]
;inspe2: if there are two spectra for two different peaks, inspe2 is the second spectra
;binsize: bin parameter to aid fitting. if one spectrum a float, if two spectra fltarr[2]
;npol: polynomial degree in fitting. 


IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(insp2) THEN inp2=0 ELSE inp2=1
IF NOT keyword_set(binsize) then binsize=[1,1]

;FIRST DETERMINE IF THE INPUT CONSISTS OF ONE OR TWO SOURCE SPECTRA

;IF one dimensional, duplicate to mimic two source to have a parallel
;program

IF inp2 THEN BEGIN
  asize=[n_elements(inspe),n_elements(insp2)] 
  szs=(asize[0] > asize[1])
  spe=lonarr(2,szs)
  spe(0,0:asize[0]-1L)=inspe
  spe(1,0:asize[1]-1L)=insp2
  ENDIF ELSE BEGIN
     spe=lonarr(2,n_elements(inspe))
     spe[0,*]=inspe
     spe[1,*]=inspe
     asize=[n_elements(inspe),n_elements(inspe)] 
     IF n_elements(binsize) eq 1 then binsize=[binsize,binsize]
  ENDELSE

peakch=fltarr(2)

!p.multi=0
FOR j=0,1 DO BEGIN

  x_range = [1e1, asize[j]] ;just provide an initial guess
  y_range = [1, MAX(spe[j,1:*])*1.2] ;start from 1 for logarithmic scale
  r1 = !x.crange ; initial range is the plot window
  cond1='No'

  WHILE cond1 EQ 'No' DO BEGIN

  PLOT, spe[j,*], xrange = x_range, yrange = y_range, xstyle = 1, ystyle = 1
    oplot,[r1[0],r1[0]], !y.crange, line = 2
    oplot,[r1[1],r1[1]], !y.crange, line = 2
 

  cond2 = 'No' ;Set initial prompt response.
  ;READ, cond2, PROMPT='Are you happy with the range you chose? (y/n)'

  WHILE cond2 EQ 'No' do begin

  print,'Please set the range using your mouse on the plot'
  print,'Please set the range using your mouse on the plot'
    print,'Move the mouse to the startpoint of region and click'
    cursor, x1, y1, /down
    oplot,[x1,x1],!y.crange,line=0
    print,'Move the mouse to the endpoint of region and click'
    if !mouse.button ne 4 then cursor, x2, y2, /down
    oplot,[x2,x2],!y.crange,line=0
    wait,0.5
    r1=[x1,x2]
    cond2 = DIALOG_MESSAGE('Are you happy with the range you chose?', /Ques)

  ENDWHILE

  fitspe=peakfind2(spe[j,*],r1[0],r1[1],/show,npol=npol)
  peakch[j]=(fitspe.par[1]+r1[0])*binsize[j]

  cond1 = DIALOG_MESSAGE('Are you happy with the fit', /Ques)  

ENDWHILE
ENDFOR

outpar= linfit(peakch,pens)

END
