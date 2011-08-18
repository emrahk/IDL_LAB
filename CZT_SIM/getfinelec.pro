;determine the anode, sterring electrode or the gap based on the steering electrode signal

pro getfinelec, finalx, finelec, wpa, wpst, wpthresh=threshwp

;INPUTS
;
;finalx : the x position in mm at the end of the electron motion
;wpa    : The weighting potential of anodes
;wpst   : The weitghting potential of steering electrodes
;
;OUTPUT
;
;finelec : final electrode, a string with Ax for anode, Sx for steering electrode,
;          and G for gap, where x stand for anode number or steering electrode number
;
;OPTIONAL INPUT
;
;threshwp : threshold weighting potential to determine the boundary of electrodes, default 0.8

IF NOT keyword_set(threshwp) THEN threshwp=0.8
;It is best to use weighting potentials
;first determine rough position

pitch=19.54/16.
an = floor(finalx/pitch)
cn = floor(finalx/pitch)
;the steering electrode pitch is irregular, need a trick to find the
;SE number
selimits=[4.370,7.970, 11.560, 15.170, 19.54] 
setest=sort([selimits,finalx])
sen=where(setest eq 5)

;print, 'Anode no: ',an
;print, 'Cathode no: ',cn
;print, 'Steering no: ',sen

;now determine precisely how it behaves

wpaline=reform(wpa[an,*,2])
wpstline=reform(wpst[sen,*,2])

;convert finalx to x
x=floor(finalx/0.005)

finelec='G'

IF wpaline[x] GT threshwp THEN finelec='A'+strtrim(string(an+1),1)
IF wpstline[x] GT threshwp THEN finelec='S'+strtrim(string(sen+1),1)


END