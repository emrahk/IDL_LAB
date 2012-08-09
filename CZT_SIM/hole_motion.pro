; THIS PROGRAM DETERMINES THE HOLE MOTION INSIDE A DETECTOR ALONG THE FIELD LINES
; AND CALCULATES THE INDUCED CHARGE ON A SPECIFIC ELECTRODE.

pro hole_motion, xstart, zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST,$
 th_actual, xh_actual, zh_actual, QA_ind_h, QC_ind_h, QST_ind_h,$
   ypos = posy, htau=tauh, hmob=mobh, plotout=plotout, plotps=plotps, fname=namef,$
   verbose=verbose, coarsegridpos=poscoarsegrid

;INPUTS
;xstart: start position in the x direction in units of mm
;zstart: start position in the z direction in units of mm
;Efieldx: x component of the electric field
;Efieldz: z component of the electric field
;WP_Ano: Weihgting potential of the anode
;WP_Cath: Weighting potential of the cathode
;WP_ST  : Weighting potential of the steering electrode
;
;OPTIONAL INPUTS
;tauh: trapping time of electrons
;mobh : electron mobility
;posy : fixed y position for calculating cathode signal. If not given, assumed to be the center
;of the cathode
;verbose: if set screen output for diagnostic is produced. The default
;         parameters to be shown are x, z, t, QA_ind_h, QC_ind_h
;poscoarsegrid : one can set where coarse gridding starts and end default=[0.5,4.5] mm


;OUTPUTS
;th_actual: timh variable with respect to the motion of holes
;xh_actual: actual x position with respect to the motion of holes 
;zh_actual: actual z position with respect to the motion of holes
;QA_ind_h: Induced charge of holes on the anode side 
;QC_ind_h: Induced charge of electrons on the cathode side
;QST_ind_h: Induced charge of holes on the steering electrodes
;
;OPTIONAL OUTPUTS
;plotout: If this option is selected, user gets plots on the screen
;plotps: If this option is selected, user gets plots as a ps file
;namef: optional postscript output filename

;====NOTES, BUG FIXES
;August 14, 2011, A bug on the definition of posy was fixed,
;cathode weighting potential is now correctly set

;Still going in a loop at negative electric fields, maybe it is not
;physical. For now I will write a routine to catch the loop and get
;out with a warning message

;August 15, verbose keyword added, minor fixes on description

;August 18, 2011, yet another stupid mistake, when z goes by 5, gz must go by 5*0.005
;major effect on time and x position. In fact a coarsegrid position variable is set so
;that one can adjust which part of the detector is coarse and which part is fine

;August 10, 2012, a bug that calculates dt as negative with negative
;electric field is fixed

;when the charges are very close to the side do not allow them to go
;out, August 11 2012

IF NOT keyword_set(plotout) THEN plotout=0
IF NOT keyword_set(plotps) THEN plotps=0
IF NOT keyword_set(verbose) THEN verbose = 0

bb = size(Efieldz)

QT_h = dblarr(bb[1],bb[2])          ; Trapped Charge Array

IF NOT KEYWORD_SET(tauh) THEN tauh=1E-6 ; electron trapping time in s
IF NOT KEYWORD_SET(mobh) THEN mobh=5E3 ; mm^2/V.s, electron mobility

z_thick = 5.0                       ; mm. Detector z thickness
x_length = 19.54                    ; mm. Detector x length  

gx = 0.005                          ; Default x grid spacing
gy = 0.005                          ; Default y grid spacing
gz = 0.005                          ; Default z grid spacing

;coarse and finegrid indexes

IF NOT keyword_set(poscoarsegrid) THEN BEGIN
  coarsezstart=100
  coarsezend=900
  ENDIF ELSE BEGIN
  coarsezstart=floor(poscoarsegrid[0]/gz)
  coarsezend=floor(poscoarsegrid[1]/gz)
  ENDELSE
  

;y position for cathode
IF NOT KEYWORD_SET(posy) then BEGIN
  slice=reform(WP_Cath[*,950])
  y=where(slice eq max(slice))
ENDIF ELSE y = floor(posy/gy) 

;------ HOLE MOTION --------
;In the following, hole motion along the electric field lines are obtained

xh_actual = xstart             ; Define x position of hole along the grid
xhv = xh_actual

th_actual=0.                        ; Starting time

x = floor(xstart/gx)                          ; Initial hole position in x
z = floor(zstart/gz)                          ; Initial hole position in z

zh_actual= zstart

Qr_h      = -1.                     ; At xstart and zstart initial charge is 1.
QT_h[x,z] = 0.                      ; At xstart and zstart initial trapped charge is 0.
QTindA = 0.                         ; initial induced charges due to trapped holes
QTindC = 0.
QTindST = 0.

QA_ind_h  = Qr_h*WP_Ano[x,z]        ; Initial induced Charge on the anode site 
QC_ind_h  = Qr_h*WP_Cath[y,z]       ; Initial induced Charge on the cathode site 
QST_ind_h = Qr_h*WP_ST[x,z]         ; Initial induced Charge on the steering electodes 

t=0.                                ; Starting time

;------ OBTAIN INDUCED CHARGES WITH RESPECT TO THE DIRECTON OF ELECTRIC FIELD ------ 

loopcheck=1
WHILE ((z NE 1000) AND (Abs(Efieldz[x,z]) GT 1.) AND loopcheck) DO BEGIN     

; Start while loop, except z=0 calculate actual x dimension and time 
; Check electric field and make sure electron moves


IF ((z LT coarsezstart) OR (z GT coarsezend)) THEN gz=0.005 ELSE gz=0.025


Dth = gz/abs(mobh*Efieldz[x,z])          ; Obtain time step
t = t+Dth      
th_actual = [th_actual,t]           ; In order to find in terms of nanosecond, I multiplied by *(1*E9)

Dxh = mobh*Efieldx[x,z]*Dth           ; Obtain x step
xhv = xhv + Dxh

L = Sqrt(Dxh^2+gz^2)
L_h = (tauh*mobh)*sqrt(Efieldx[x,z]^2+Efieldz[x,z]^2)  ; Le is the minority carrier diffusion length.

QT_h[x,z] = Qr_h*(1.-Exp(-L/L_h))    ; Trapped charge along the field lines
Qr_h      = Qr_h*Exp(-L/L_h)         ; Remaining induced charge after trapping
QTindA=QTindA+(QT_h[x,z]*WP_Ano[x,z])    ;this is an approximation that may be problematic for large x movements
QTindC=QTindC+(QT_h[x,z]*WP_Cath[y,z])    ;this is an approximation that may be problematic for large x movements
QTindST=QTindST+(QT_h[x,z]*WP_ST[x,z])    ;this is an approximation that may be problematic for large x movements

;keep in the detector
IF xhv GE 19.54 THEN xhv=19.54
IF xhv LT 0. THEN xhv=0

;----- CHECK THE DIRECTION OF ELECTRIC FIELD LINES -------
; Holes move through the cathode

IF Efieldz[x,z] LT 0 THEN BEGIN        ; Define the Electric field lines.  
                                        
   IF ((z LT coarsezstart) OR (z GT coarsezend)) THEN z=z-1 ELSE z=z-5

ENDIF ELSE BEGIN
 
   IF ((z LT coarsezstart) OR (z GT coarsezend)) THEN z=z+1 ELSE z=z+5

ENDELSE

x=floor(xhv/gx+0.5)                  ; Define new x position in the nearest grid point

IF ((Efieldz[x,z] LT 0.) AND (Abs(Dxh/gx) LT 1.)) THEN BEGIN
   loopcheck=0 
   print, 'motion will be stopped here to avoid loop'
ENDIF

xh_actual = [xh_actual,xhv]
zh_actual = [zh_actual,z*0.005]

QA_ind_h = [QA_ind_h, Qr_h*WP_Ano[x,z] + QTindA]     ; Final induced charge on anode site
QC_ind_h = [QC_ind_h, Qr_h*WP_Cath[y,z] + QTindC]   ; Final induced charge on cathode site
QST_ind_h = [QST_ind_h, Qr_h*WP_ST[x,z] + QTindST]     ; Final induced charge on steering electrode site

IF verbose THEN $
   IF (((z mod 10) eq 0) OR (z LT 10)) THEN $
      print, x, z, t, QA_ind_h[n_elements(QA_ind_h)-1],QC_ind_h[n_elements(QC_ind_h)-1]

;IF (((z mod 10) eq 0) OR (z LT 10)) THEN print, x, z, zh_actual[n_elements(zh_actual)-1], gz
ENDWHILE

IF (plotout OR plotps) THEN BEGIN

  IF plotps THEN BEGIN
    SET_PLOT,'ps'
    IF NOT KEYWORD_SET(namef) then namef='holemotion.ps'
    device, filename=namef
    ENDIF
  
  IF NOT plotps THEN window,1,xsize=800,ysize=200
  plot,xh_actual,zh_actual,yrange=[0.,5.],xtitle='Distance Along Detector(mm)',$
    ytitle='depth(mm)',title='Hole',xrange=[0.,20.],linestyle=2
    
  ; Define the placement of anodes
  obox,0.337,0,0.637,0.1
  obox,1.311,0,1.611,0.1
  obox,2.285,0,2.585,0.1
  obox,3.709,0,3.909,0.1
  obox,5.033,0,5.233,0.1
  obox,6.357,0,6.557,0.1
  obox,7.781,0,7.881,0.1
  obox,9.105,0,9.205,0.1
  obox,10.429,0,10.529,0.1
  obox,11.753,0,11.853,0.1
  obox,12.727,0,13.027,0.1
  obox,13.901,0,14.201,0.1
  obox,15.075,0,15.375,0.1
  obox,16.049,0,16.649,0.1
  obox,17.323,0,17.923,0.1
  obox,18.595,0,19.195,0.1
  
  IF NOT plotps THEN window,2,xsize=500,ysize=500
  plot,th_actual*1E9, QA_ind_h,xtitle='Time (ns)',ytitle='Q/Qo',title='Anode';,xrange=[0,100]
  IF NOT plotps THEN window,3,xsize=500,ysize=500
  plot, th_actual*1E9, QC_ind_h,xtitle='Time (ns)',ytitle='Q/Qo',title='Cathode';,xrange=[0,100]
  IF NOT plotps THEN window,4,xsize=500,ysize=500
  plot, th_actual*1E9, QST_ind_h,xtitle='Time (ns)',ytitle='Q/Qo',title='Steering Electrode';,xrange=[0,50]

  IF plotps THEN BEGIN
    device,/close
    IF !version.os_family EQ 'unix' THEN SET_PLOT,'x' ELSE SET_PLOT,'WIN'
    ENDIF

ENDIF


END
