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
;finelec : is a structure that holds the anode number, weighying potential, steering 
;           electrode number, weighting potential, and where the electron ends up
;
;OPTIONAL INPUT
;
;threshwp : threshold weighting potential to determine the boundary of electrodes, default 0.8
;
;Note to programmer, there seems something wrong with comsol out, or how IDL converts
;from irregular grid to regular grid. When those problems are fixed I believe
;this program can be simplified


IF NOT keyword_set(threshwp) THEN threshwp=0.8
;It is best to use weighting potentials

x=floor(finalx/0.005)

wpaline=reform(wpa[*,x,2])
wpstline=reform(wpst[*,x,2])


;get anode limits
anlimits=lonarr(32)
FOR i=0,15 DO BEGIN
  limsind=where(wpa[i,*,2] GE 0.5)
  anlimits[i*2]=min(limsind)
  anlimits[i*2+1L]=max(limsind)
  ENDFOR


IF max(wpaline) GT 0.03 THEN BEGIN
  an=where(wpaline eq max(wpaline))
  wepa=wpaline[an]
ENDIF ELSE BEGIN
  ;things get complicated if the electron goes to gap, 
  ;it is difficult to determine closest anode
  prox=abs(x-anlimits)
  minv=min(prox,k)
  an=k/2
  wepa=wpa[an,x,2]
  ENDELSE

;get steering electrode limits
selimits=lonarr(10)
FOR i=0,4 DO BEGIN
  limsind=where(wpst[i,*,2] GE 0.5)
  selimits[i*2]=min(limsind)
  selimits[i*2+1L]=max(limsind)
  ENDFOR

IF max(wpstline) GT 0.03 THEN BEGIN
  sen=where(wpstline eq max(wpstline))
  wepst=wpstline[sen]
ENDIF ELSE BEGIN
  ;things get complicated if the electron goes to gap, 
  ;it is difficult to determine closest steering electrode
  prox=abs(x-selimits)
  minv=min(prox,k)
  sen=k/2
  wepst=wpst[sen,x,2]
  ENDELSE


finelec=create_struct('an',an,'sen',sen,'wpa',wepa,'wpst',wepst,'hit','G')

IF wepa GT threshwp THEN finelec.hit='A'
IF wepst GT threshwp THEN finelec.hit='S'


END