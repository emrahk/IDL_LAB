pro calibcorev_mix, ev, calib, evc, catlist=listc, anlist=lista, selist=listse

;this program takes an eventlist file, a calibration file, which
;is a structure that holds calibration parameters, and converts to
;energy all items in channel. Output is evc. This works with mixed
;anode, cathodes and steering electrodes 
;
;INPUTS
;ev: input event list array
;
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
;catlist: list of cathode channels
;
;anlist: list of anode channels
;
;selist: list of steering electrode channels
;
;
;Used by:
;
;NONE
;
;Uses
;
;NONE
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES
;
;steering electrode capacity added, 24/02
;

IF NOT keyword_set(listc) THEN listc=-1
IF NOT keyword_set(lista) THEN lista=-1
IF NOT keyword_set(listse) THEN listse=-1

IF total(listc+lista+listse) EQ -3 THEN BEGIN
  PRINT,'You must provide at least one list of channels'
  ENDIF ELSE BEGIN

evc=float(ev)
sz=size(ev)


IF listc[0] ne -1 THEN BEGIN
   npix=n_elements(listc)
   FOR i=0, npix-1 DO BEGIN
;      print,'i: ',i
;      print,'listc[i]: ',listc[i]
;      print,calib.cch2e(i,1)
;      print,calib.cch2e(i,0)
        zeros=where(ev[listc[i],*] eq 0) ;zeros remain zero
        evc[listc[i],*]=ev[listc[i],*]*calib.cch2e(i,1)+calib.cch2e(i,0)
        IF calib.cch2e[i,1] NE 0. THEN evc[listc[i],*]=evc[listc[i],*]+randomu(s,sz[2])-0.5
        evc[listc[i],zeros]=0.
   ENDFOR
ENDIF

IF lista[0] ne -1 THEN BEGIN
   npix=n_elements(lista)
   FOR i=0, npix-1 DO BEGIN
;      print,'i: ',i
;      print,'lista[i]: ',lista[i]
;      print,calib.ach2e(i,1)
;      print,calib.ach2e(i,0)
      zeros=where(ev[lista[i],*] eq 0) ;zeros remain zero
      evc[lista[i],*]=ev[lista[i],*]*calib.ach2e(i,1)+calib.ach2e(i,0)
      IF calib.ach2e[i,1] NE 0. THEN evc[lista[i],*]=evc[lista[i],*]+randomu(s,sz[2])-0.5
      evc[lista[i],zeros]=0.
  ENDFOR
ENDIF


IF listse[0] ne -1 THEN BEGIN
   npix=n_elements(listse)
   FOR i=0, npix-1 DO BEGIN
;      print,'i: ',i
;      print,'lista[i]: ',lista[i]
;      print,calib.ach2e(i,1)
;      print,calib.ach2e(i,0)
      zeros=where(ev[33+i,*] eq 0) ;zeros remain zero
      evc[33+i,*]=ev[33+i,*]*calib.sech2e(listse[i],1)+calib.sech2e(listse[i],0)
      IF calib.sech2e[listse[i],1] NE 0. THEN evc[33+i,*]=evc[33+i,*]+randomu(s,sz[2])-0.5
      evc[33+i,zeros]=0.
  ENDFOR
ENDIF


ENDELSE

END
