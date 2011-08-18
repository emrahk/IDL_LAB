; THIS PROGRAM follows a single track for an electron for plotting purposes

pro single_track, xstart, zstart, Efieldx, Efieldz, xe_actual, ze_actual, $
  plotout=plotout, emob=mobe, verbose=verbose

;INPUTS
;xstart: start position in the x direction in mm
;zstart: start position in the z direction in mm
;Efieldx: x component of the electric field
;Efieldz: z component of the electric field
;
;OUTPUTS
;xe_actual : x position in mm
;ze_actual : z position in mm
;
;OPTIONAL INPUTS
;plotout: If this option is selected, user gets plots on the screen
;verbose : if set print out the warnings
;mobe : electron mobility

IF NOT keyword_set(plotout) THEN plotout=0
IF NOT keyword_set(verbose) THEN verbose=0

aa = size(Efieldz)

IF NOT KEYWORD_SET(mobe) THEN mobe=1E5 ; mm^2/V.s, electron mobility
z_thick = 5.0                       ; mm. Detector z thickness
x_length = 19.54                    ; mm. Detector x length

gx = 0.005                         ; Default x grid spacing in mm
gz = 0.005                          ; Default z grid spacing in mm

;------ ELECTRON MOTION --------
;In the following, electron motion along the electric field lines are obtained

xe_actual = xstart               ; Obtain actual x position of electron along the grid at starting point
xev = xe_actual                 ; record for later use
ze_actual= zstart               ;record for the full array

te_actual=0.                        ; Initial actual time

x = floor(xstart/gx)                ; Initial electron position in x
z = floor(zstart/gz)                ; Initial electron position in z



t=0.                                ; Starting time

;------ OBTAIN INDUCED CHARGES WITH RESPECT TO THE DIRECTON OF ELECTRIC FIELD ------

loopcheck=1

WHILE ((z NE 0) AND (Abs(Efieldz[x,z]) GT 3.) AND loopcheck) DO BEGIN

; Start while loop, except z=0 calculate actual x dimension and time
; Check electric field and make sure electron moves

IF (z LT 500 or z GT 900) THEN gz=0.005 ELSE gz=0.025

Dte = gz/(mobe*Efieldz[x,z])          ; Obtain time step
t = t+Dte
te_actual = [te_actual,t]           ; In order to find in terms of nanosecond, I multiplied by *(1*E9)

Dxe = -mobe*Efieldx[x,z]*Dte          ; Obtain x step, since electron has negative charge, multiplied with -1.
xev = xev + Dxe                     ;actual x position

;keep in the detector
IF xev GE 19.54 THEN xev=19.54
IF xev LT 0. THEN xev=0

;----- CHECK THE DIRECTION OF ELECTRIC FIELD LINES -------
; Electron moves through the anode

IF Efieldz[x,z] LT 0 THEN BEGIN          ; Obtain the Electric field lines.

   IF (z LT 500 or z GT 900) THEN z=z+1 ELSE z=z+5

ENDIF ELSE BEGIN

   IF (z LT 500 or z GT 900) THEN z=z-1 ELSE z=z-5

ENDELSE

x=floor(xev/gx+0.5)                       ; Obtain new x position in the nearest grid point
;make sure x stays in detector

IF x GE aa[1] THEN BEGIN
  IF verbose THEN print,'at the edge of detector, at 19.54'
  x=aa[1]-1L
  ENDIF
  
IF x LE 0. THEN BEGIN
  IF verbose THEN print,'at the edge of detector, at 0'
  x=0
  ENDIF
  
IF ((Efieldz[x,z] LT 0.) AND (Abs(Dxe/gx) LT 1.)) THEN BEGIN
   loopcheck=0 
   IF verbose THEN print, 'motion will be stopped here to avoid loop'
ENDIF

xe_actual = [xe_actual,xev]
ze_actual = [ze_actual,z*0.005]


ENDWHILE

IF (plotout) THEN BEGIN

 
  window,1,xsize=800,ysize=200
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

ENDIF


END
