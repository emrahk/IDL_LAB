;This program calculates induced charges from a given initial position
;for the corresponding anode, cathode and the given number of
;neighbors

pro nearneighbor, xpos, ypos, zpos, nn, wpaall, wpcall, wpstall, efx, efz,$
                  t, qa_out, qc_out, qst_out, $
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
;
;OUTPUTS
;
;t : time
;qa_out: output induced charge on anodes with n neighbors
;qc_out: output induced charge on cathdes with n neighbors
;qst_out: output induced charge on steering electrodes with n neighbors

IF NOT keyword_set(plotps) THEN plotps=0
IF NOT keyword_set(plotout) THEN plotout=0

;Determine the anode, cathode and steering electrode triple for the
;given position.

;define initially the outputs
qa_out=fltarr(2*nn+1,1000)
qc_out=fltarr(2*nn+1,1000)
qst_out=fltarr(2*nn+1,1000)


pitch=19.54/16.
an = floor(xpos/pitch)
cn = floor(ypos/pitch)
;the steering electrode pitch is irregular, need a trick to find the
;SE number
selimits=[4.370,7.970, 11.560, 15.170, 19.54] 
setest=sort([selimits,xpos])
sen=where(setest eq 5)

print, 'Anode no: ',an
print, 'Cathode no: ',cn
print, 'Steering no: ',sen

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
                   xh_actual = xh_actual, zh_actual = zh_actual, $
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
    ENDIF
       
    IF NOT plotps THEN window,1,xsize=400,ysize=400
    plot,xe_actual,ze_actual,yrange=[0.,5.],xtitle='Distance Along Detector(mm)',ytitle='depth(mm)',xrange=[0.,20.]
    oplot, xh_actual,zh_actual, linestyle=2, thick=1
       ;Define the placement of anodes
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
 
;ccol=0
 
    FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(an-nn+i),1)
       IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((2*nn)+1))
       IF ((NOT plotps) AND (i eq 0)) THEN window,2,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qa_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Anode', color=ccol,$
                             yrange=[-0.2,1.1],/ystyle ELSE $
                       oplot,t*1.e9,qa_out[i,*],color=ccol
       IF (an-nn+i) GE 0 THEN BEGIN
          oplot, !X.crange[1]*[0.7,0.8], [0.5,0.5]+(i*0.1), color=ccol
          XYOUTS, !X.crange[1]*0.82, 0.49+(i*0.1), ptext
       ENDIF
       ENDFOR
    FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(cn-nn+i),1) 
       IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((2*nn)+1))

       IF ((NOT plotps) AND (i eq 0)) THEN window,3,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qc_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Cathode', color=ccol, $
                             yrange=[-1.,.1],/ystyle ELSE $
                       oplot,t*1.e9,qc_out[i,*],color=ccol
       IF (cn-nn+i) GE 0 THEN BEGIN
          oplot, !X.crange[1]*[0.2,0.3], [-0.8,-0.8]+(i*0.1), color=ccol
          XYOUTS, !X.crange[1]*0.17, -0.81+(i*0.1), ptext
       ENDIF

       ENDFOR
  
       FOR i=0,2*nn DO BEGIN
       ptext=strtrim(string(sen-nn+i),1)
        IF (i eq 0) THEN BEGIN
          IF plotps THEN ccol=0 ELSE ccol=255
       ENDIF ELSE ccol=floor(255*i/((2*nn)+1))

       IF ((NOT plotps) AND (i eq 0)) THEN window,4,xsize=400,ysize=400
       IF (i eq 0) THEN plot,t*1.e9,qst_out[i,*],xtitle='Time (ns)',$
                             ytitle='Q/Qo',title='Steering Electrode',$
                             color=ccol, yrange=[-1.,1.],/ystyle ELSE $
                       oplot,t*1.e9,qst_out[i,*],color=ccol
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
