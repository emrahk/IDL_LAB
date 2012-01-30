pro wrapcalib_str_sp_mix, instr, pix, outpar, ps=ps, filename=filename,$ 
binsize=binsize, instr2=inst2, pens=pens, npol=npol, canoc=canoc, anoc=anoc,$
 ans=ans, cats=cats, ses=ses

; This program is a wrapper for calib_sp when the input is a event 
; structure obtained from either the MPA system or the RENA system
;with mixed anodes and cathodes. 

;INPUTS
;
;instr: input structure
;
;pix: input channel. 
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
;
;Used by:
;
;wrapcalib_mp_mix.pro
;
;Uses
;
;calib_sp.pro
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES

IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(ps) THEN filename='singlepixfit.eps'
IF NOT keyword_set(binsize) then binsize=[1,1]
IF NOT keyword_set(inst2) THEN inp2=0 ELSE inp2=1
IF NOT keyword_set(pens) THEN pens=[122.1, 136.5]
IF NOT keyword_set(npol) THEN npol=1
IF NOT keyword_set(ans) THEN ans=0
IF NOT keyword_set(cats) THEN cats=0
IF NOT keyword_set(ses) THEN ses=0

IF (ans+cats+ses) NE 1 THEN $
  print,'You can only choose one of anodes, cathodes or steering electrodes, nothing to be done' $
  ELSE BEGIN

  IF NOT keyword_set(canoc) THEN canoc=-1
  IF NOT keyword_set(anoc) THEN anoc=-1


  IF (n_elements(binsize) eq 1) THEN binsize=[binsize,binsize]
 
  ;choose from a distribution of cathode to anode ratios

  ;Anodes

  IF ans THEN BEGIN

    print,'Choose a range by clicking on the right mouse button twice, and then push the left button to finish'

    ;if no cathode provided, use all cathodes
    IF (canoc eq -1) THEN xast1=where((instr.flag eq 'single') and $
                                     (instr.det[0] eq pix)) ELSE $
                         xast1=where((instr.flag eq 'single') and $
                                     (instr.det[0] eq pix) and $
                                     (instr.cadet[0] eq canoc))


   plot,histogram(instr[xast1].car,min=0,bins=0.01),xr=[0,300] ;this assumes the cathode calibration is not far off from the anode calibration


   moncurs, x_tab=x_tab
   x_tab1=x_tab/100.

   oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
   oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

   wait,0.5

;choose the data with the good cathode to anode ratio
   IF (canoc eq -1) THEN xlst=where((instr.flag eq 'single') and $
                                         (instr.det[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1]))) ELSE $
             xlst=where((instr.flag eq 'single') and (instr.cadet[0] eq canoc) $
                                  and (instr.det[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1])))

  spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0])
  xr1=[1,n_elements(spe1)] ;this is required for plotting

  ENDIF

  IF cats THEN BEGIN
      print,'Choose a range by clicking on the right mouse button twice, and then push the left button to finish'

      ;if an anode is provided, use that anode, otherwise use all anodes
      IF (anoc eq -1) THEN xast1=where((instr.cflag eq 'single') and $
                                     (instr.cadet[0] eq pix)) ELSE $
                         xast1=where((instr.cflag eq 'single') and $
                                     (instr.cadet[0] eq pix) and $
                                     (instr.det[0] eq anoc))

      plot,histogram(instr[xast1].car,min=0,bins=0.01),xr=[0,300] ;this assumes the cathode calibration is not far off from the anode calibration


    moncurs, x_tab=x_tab
    x_tab1=x_tab/100.

    oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
    oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

   wait,0.5

    ;choose the data with the good cathode to anode ratio
    IF (canoc eq -1) THEN xlst=where((instr.cflag eq 'single') and $
                                         (instr.cadet[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1]))) ELSE $
             xlst=where((instr.cflag eq 'single') and (instr.det[0] eq anoc) $
                                  and (instr.cadet[0] eq pix) and $
          ((instr.car gt x_tab1[0]) and (instr.car lt x_tab1[1])))

    spe1=histogram(instr[xlst].caten,min=0,bins=binsize[0])
    xr1=[1,n_elements(spe1)] ;this is required for plotting


  ENDIF


  cond1='No'
  cond2='No'


  WHILE cond1 EQ 'No' DO BEGIN
    WHILE cond2 EQ 'No' DO BEGIN

      IF ans THEN spe1=histogram(instr[xlst].toten,min=0,bins=binsize[0]) 
      IF cats THEN spe1=histogram(instr[xlst].caten,min=0,bins=binsize[0]) 

      ;plot with the new binsize
      plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr1

      cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

      IF cond2 eq 'No' THEN BEGIN 
      read, newbins, prompt='Please provide the new binsize : '
      binsize[*]=newbins
      ENDIF
    ENDWHILE

  xr_anode=xr1
  plot,spe1,xtitle='Channel',ytitle='Counts/bin',xr=xr1
  cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

  IF cond1 eq 'No' THEN read, xr1, prompt='Please provide the new xrange  as xr1,xr2 : '

  ENDWHILE

;=====

  ;If two source, just do the other one....More straightforward then
  ;doing a for loop....

  IF inp2 THEN BEGIN

    IF ans THEN BEGIN

      print,'For the second input structure, choose a range by clicking on the right mouse button twice, and then push the left button to finish'

      IF (canoc eq -1) THEN xast2=where((instr2.flag eq 'single') and $
                                     (instr2.det[0] eq pix)) ELSE $
                         xast2=where((instr2.flag eq 'single') and $
                                     (instr2.det[0] eq pix) and $
                                     (instr2.cadet[0] eq canoc))


    plot,histogram(instr2[xast2].car,min=0,bins=0.01),xr=[0,300] ;this assumes the cathode calibration is not far off from the anode calibration


    moncurs, x_tab=x_tab
    x_tab1=x_tab/100.

    oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
    oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

    wait,0.5
  
    ;choose the data with the good cathode to anode ratio
    IF (canoc eq -1) THEN xlst2=where((instr2.flag eq 'single') and $
                                         (instr2.det[0] eq pix) and $
          ((instr2.car gt x_tab1[0]) and (instr2.car lt x_tab1[1]))) ELSE $
           xlst2=where((instr2.flag eq 'single') and (instr2.cadet[0] eq canoc) $
                                  and (instr2.det[0] eq pix) and $
          ((instr2.car gt x_tab1[0]) and (instr2.car lt x_tab1[1])))

    spe2=histogram(instr[xlst2].toten,min=0,bins=binsize[0])
    xr2=[1,n_elements(spe2)] ;this is required for plotting

  ENDIF

  IF cats THEN BEGIN
    print,'For the second structure, choose a range by clicking on the right mouse button twice, and then push the left button to finish'
  
    IF (anoc eq -1) THEN xast2=where((instr2.cflag eq 'single') and $
                                     (instr2.cadet[0] eq pix)) ELSE $
                         xast2=where((instr2.cflag eq 'single') and $
                                     (instr2.cadet[0] eq pix) and $
                                     (instr2.det[0] eq anoc))

    plot,histogram(instr2[xast2].car,min=0,bins=0.01),xr=[0,300] ;this assumes the cathode calibration is not far off from the anode calibration


    moncurs, x_tab=x_tab
    x_tab1=x_tab/100.

    oplot,[1,1]*x_tab1[0]*100.,[0,!y.crange[1]]
    oplot,[1,1]*x_tab1[1]*100.,[0,!y.crange[1]]

    wait,0.5

    ;choose the data with the good cathode to anode ratio
    IF (canoc eq -1) THEN xlst2=where((instr2.cflag eq 'single') and $
                                         (instr2.cadet[0] eq pix) and $
          ((instr2.car gt x_tab1[0]) and (instr2.car lt x_tab1[1]))) ELSE $
           xlst2=where((instr2.cflag eq 'single') and (instr2.det[0] eq anoc) $
                                  and (instr2.cadet[0] eq pix) and $
          ((instr2.car gt x_tab1[0]) and (instr2.car lt x_tab1[1])))

  spe2=histogram(instr2[xlst2].caten,min=0,bins=binsize[0])
  xr2=[1,n_elements(spe2)] ;this is required for plotting

  ENDIF


  cond1='No'
  cond2='No'


  WHILE cond1 EQ 'No' DO BEGIN
    WHILE cond2 EQ 'No' DO BEGIN

      IF ans THEN spe2=histogram(instr2[xlst2].toten,min=0,bins=binsize[0]) 
      IF cats THEN spe2=histogram(instr2[xlst2].caten,min=0,bins=binsize[0]) 


      plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=xr2

      cond2 = DIALOG_MESSAGE('is this binsize ok for the spectrum?', /Ques)

      IF cond2 eq 'No' THEN BEGIN 
        read, newbins, prompt='Please provide the new binsize : '
        binsize[*]=newbins
        ENDIF
        ENDWHILE

  plot,spe2,xtitle='Channel',ytitle='Counts/bin',xr=xr2
  cond1 = DIALOG_MESSAGE('is this xrange ok for the spectrum?', /Ques)

  IF cond1 eq 'No' THEN read, xr2, prompt='Please provide the new xrange  as xr1,xr2 : '

  ENDWHILE

  calib_sp, spe1, outpar, pens=pens, inspe2=spe2, binsize=binsize, npol=npol,xr1=xr1,xr2=xr2 
  ENDIF ELSE calib_sp, spe1, outpar, pens=pens, binsize=binsize, npol=npol, xr1=xr1


!p.multi=[0,1,2]


;Now plot the results and check

IF cats THEN evlall1=instr[xast1].caten ELSE evlall1=instr[xast1].toten
;calibrate and randomize for nice plotting
evlkev1=(evlall1*outpar[1])+outpar[0]+randomu(s,n_elements(evlall1))-0.5 
enspe1=histogram(evlkev1,min=0)

maxc=max(enspe1[1:n_elements(enspe1)-1L])*1.2
plot, enspe1, xr=[0,pens[1]*1.5],/xstyle,yr=[0,maxc],xtitle='Energy (keV)',psym=10,/ystyle
oplot,[pens[0],pens[0]],[0,maxc]
oplot,[pens[1],pens[1]],[0,maxc]

IF inp2 THEN BEGIN
   IF cats THEN evlall2=inst2[xast2].caten ELSE evlall2=inst2[xast2].toten
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

ENDELSE

END
