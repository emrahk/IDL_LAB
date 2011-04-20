pro wrapcalib_str_sp, instr, pix, outpar, ps=ps, filename=filename,$ 
binsize=binsize, instr2=inst2, pens=pens, npol=npol

; This program is a wrapper for calib_sp when the input is a event structure obtained
; from either the MPA system or the RENA system. 

;INPUS
;
;instr: input structure
;pix: input channel
;
;OUTPUTS
;
;outpar: calibration parameters in the form of [a,b] energy=a+b*channel
;
;OPTIONAL INPUTS
;pens: peak energies for calibration, floating array [en1,en2]
;instr2: if there are two spectra for two different peaks, instr2 is the second structure
;binsize: bin parameter to aid fitting. if one spectrum a float, if two spectra fltarr[2]
;npol: polynomial degree in fitting. 
;ps: if set encapsulated postscript output is produced
;filename: if set with ps, encapsulated postscript is given this name.


IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(ps) THEN filename='singlepixfit.eps'
IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inp2=0 ELSE inp2=1
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1

IF (inp2 AND (n_elements(binsize) eq 1)) THEN binsize=[binsize,binsize]
 
;choose from a distribution of cathode to anode ratios
xast1=where((instr.flag eq 'single') and (instr.det[0] eq pix))
plot,histogram(instr[xast1].car,min=0,bins=0.01),xr=[0,300]

moncurs, x_tab=x_tab
x_tab1=x_tab/100.

oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

wait,0.5

xlst=where((instr.flag eq 'single') and (instr.det[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1])))


cond1='No'
cond2='No'
spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0])
xr1=[1,n_elements(spe1)]

WHILE cond1 EQ 'No' DO BEGIN
  WHILE cond2 EQ 'No' DO BEGIN

    spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0])
    plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr

    cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

     IF cond2 eq 'No' THEN BEGIN 
      read, newbins, prompt='Please provide the new binsize : '
      binsize[0]=newbins
    ENDIF
    ENDWHILE

plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr1

cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

IF cond1 eq 'No' THEN read, xr1, prompt='Please provide the new xrange  as xr1,xr2 : '

ENDWHILE


;If two source, just do the other one....More straightforward then
;doing a for loop....

IF inp2 THEN BEGIN

   xast2=where((inst2.flag eq 'single') and (inst2.det[0] eq pix))
   plot,histogram(inst2[xast2].car,min=0,bins=0.01),xr=[0,300]

   moncurs, x_tab=x_tab
   x_tab1=x_tab/100.

   xlst=where((inst2.flag eq 'single') and (inst2.det[0] eq pix) and $
          ((inst2.car gt x_tab1[0]) and (inst2.car lt x_tab1[1])))


cond1='No'
cond2='No'
spe2=histogram(inst2[xlst].toten,min=0,bins=binsize[1])
xr2=[1,n_elements(spe2)]

WHILE cond1 EQ 'No' DO BEGIN
  WHILE cond2 EQ 'No' DO BEGIN

  spe2=histogram(inst2[xlst].toten,min=0,bins=binsize[1])
  plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=[1,n_elements(spe2)]

  cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

  IF cond2 eq 'No' THEN BEGIN
    read, newbins, prompt='Please provide the new binsize'
    binsize[1]=newbins
    ENDIF
    ENDWHILE

plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=xr2

cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

IF cond1 eq 'No' THEN read, xr2, prompt='Please provide the new xrange  as xr1,xr2 : '

ENDWHILE

calib_sp, spe1, outpar, pens=pens, inspe2=spe2, binsize=binsize, npol=npol,xr1=xr1,xr2=xr2
!p.multi=[0,1,2]

ENDIF ELSE calib_sp, spe1, outpar, pens=pens, binsize=binsize, npol=npol, xr1=xr1

;Now plot the results and check

evlall1=instr[xast1].toten
evlkev1=(evlall1*outpar[1])+outpar[0]
if outpar[1] LT 0. THEN evlkev1=2*pens[0]-evlkev1
enspe1=histogram(evlkev1,min=0)

maxc=max(enspe1[1:n_elements(enspe1)-1L])*1.2
plot, enspe1, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',psym=10,/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]

IF inp2 THEN BEGIN
evlall2=inst2[xast2].toten
evlkev2=(evlall2*outpar[1])+outpar[0]
if outpar[1] LT 0. THEN evlkev2=2*pens[1]-evlkev2
enspe2=histogram(evlkev2,min=0)
maxc=max(enspe2[1:n_elements(enspe2)-1L])*1.2
plot, enspe2, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',psym=10,/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]
ENDIF


IF ps THEN BEGIN

  set_plot,'ps'
  device,/encapsulated
  device,filename=filename

maxc=max(enspe1[1:n_elements(enspe1)-1L])*1.2
plot, enspe1, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]

IF inp2 THEN BEGIN
maxc=max(enspe2[1:n_elements(enspe2)-1L])*1.2
plot, enspe2, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]
ENDIF

ENDIF

!p.multi=0

wait,0.25



IF ps THEN BEGIN
  device,/close
  set_plot,'x'
  ENDIF

END
