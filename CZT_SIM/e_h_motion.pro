; PURPOSE:vDo electron and hole motion, merge signals to get the total signal

pro e_h_motion, xstart,zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST, $
 t,qa,qc,qst, ypos=posy, etau=taue, htau=tauh, emob=mobe, hmob=mobh,$
 te_actual=te_actual, xe_actual=xe_actual, ze_actual=ze_actual, $
 QA_ind_e=QA_ind_e, QC_ind_e=QC_ind_e, QST_ind_e=QST_ind_e, $
 th_actual=th_actual, xh_actual=xh_actual, zh_Actual=zh_actual,$
 QA_ind_h=QA_ind_h, QC_ind_h=QC_ind_h, QST_ind_h=QST_ind_h, coarsegridpos=poscoarsegrid, $
 plotout=plotout, plotps=plotps, fname=namef
 
 
;INPUTS
;xstart: start position in the x direction in mm
;zstart: start position in the z direction in units of fine grid
;Efieldx: x component of the electric field
;Efieldz: z component of the electric field
;WP_Ano: Weihgting potential of the anode
;WP_Cath: Weighting potential of the cathode
;WP_ST: Weighting potential of the steering electrode
;
;OPTIONAL INPUTS
;taue(h): trapping time of electrons (holes)
;mobe(h) : electron (hole) mobility
;posy : fixed y position for calculating cathode signal. If not given, assumed to be the center
;of the cathode
;fname : name of the output postscript file
;poscoarsegrid : one can set where coarse gridding starts and end default=[0.5,4.5] mm

;
;OPTIONAL OUTPUTS
;te(h)_actual: time variable with respect to the motion of electrons (holes)
;xe(h)_actual: actual x position with respect to the motion of electrons (holes)
;ze(h)_actual: actual z position with respect to the motion of electrons (holes)
;QA_ind_e(h): Induced charge of electrons (holes) on the anode side
;QC_ind_e(h): Induced charge of electrons (holes) on the cathode side
;QST_ind_e(h): Induced charge of electrons (holes) on the steering electrodes
;
;OPTIONS
;plotout: If this option is selected, user gets plots on the screen
;plotps: If this option is selected, user gets plots as a ps file

;=====NOTES BUG FIXES
;
;18 August 2011, poscoarsegrid keyword added
 
IF NOT keyword_set(plotout) THEN plotout=0
IF NOT keyword_set(plotps) THEN plotps=0


electron_motion, xstart, zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST,$
 te_actual, xe_actual, ze_actual, QA_ind_e, QC_ind_e, QST_ind_e,$
   ypos = posy, etau=taue, emob=mobe, coarsegridpos=poscoarsegrid, plotout=0, plotps=0
   
hole_motion, xstart, zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST,$
 th_actual, xh_actual, zh_actual, QA_ind_h, QC_ind_h, QST_ind_h,$
   ypos = posy, htau=tauh, hmob=mobh, coarsegridpos=poscoarsegrid, plotout=0, plotps=0
      
xx = where(th_actual GT max(te_actual))
t = [te_actual,th_actual[xx]]

; Interpolation of Holes (for induced charge on Anode side)

QAH = INTERPOL(QA_ind_h,th_actual,te_actual)                ; Interpolation of induced hole charge in anode side vectors for irregular time points. 

  Q1A = QAH + QA_ind_e                                      ; The signal consists of two parts, a rapid componebt due to electrons drifting away from the cathode
  Q2A = QA_ind_e(n_elements(te_actual)-1) + QA_ind_h(xx)    ; and a slow component due to hole approaching the cathodes.
  qa  = [Q1A,Q2A]

; Interpolation of Holes (for induced charge on Cathode side)

QCH = INTERPOL(QC_ind_h,th_actual,te_actual)                ; Interpolation of induced hole charge in cathode side vectors for irregular time points.
  
  Q1C = QCH + QC_ind_e
  Q2C = QC_ind_e(n_elements(te_actual)-1) + QC_ind_h(xx)
  qc  = [Q1C,Q2C]
  
QSTH = interpol(QST_ind_h,th_actual,te_actual)                ; Interpolation of induced hole charge in steering electrode side vectors for irregular time points.
  
  Q1ST = QSTH + QST_ind_e
  Q2ST = QST_ind_e(n_elements(te_actual)-1) + QST_ind_h(xx)
  qst  = [Q1ST,Q2ST]

;fname='C:\Users\Ozge\Desktop\Modelling\Anode5_1.csv'
;write_csv,fname,xe_actual,ze_actual,qa,qc,qst,t,HEADER=xe,ze,qa,qc,qst,t

    IF (plotout or plotps) THEN BEGIN
    
    IF plotps THEN BEGIN
    SET_PLOT,'ps'
    IF NOT KEYWORD_SET(namef) then namef='ehmotion.ps'
    device, filename=namef
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
  
    IF NOT plotps THEN window,2,xsize=400,ysize=400
    plot,t*1.e9,qa,xtitle='Time (ns)',ytitle='Q/Qo',title='Anode';,xrange=[0,200]
  
    IF NOT plotps THEN window,3,xsize=400,ysize=400
    plot,t*1.e9,qc,xtitle='Time (ns)',ytitle='Q/Qo',title='Cathode';,xrange=[0,200]
  
    IF NOT plotps THEN window,4,xsize=400,ysize=400
    plot,t*1.e9,qst,xtitle='Time (ns)',ytitle='Q/Qo',title='Steering Electrode';,xrange=[0,200]
   
   IF plotps THEN BEGIN
    device,/close
    IF !version.os_family EQ 'unix' THEN SET_PLOT,'x' ELSE SET_PLOT,'WIN'
    ENDIF
   
   
    ENDIF 

END