; THIS PROGRAM DETERMINES THE ELECTRON MOTION INSIDE A DETECTOR ALONG THE FIELD LINES
; AND CALCULATES THE INDUCED CHARGE ON A SPECIFIC ELECTRODE.

pro electron_motion, xstart, zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST,$
 te_actual, xe_actual, ze_actual, QA_ind_e, QC_ind_e, QST_ind_e,$
   ypos = posy, etau=taue, emob=mobe, plotout=plotout, plotps=plotps, fname=namef

;INPUTS
;xstart: start position in the x direction in mm
;zstart: start position in the z direction in units of fine grid
;Efieldx: x component of the electric field
;Efieldz: z component of the electric field
;WP_Ano: Weihgting potential of the anode
;WP_Cath: Weighting potential of the cathode
;
;OPTIONAL INPUTS
;taue: trapping time of electrons
;mobe : electron mobility
;posy : fixed y position for calculating cathode signal. If not given, assumed to be the center
;of the cathode
;
;OUTPUTS
;te_actual: time variable with respect to the motion of electrons
;xe_actual: actual x position with respect to the motion of electrons
;ze_actual: actual z position with respect to the motion of electrons
;QA_ind_e: Induced charge of electrons on the anode side
;QC_ind_e: Induced charge of electrons on the cathode side
;QST_ind_e: Induced charge of electrons on the steering electrodes
;
;OPTIONAL OUTPUTS
;plotout: If this option is selected, user gets plots on the screen
;plotps: If this option is selected, user gets plots as a ps file
;namef: output postscript filename

IF NOT keyword_set(plotout) THEN plotout=0
IF NOT keyword_set(plotps) THEN plotps=0

aa = size(Efieldz)

QT_e = dblarr(aa[1],aa[2])          ; Trapped Charge array

IF NOT KEYWORD_SET(taue) THEN taue=3E-6 ; electron trapping time in s
IF NOT KEYWORD_SET(mobe) THEN mobe=1E5 ; mm^2/V.s, electron mobility
z_thick = 5.0                       ; mm. Detector z thickness
x_length = 19.54                    ; mm. Detector x length

gx = 0.005                          ; Default x grid spacing in mm
gz = 0.005                          ; Default z grid spacing in mm

;y position for cathode
IF NOT KEYWORD_SET(posy) then BEGIN
  slice=reform(WP_Cath[*,950])
  posy=where(slice eq max(slice))
  ENDIF

;------ ELECTRON MOTION --------
;In the following, electron motion along the electric field lines are obtained

xe_actual = xstart               ; Obtain actual x position of electron along the grid at starting point
xev = xe_actual                 ; record for later use
ze_actual= zstart               ;record for the full array

te_actual=0.                        ; Initial actual time

x = floor(xstart/gx)                ; Initial electron position in x
z = floor(zstart/gz)                ; Initial electron position in z



Qr_e = 1.                           ; At start position remaining charge is all the charge
QT_e[x,z] = 0.                      ; At xstart and zstart initial trapped charge is 0.
QTindA = 0.                         ; initial induced charges due to trapped electrons
QTindC = 0.
QTindST = 0.

QA_ind_e  = Qr_e*WP_Ano[x,z]        ; Initial induced Charge on the anode site
QC_ind_e  = Qr_e*WP_Cath[posy,z]       ; Initial induced Charge on the cathode site
QST_ind_e = Qr_e*WP_ST[x,z]         ; Initial induced Charge on the steering electodes

t=0.                                ; Starting time

;------ OBTAIN INDUCED CHARGES WITH RESPECT TO THE DIRECTON OF ELECTRIC FIELD ------

WHILE ((z NE 0) AND (Abs(Efieldz[x,z]) GT 1.)) DO BEGIN

; Start while loop, except z=0 calculate actual x dimension and time
; Check electric field and make sure electron moves

IF (z LT 100 or z GT 900) THEN gz=0.001 ELSE gz=0.005

Dte = gz/(mobe*Efieldz[x,z])          ; Obtain time step
t = t+Dte
te_actual = [te_actual,t]           ; In order to find in terms of nanosecond, I multiplied by *(1*E9)

Dxe = -mobe*Efieldx[x,z]*Dte          ; Obtain x step, since electron has negative charge, multiplied with -1.
xev = xev + Dxe                     ;actual x position

L = Sqrt(Dxe^2+gz^2)                ;total distance travelled
L_e = (taue*mobe)*sqrt(Efieldx[x,z]^2+Efieldz[x,z]^2)  ; Le is the minority carrier diffusion length.

QT_e[x,z] = Qr_e*(1.-Exp(-L/L_e))        ; Trapped charge along the field lines
Qr_e = Qr_e*Exp(-L/L_e)                  ; Remaining induced charge after trapping
QTindA=QTindA+(QT_e[x,z]*WP_Ano[x,z])    ;this is an approximation that may be problematic for large x movements
QTindC=QTindC+(QT_e[x,z]*WP_Cath[posy,z])    ;this is an approximation that may be problematic for large x movements
QTindST=QTindST+(QT_e[x,z]*WP_ST[x,z])    ;this is an approximation that may be problematic for large x movements

;----- CHECK THE DIRECTION OF ELECTRIC FIELD LINES -------
; Electron moves through the anode

IF Efieldz[x,z] LT 0 THEN BEGIN          ; Obtain the Electric field lines.

   IF (z LT 100 or z GT 900) THEN z=z+1 ELSE z=z+5

ENDIF ELSE BEGIN

   IF (z LT 100 or z GT 900) THEN z=z-1 ELSE z=z-5

ENDELSE

x=floor(xev/gx+0.5)                       ; Obtain new x position in the nearest grid point
xe_actual = [xe_actual,xev]
ze_actual = [ze_actual,z*0.005]

QA_ind_e = [QA_ind_e, Qr_e*WP_Ano[x,z] + QTindA]     ; Final induced charge on anode site
QC_ind_e = [QC_ind_e, Qr_e*WP_Cath[posy,z] + QTindC]   ; Final induced charge on cathode site
QST_ind_e = [QST_ind_e, Qr_e*WP_ST[x,z] + QTindST]     ; Final induced charge on steering electrode site

IF (((z mod 10) eq 0) OR (z LT 10)) THEN print, x,z, L_e, L, QA_ind_e[n_elements(te_actual)-1],QC_ind_e[n_elements(te_actual)-1]
;IF (((z mod 10) eq 0) OR (z LT 10)) THEN print, x,z,ze_actual[n_elements(ze_actual)-1],gz
ENDWHILE

IF (plotout or plotps) THEN BEGIN

  IF plotps THEN BEGIN
    SET_PLOT,'ps'
    IF NOT KEYWORD_SET(namef) then namef='electronmotion.ps'
    device, filename=namef
    ENDIF
 
  IF NOT plotps THEN window,1,xsize=500,ysize=500
  plot,xe_actual,ze_actual,yrange=[0.,5.],xtitle='Distance Along Detector(mm)',ytitle='depth(mm)',title='Electron',xrange=[0.,20.]
  ; Obtain the placement of anodes
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
  plot, te_actual*1E9, QA_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Anode';,xrange=[0,50]
  IF NOT plotps THEN window,3,xsize=500,ysize=500
  plot, te_actual*1E9, QC_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Cathode';,xrange=[0,50]
  IF NOT plotps THEN window,4,xsize=500,ysize=500
  plot, te_actual*1E9, QST_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Steering Electrode';,xrange=[0,50]

  IF plotps THEN BEGIN
    device,/close
    IF !version.os_family EQ 'unix' THEN SET_PLOT,'x' ELSE SET_PLOT,'WIN'
    ENDIF

ENDIF


END