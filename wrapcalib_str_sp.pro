pro wrapcalib_str_sp, instr, pix, outpar, ps=ps, filename=filename,$ 
binsize=binsize, instr2=inst2, pens=pens, npol=npol, planar=planar

; This program is a wrapper for calib_sp when the input is a event 
; structure obtained from either the MPA system or the RENA system. 

;INPUTS
;
;instr: input structure
;pix: input channel. If planar is chosen, than the cathode to anode
;ratio limiting is done with the data from this pixel.
;
;OUTPUTS
;
;outpar: calibration parameters in the form of [a,b] energy=a+b*channel
;
;OPTIONAL INPUTS
;pens: peak energies for calibration, floating array [en1,en2]
;
;instr2: if there are two spectra for two different peaks, 
;instr2 is the second structure
;
;binsize: bin parameter to aid fitting. if one spectrum a float, if two spectra fltarr[2]
;
;npol: polynomial degree in fitting. 
;
;ps: if set encapsulated postscript output is produced
;
;filename: if set with ps, encapsulated postscript is given this name.
;
;planar: If set calibrate the planar using the given pixel

IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(ps) THEN filename='singlepixfit.eps'
IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inp2=0 ELSE inp2=1
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1
IF NOT keyword_set(planar) THEN planar=0

IF (inp2 AND (n_elements(binsize) eq 1)) THEN binsize=[binsize,binsize]
 
;choose from a distribution of cathode to anode ratios
print,'Choose a range by clicking on the right mouse button twice, and then push the left button to finish'

xast1=where((instr.flag eq 'single') and (instr.det[0] eq pix))

plot,histogram(instr[xast1].car,min=0,bins=0.01),xr=[0,300] ;this assumes the cathode calibration is not far off from the anode calibration


moncurs, x_tab=x_tab
x_tab1=x_tab/100.

oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

wait,0.5

;choose the data with the good cathode to anode ratio
xlst=where((instr.flag eq 'single') and (instr.det[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1])))


cond1='No'
cond2='No'


;Planar case gets complicated. We choose anode spectral range to fit
;the cathode (planar) spectra. For anodes we need to choose this range anyway.

IF planar THEN print,'For planar first choose the anode spectral range'

spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0])
xr1=[1,n_elements(spe1)] ;this is required for plotting

WHILE cond1 EQ 'No' DO BEGIN
  WHILE cond2 EQ 'No' DO BEGIN

    spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0]) ;plot with the new binsize
    plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr1

    cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

     IF cond2 eq 'No' THEN BEGIN 
      read, newbins, prompt='Please provide the new binsize : '
      binsize[*]=newbins
    ENDIF
    ENDWHILE

;this is necessary for cathode case
spe_anode=spe1
xr_anode=xr1
plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr1
cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

IF cond1 eq 'No' THEN read, xr1, prompt='Please provide the new xrange  as xr1,xr2 : '

ENDWHILE

;Here it gets complicated because for high energies the planar line
; could be just an edge due to hole trapping. The best is to choose 
;anode spectral regions for singles, and treat two planar lines as if 
;it is two spectra even for the case of one input structure.


IF planar THEN BEGIN
    print,'For planar only now choose the spectral regions, first ',pens[0],' keV'
    print,'Use right click to set the range, left click to finish'
    moncurs, x_tab=x_tab
  
    oplot,[1,1]*x_tab[0],[0,!y.crange[1]]
    oplot,[1,1]*x_tab[1],[0,!y.crange[1]]

wait,0.5

xlst1=where((instr.flag eq 'single') and (instr.det[0] eq pix) and $
          ((instr.toten gt x_tab[0]*binsize[0]) and (instr.toten lt x_tab[1]*binsize[0])))

spe1=histogram(instr[xlst1].caten,min=0,bins=binsize[0])

;adjust the range for better fitting

xr1=[0,n_elements(spe1)]
cond3='No'
WHILE cond3 eq 'No' DO BEGIN
   plot,spe1,xrange=xr1,/xstyle
   cond3 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)
   IF cond3 eq 'No' THEN read, xr1, prompt='Please provide the new xrange  as xr1,xr2 : '
   ENDWHILE


;if there is no second structure, we can still treat the second line
;coming from a second structure to obtain clear features to fit.

   IF NOT inp2 THEN BEGIN
      
   print,'For planar only now choose the spectral regions, second ',pens[1],' keV'
    print,'Use right click to set the range, left click to finish'

   plot,spe_anode,xtitle='Channel',ytitle='Counts/bin',xr=xr_anode
    moncurs, x_tab=x_tab
  
    oplot,[1,1]*x_tab[0],[0,!y.crange[1]]
    oplot,[1,1]*x_tab[1],[0,!y.crange[1]]

    wait,0.5

    xlst2=where((instr.flag eq 'single') and (instr.det[0] eq pix) and $
          ((instr.toten gt x_tab[0]*binsize[0]) and (instr.toten lt x_tab[1]*binsize[0])))
    
    spe2=histogram(instr[xlst2].caten,min=0,bins=binsize[1])
    xr2=[0,n_elements(spe2)]

;adjust the range for better fit

   cond3='No'
   WHILE cond3 eq 'No' DO BEGIN
   plot,spe2,xrange=xr2,/xstyle
   cond3 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)
   IF cond3 eq 'No' THEN read, xr2, prompt='Please provide the new xrange  as xr1,xr2 : '
   ENDWHILE
    ENDIF
ENDIF

;If two source, just do the other one....More straightforward then
;doing a for loop....

IF inp2 THEN BEGIN

;choose cathode to anode ratio from the second input structure
   print,'Choose the range for the second input structure by clicking on the right mouse button twice, and then push the left button to finish'

   xast2=where((inst2.flag eq 'single') and (inst2.det[0] eq pix))
   plot,histogram(inst2[xast2].car,min=0,bins=0.01),xr=[0,300]

   moncurs, x_tab=x_tab
   x_tab1=x_tab/100.

   xlst=where((inst2.flag eq 'single') and (inst2.det[0] eq pix) and $
          ((inst2.car gt x_tab1[0]) and (inst2.car lt x_tab1[1])))

   spe2=histogram(inst2[xlst].toten,min=0,bins=binsize[1])
   xr2=[1,n_elements(spe2)]     ;this is required for plotting

cond1='No'
cond2='No'

WHILE cond1 EQ 'No' DO BEGIN
  WHILE cond2 EQ 'No' DO BEGIN

  spe2=histogram(inst2[xlst].toten,min=0,bins=binsize[1])
  plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=xr2

  cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

  IF cond2 eq 'No' THEN BEGIN
    read, newbins, prompt='Please provide the new binsize'
    binsize[1]=newbins
    ENDIF
    ENDWHILE

plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=xr2
spe_anode=spe2
xr_anode=xr2

cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

IF cond1 eq 'No' THEN read, xr2, prompt='Please provide the new xrange  as xr1,xr2 : '

ENDWHILE

IF planar THEN BEGIN
   print,'For planar only now choose the spectral regions, second ',pens[1],' keV'
    print,'Use right click to set the range, left click to finish'
    moncurs, x_tab=x_tab
  
    oplot,[1,1]*x_tab[0],[0,!y.crange[1]]
    oplot,[1,1]*x_tab[1],[0,!y.crange[1]]

wait,0.5

xlst2=where((inst2.flag eq 'single') and (inst2.det[0] eq pix) and $
          ((inst2.toten gt x_tab[0]*binsize[1]) and (inst2.toten lt x_tab[1]*binsize[1])))

spe2=histogram(inst2[xlst2].caten,min=0,bins=binsize[1])

;adjust the range for better fitting

xr2=[0,n_elements(spe2)]
cond4='No'
WHILE cond4 eq 'No' DO BEGIN
   plot,spe2,xrange=xr2,/xstyle
   cond4 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)
   IF cond4 eq 'No' THEN read, xr2, prompt='Please provide the new xrange  as xr1,xr2 : '
   ENDWHILE


ENDIF

calib_sp, spe1, outpar, pens=pens, inspe2=spe2, binsize=binsize, npol=npol,xr1=xr1,xr2=xr2
!p.multi=[0,1,2]

ENDIF ELSE BEGIN 
  IF planar THEN calib_sp, spe1, outpar, pens=pens, inspe2=spe2, $
  binsize=binsize, npol=npol, xr1=xr1, xr2=xr2 ELSE $
  calib_sp, spe1, outpar, pens=pens, binsize=binsize, npol=npol, xr1=xr1
ENDELSE

;Now plot the results and check

IF planar THEN evlall1=instr[xast1].caten ELSE evlall1=instr[xast1].toten
;calibrate and randomize for nice plotting
evlkev1=(evlall1*outpar[1])+outpar[0]+randomu(s,n_elements(evlall1))-0.5 
enspe1=histogram(evlkev1,min=0)

maxc=max(enspe1[1:n_elements(enspe1)-1L])*1.2
plot, enspe1, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',psym=10,/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]

IF inp2 THEN BEGIN
   IF planar THEN evlall2=inst2[xast2].caten ELSE evlall2=inst2[xast2].toten
   evlkev2=(evlall2*outpar[1])+outpar[0]+randomu(s,n_elements(evlall2))-0.5
   enspe2=histogram(evlkev2,min=0)
   maxc=max(enspe2[1:n_elements(enspe2)-1L])*1.2
   plot, enspe2, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',psym=10,/ystyle
   oplot,[pens[0],pens[0]],[0,maxc]
   oplot,[pens[1],pens[1]],[0,maxc]
ENDIF

print, 'Calibration parameters: '
print, 'offset: ',outpar[0]
print, 'gain: ',outpar[1]

IF ps THEN BEGIN

  set_plot,'ps'
  device,/encapsulated
  device,filename=filename

maxc=max(enspe1[1:n_elements(enspe1)-1L])*1.2
plot, enspe1, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',/ystyle,psym=10
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]

IF inp2 THEN BEGIN
maxc=max(enspe2[1:n_elements(enspe2)-1L])*1.2
plot, enspe2, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',/ystyle,psym=10
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
