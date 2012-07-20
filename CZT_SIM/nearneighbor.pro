;This program calculates induced charges from a given initial position
;for the corresponding anode, cathode and the given number of
;neighbors

pro nearneighbor, xpos, ypos, zpos, nn, wpaall, wpcall, wpstall, efx, efz,$
                  t, qa_out, qc_out, qst_out, coarsegridpos=poscoarsegrid, $
                  etau=taue, htau=tauh, emob=mobe, hmob=mobh,$
                  plotout=plotout, plotps=plotps, fname=namef

;INPUTS
;
;xpos, ypos, zpos: x, y, z initial position
;nn : number of neighbors to perform calculation
;wpaall : weighting potential for all anodes
;wpcall :  weighting potential for all cathodes
;wpstall : weighting potential for all steering electrodes
;efx, efz : elextric field comsol file for x and z direction
;
;OPTIONAL INPUTS
;
;plotout: plot the graphs on screen
;plotps: plot the graphs on a postscript file
;namef: name of the postscript file
;taue(h): trapping time of electrons (holes)
;mobe(h) : electron (hole) mobility
;poscoarsegrid : one can set where coarse gridding starts and end default=[0.5,4.5] mm

;
;OUTPUTS
;
;t : time
;qa_out: output induced charge on anodes with n neighbors
;qc_out: output induced charge on cathdes with n neighbors
;qst_out: output induced charge on steering electrodes with n neighbors

;==NOTES, BUG FIXES
;18 August 2011, poscoarsegrid keyword added
;
;21 August 2011, the way anode and steering electrode is set up (at least anode) is incorrect
;this may be partially caused by comsol, but to be consistent we need to determine them
;with a separate program
;
;20 July 2012, steering electrodes are now shown with color

IF NOT keyword_set(plotps) THEN plotps=0
IF NOT keyword_set(plotout) THEN plotout=0


;define initially the outputs
qa_out=fltarr(2*nn+1,1000)
qc_out=fltarr(2*nn+1,1000)
qst_out=fltarr(2*nn+1,1000)

;cathode easy
pitch=19.54/16.
cn = floor(ypos/pitch)

;firt determine the end x position

single_track, xpos, zpos, efx, efz, xac, zac, verbose=0

;then determine the anode and steering electrodes

finxpos=xac(n_elements(xac)-1L)

getfinelec, finxpos, finelec, wpaall, wpstall

print, 'Anode no: ',finelec.an
print, 'Cathode no: ',cn
print, 'Steering no: ',finelec.sen

an=finelec.an
sen=finelec.sen

;Now do it!

FOR i=-nn,nn DO BEGIN
    can=an+i                     ;current anode number
    IF ((can LT 0) OR (can GT 15)) THEN BEGIN
       skipanode=1 
       wpa=reform(wpaall[an,*,*])
       ENDIF ELSE BEGIN 
       skipanode=0
       wpa=reform(wpaall[can,*,*])
    ENDELSE

    ccn=cn+i
    IF ((ccn LT 0) OR (ccn GT 15)) THEN BEGIN
       skipcathode=1 
       wpc=reform(wpcall[cn,*,*])
       ENDIF ELSE BEGIN
       skipcathode=0
       wpc=reform(wpcall[ccn,*,*])
    ENDELSE

    csen=sen+i
    IF ((csen LT 0) OR (csen GT 4)) THEN BEGIN
       skipse=1
       wpst=reform(wpstall[sen,*,*])
       ENDIF ELSE BEGIN
       skipse=0
       wpst=reform(wpstall[csen,*,*])
    ENDELSE

    IF NOT (skipanode AND skipcathode AND skipse) THEN BEGIN
       e_h_motion, xpos,zpos, efx, efz, wpa, wpc, wpst, $
                   t,qa,qc,qst, xe_actual=xe_actual, ze_actual=ze_actual, $
                   xh_actual = xh_actual, zh_actual = zh_actual, coarsegridpos=poscoarsegrid, $
                   ypos=ypos, etau=taue, htau=tauh, emob=mobe, hmob=mobh,$
                   plotout=0, plotps=0
       IF NOT skipanode THEN qa_out[i+nn,0:n_elements(qa)-1L]=qa
       IF NOT skipcathode THEN qc_out[i+nn,0:n_elements(qc)-1L]=qc
       IF NOT skipse THEN qst_out[i+nn,0:n_elements(qst)-1L]=qst
    ENDIF ELSE print,'Skipping as the neighbor is out of boundary'
ENDFOR

IF (plotout or plotps) THEN BEGIN
    device,decomposed=0
    loadct, 12
   
    IF plotps THEN BEGIN
       SET_PLOT,'ps'
       IF NOT KEYWORD_SET(namef) then namef='allneighbors.eps'
       device, filename=namef
       device, /encapsulated
       device, /color
       !p.multi=[0,2,2]
       device, xsize=20
       device, ysize=20
    ENDIF
       
    IF NOT plotps THEN window,1,xsize=1200,ysize=300
    plot,xe_actual,ze_actual,yrange=[0.,5.],$
      xtitle='Distance Along Detector(mm)',ytitle='depth(mm)',$
      xrange=[0.,20.],thick=2
    oplot, xh_actual,zh_actual, linestyle=2, thick=2
       ;Define the placement of anodes
  obox,0.62,0,0.92,0.1
  polyfill,[0.62,0.92, 0.92, 0.62,0.62],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[1.82,2.12, 2.12, 1.82,1.82],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[3.02,3.32, 3.32, 3.02,3.02],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[4.27,4.47, 4.47, 4.27,4.27],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[5.47,5.67, 5.67, 5.47,5.47],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[6.67,6.87, 6.87, 6.67,6.67],[0.,0.,0.1,0.1,0.],color=150
 polyfill,[7.92,8.02, 8.02, 7.92,7.92],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[9.12,9.22, 9.22, 9.12,9.12],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[10.32,10.42, 10.42, 10.32,10.32],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[11.52,11.62, 11.62, 11.52,11.52],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[12.62,12.92, 12.92, 12.62,12.62],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[13.82,14.12, 14.12, 13.82,13.82],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[15.02,15.32, 15.32, 15.02,15.02],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[16.07,16.67, 16.67, 16.07,16.07],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[17.27,17.87, 17.87, 17.27,17.27],[0.,0.,0.1,0.1,0.],color=150
  polyfill,[18.47,19.07, 19.07, 18.47,18.47],[0.,0.,0.1,0.1,0.],color=150
 
 ;Now steering electrodes
obox,0.00000,0,0.320000,0.1
obox,1.22000,0,1.52000,0.1
obox,2.42000,0,2.72000,0.1
obox,3.62000,0,4.14500,0.1
obox,4.59500,0,5.34500,0.1
obox,5.79500,0,6.54500,0.1
obox,6.99500,0,7.79500,0.1
obox,8.14500,0,8.99500,0.1
obox,9.34500,0,10.1950,0.1
obox,10.5450,0,11.3950,0.1
obox,11.7450,0,12.4200,0.1
obox,13.1200,0,13.6200,0.1
obox,14.3200,0,14.8200,0.1
obox,15.5200,0,15.9200,0.1
obox,16.8200,0,17.1200,0.1
obox,18.0200,0,18.3200,0.1
obox,19.2200,0,19.5400,0.1
 
;ccol=0
 
    FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(an-nn+i),1)
       IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((3*nn)+1))
       IF ((NOT plotps) AND (i eq 0)) THEN window,2,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qa_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Anode', color=ccol,$
                             yrange=[-0.2,1.1],/ystyle, thick=2 ELSE $
                       oplot,t*1.e9,qa_out[i,*],color=ccol, thick=2
       IF (an-nn+i) GE 0 THEN BEGIN
          oplot, !X.crange[1]*[0.7,0.8], [0.5,0.5]+(i*0.1), color=ccol
          XYOUTS, !X.crange[1]*0.82, 0.49+(i*0.1), ptext
       ENDIF
       ENDFOR
    FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(cn-nn+i),1) 
       IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((3*nn)+1))

       IF ((NOT plotps) AND (i eq 0)) THEN window,3,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qc_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Cathode', color=ccol, $
                             yrange=[-1.,.1],/ystyle, thick=2 ELSE $
                       oplot,t*1.e9,qc_out[i,*],color=ccol, thick=2
       IF (cn-nn+i) GE 0 THEN BEGIN
          oplot, !X.crange[1]*[0.2,0.3], [-0.8,-0.8]+(i*0.1), color=ccol
          XYOUTS, !X.crange[1]*0.17, -0.81+(i*0.1), ptext
       ENDIF

       ENDFOR
  
       FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(sen-nn+i),1)
        IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((3*nn)+1))

       IF ((NOT plotps) AND (i eq 0)) THEN window,4,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qst_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Steering Electrode',$
                             color=ccol, yrange=[-1.,1.],/ystyle, thick=2 ELSE $
                       oplot,t*1.e9,qst_out[i,*],color=ccol, thick=2
       IF (sen-nn+i) GE 0 THEN BEGIN
          oplot, !X.crange[1]*[0.7,0.8], [-0.8,-0.8]+(i*0.1), color=ccol
          XYOUTS, !X.crange[1]*0.67, -0.81+(i*0.1), ptext
       ENDIF

       ENDFOR
  
 
   IF plotps THEN BEGIN
    device,/close
    IF !version.os_family EQ 'unix' THEN SET_PLOT,'x' ELSE SET_PLOT,'WIN'
    !p.multi=0
    ENDIF
   
   
    ENDIF 


END
