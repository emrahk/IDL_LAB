; PURPOSE: READ SINGLE WEIGHTING POTENTIAL COMSOL OUTPUT FILE AND ARRANGE IT TO BE USED IN SIMULATION

pro read_single_wp, wpout, resolution=resolution,plotc=plotc, showt=showt, $
  data_dir=dir, infile=filein

;OUTPUTS
;
;wpout : output weighting potential file to be used in the simulation programs

;OPTIONAL INPUTS
;
;resolution: If this option is selected, user can change the grid spacing
;poltc: If this option is selected, user gets plot of the contour
; showt: if set, triangles are shown
; infile: If specified, this is the filename read as dir+infile. If not specified,
;         file is picked with a dialog window
; data_dir: directory that holds the input files
;
;23 August 2011, if a fine grid is used, then read_table limits the table size if actual 
;size is not given. This is fixed by first determining number of lines. Same fix should go 
;into reading weighting potential file.

IF NOT KEYWORD_SET(showt) THEN showt=0
IF NOT KEYWORD_SET(plotc) THEN plotc=0
IF NOT KEYWORD_SET(filein) THEN pickf=1 else pickf=0

;The magic numbers are set by Ozge's initial setup of the simulation area

IF NOT keyword_set(resolution) THEN resolution=[4709,1841]
IF NOT keyword_set(dir) THEN dir='/Users/emrahkalemci/CZTMODEL/COMSOL_OUT/WPA/'

IF pickf THEN infile=dialog_pickfile(/READ,filter='*.txt',title='Pick Weighting Potential File',PATH=dir) ELSE $
  infile=dir+filein

;read data
nlines=file_lines(infile)
aep=read_table(infile,head=8,nmax=nline)
x1 = aep(0,*) & z1 = aep(1,*) & V1 = aep(2,*)

; Triangulation of Irregular Data
triangulate, x1, z1, tri1, b1          ; Obtain triangulation

; Interpolates irregularly-gridded data to a regular grid from a triangulation.

nWP = trigrid(x1,z1,V1,tri1,extra=b1,nx=resolution[0],ny=resolution[1],$
  xgrid=xg,ygrid=yg,/quintic)

; Crops the CZT detector geometry

xx1=where(xg ge 0.)
zz1=where(yg ge 0.)
xx2=where(xg ge 19.54)
zz2=where(yg ge 5.)

; Finally Regularly gridded data is obtained

wpout  = nWP[xx1[0]:xx2[0],zz1[0]:zz2[0]]

IF showt THEN BEGIN

  FOR i = 0, n_elements(tri1)/3-1 DO BEGIN  ; Show Triangles
    t1=[tri1[*,i],tri1[0,i]]
    plots, x1[t1], z1[t1]
    ENDFOR

ENDIF

IF plotc THEN BEGIN

levels1=[0.05,0.1,0.3,0.5,0.7,1]
c_labels1=[1,1,1,1,1,0]

; Weighting Contour Plot from Anode Site
contour,wpout,levels=levels1,c_labels=c_labels1,$
          xtitle='Distance (mm)',ytitle='Depth (mm)',$
          title='Weighting Potential Contour',$
          /xstyle,/ystyle,yr=[0,1000],xr=[0,4000],$
          xtickname=['0','5','10','15','20'],ytickname=['5','4','3','2','1','0']

ENDIF


END

