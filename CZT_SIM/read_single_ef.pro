; PURPOSE: READ SINGLE COMSOL OUTPUT ELECTRIC FIELD PAIR AND ARRANGE IT TO BE USED IN SIMULATION

pro read_single_ef, eoutx, eoutz, resolution=resolution,plotc=plotc, showt=showt, $
  data_dir=dir, infile=filein

;OUTPUTS
;
;eoutx : output efield in x direction file to be used in the simulation programs
;
;eoutz : output efield in z direction file to be used in the simulation programs
;
;OPTIONAL INPUTS
;
;resolution: If this option is selected, user can change the grid spacing
;poltc: If this option is selected, user gets plot of the contour
; showt: if set, triangles are shown
; infiles: If specified, this are the filenames read as dir+infiles. If not specified,
;         file is picked with a dialog window.
;         Use as infiles=['fname_efieldx', 'fname_efieldz']
; data_dir: directory that holds the input files

IF NOT KEYWORD_SET(showt) THEN showt=0
IF NOT KEYWORD_SET(plotc) THEN plotc=0
IF NOT KEYWORD_SET(filein) THEN pickf=1 else pickf=0

;why these magic numbers? 
IF NOT keyword_set(resolution) THEN resolution=[4709,1841]
IF NOT keyword_set(dir) THEN dir='/Users/emrahkalemci/CZTMODEL/COMSOL_OUT/EField/'

IF pickf THEN infile=dialog_pickfile(/READ,filter='*.txt',title='Pick Electric Field File',PATH=dir) ELSE $
  infile=dir+filein


;read data
;read electric field
ef=read_table(infile,head=8)
x1 = ef(0,*) & z1 = ef(1,*) & E_x = ef(2,*) & E_z = ef(3,*)

; Triangulation of Irregular Data
triangulate, x1, z1, tri1, b1          ; Obtain triangulation

; Interpolates irregularly-gridded data to a regular grid from a triangulation.
nEfieldx  = trigrid(x1,z1,E_x*0.001,tri1,extra=b1,nx=resolution[0],ny=resolution[1],xgrid=xg,ygrid=yg,/quintic) ;Electric Field is converted to V/mm by multiplying 0.001
nEfieldz  = trigrid(x1,z1,E_z*0.001,tri1,extra=b1,nx=resolution[0],ny=resolution[1],xgrid=xg,ygrid=yg,/quintic) ;Electric Field is converted to V/mm by multiplying 0.001

; Crops the CZT detector geometry

xx1=where(xg ge 0.)
zz1=where(yg ge 0.)
xx2=where(xg ge 19.54)
zz2=where(yg ge 5.)

; Finally Regularly gridded data is obtained

eoutx  = nEfieldx[xx1[0]:xx2[0],zz1[0]:zz2[0]]
eoutz  = nEfieldz[xx1[0]:xx2[0],zz1[0]:zz2[0]]

IF showt THEN BEGIN

  FOR i = 0, n_elements(tri1)/3-1 DO BEGIN  ; Show Triangles
    t1=[tri1[*,i],tri1[0,i]]
    plots, x1[t1], z1[t1]
    ENDFOR

ENDIF

IF plotc THEN BEGIN

Efield = streamline(eoutx,eoutz,ARROW_COLOR="Dodger blue", $
;ARROW_OFFSET=[0.25,0.5,0.75,1], $
STREAMLINE_STEPSIZE=1., $
POSITION=[0.1,0.22,0.95,0.9], $
X_STREAMPARTICLES=11, Y_STREAMPARTICLES=11, $
XTITLE='X', YTITLE='Z', $
TITLE='Electric Field Lines')
ENDIF


END

