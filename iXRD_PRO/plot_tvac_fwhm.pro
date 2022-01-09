pro plot_tvac_fwhm, inpstr, ps=ps, fname=namef

; This program plots FWHM of TVAC tests with the given input structure
;
; INPUTS
;
; inpstr: input structure with all the information
;
; OUTPUTS
;
; NONE as variable, a plot
;
; OPTIONAL INPUTS
;
; ps: if set plot postscript
; fname: if set name of the output postscript plot
;
; USES
;
; NONE
;
; USED BY
;
; NONE
;
; LOGS
;
; Created by EK Jan 2022
;

IF NOT keyword_set(ps) THEN ps=0
IF (ps AND NOT keyword_set(fname)) THEN fname='allfwhmcent.eps'
  


loadct,4
colcode=[184,120,40,150];

if ps then begin
   colcode=[0,120,40,150];
   set_plot, 'ps'
   device,/color
;   loadct,5
   device,/encapsulated
   device, filename = fname
   device, yoffset = 2
   device, ysize = 28.
   ;device, xsize = 12.0
   !p.font=0
   device,/times
endif else BEGIN
   device,decomposed=0
   colcode=[0,120,180,220];
ENDELSE

cs=1.3
PLOTSYM,0,1,/FILL

multiplot, [1,2], mxtitle='Temperature (Celsius)',mxtitsize=1.2

temp=(inpstr.tdb[0]+inpstr.tdb[1])/2.
tempe=abs((inpstr.tdb[1]-inpstr.tdb[0])/2.)

good0=[0,1,2,3,4,5,12,13,14,17]
cut0=[6,7,11,16]
noise0=[8,9,10,15,18]



ploterror,temp[good0],inpstr[good0].fwhm[0,0],$
          tempe[good0],inpstr[good0].fwhm[1,0],$
          psym=8,/nohat,charsize=cs,xr=[-15,65],/xstyle,yr=[3.,15.],/ystyle,$
          ytitle='FWHM (channels)',color=colcode[0]

oploterror,temp,inpstr.fwhm[0,1],tempe,inpstr.fwhm[1,1],$
           psym=8,/nohat,color=colcode[1]

oploterror,temp,inpstr.fwhm[0,2],tempe,inpstr.fwhm[1,2],$
           psym=8,/nohat,color=colcode[2]

oploterror,temp,inpstr.fwhm[0,3],tempe,inpstr.fwhm[1,3],$
           psym=8,/nohat,color=colcode[3]

;t1=text([40.,40.,40.,40.],[14.,13.,12.,11.],['Ch0','Ch16','Ch17','Ch24'],/data)

xyouts,50.,13.,'Ch0',size=1.6,color=colcode[0]
xyouts,50.,12.,'Ch16',size=1.6,color=colcode[1]
xyouts,50.,11.,'Ch17',size=1.6,color=colcode[2]
xyouts,50.,10.,'Ch24',size=1.6,color=colcode[3]

oplot,[48.,48.],[13.3,13.3],psym=8,color=colcode[0],symsize=1.3
oplot,[48.,48.],[12.3,12.3],psym=8,color=colcode[1],symsize=1.3
oplot,[48.,48.],[11.3,11.3],psym=8,color=colcode[2],symsize=1.3
oplot,[48.,48.],[10.3,10.3],psym=8,color=colcode[3],symsize=1.3

oplot,[temp[0]-0.8,temp[0]-0.8],[3.,15.],line=2,color=colcode[0]
oplot,[temp[1]+0.8,temp[1]+0.8],[3.,15.],line=2,color=colcode[0]

multiplot

ploterror,temp[good0],inpstr[good0].centch[0,0],$
          tempe[good0],inpstr[good0].centch[1,0],$
          psym=8,/nohat,charsize=cs,xr=[-15,65],/xstyle,yr=[325.,345.],$
          /ystyle, ytitle='CENTROID (channels)',color=colcode[0]

oploterror,temp[cut0],inpstr[cut0].centch[0,0],/nohat,psym=8,$
          tempe[cut0],inpstr[cut0].centch[1,0],color=colcode[0]


oploterror,temp,inpstr.centch[0,1],tempe,inpstr.centch[1,1],$
           psym=8,/nohat,color=colcode[1]

oploterror,temp,inpstr.centch[0,2],tempe,inpstr.centch[1,2],$
           psym=8,/nohat,color=colcode[2]

oploterror,temp,inpstr.centch[0,3],tempe,inpstr.centch[1,3],$
           psym=8,/nohat,color=colcode[3]

oplot,[temp[0]-0.8,temp[0]-0.8],[325.,345.],line=2,color=colcode[0]
oplot,[temp[1]+0.8,temp[1]+0.8],[325.,345.],line=2,color=colcode[0]


multiplot,/default

IF ps THEN BEGIN
  device,/close
  IF !VERSION.OS eq 'Win32' THEN set_plot,'win' ELSE set_plot,'x'
  ENDIF

END
