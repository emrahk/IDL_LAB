pro reorganize_ixrd,evlist,an_thr, clean,outstr=outstr

;this program creates a structure that holds all share information
;neatly for event lists coming either from the iXRD. Does the
;calibration as well

;rename so that we do not overwrite

  evl=evlist
  
;INPUTS:
;
;evlist: event list array, can be channels or calibrated energies
;an_thr: minimum acceptable anode signal 
;
;OUTPUTS
;clean: structure that holds only events above threshold with planar information
;
;OPTIONAL ARGUMENTS 
;outstr: optional structure with all events, used for diagnostics.
;
;27/09/22
;
;definition of FLAGS
;
; thresh : ?
; single1-3 : see ICD
; double1-6 : see ICD
; mult : see ICD

sz=size(evl)
outstr1=create_struct('flag','','en',fltarr(4),'toten',0.,$
  'det',intarr(4),'caten',0.)
outstr=replicate(outstr1,sz(2))

;seperate cathode and others

evlc=reform(evl(35,*))

evla=evl
evla(35,*)=0 ; do not take into account cathodes

;calibrate the event list (with magic numbers from ALI)

offset=[-344.60590, -352.01546, -323.13059, -329.45215, -320.21995, -338.24382, -330.86060, -326.92740, -350.89782, -338.72305, -332.74665, -330.47653, -314.41177, -281.20112, -310.71130, -295.05040, -308.67800, -280.36221, -300.60477,  0.0000000, -344.76986, -294.80265, -331.00414, -294.87422, -287.39048, -284.68813, -337.40210, -314.37274, -307.18472, -369.66912, -339.42143, -344.81197, -310.03831, -349.19779, -311.41624]

gain=[0.16084625, 0.15813375, 0.14178875, 0.14991374, 0.14466625, 0.15058750, 0.15087751, 0.14320751, 0.16103999, 0.14706625, 0.14323124, 0.14467876, 0.13831125, 0.12436063, 0.13787501, 0.13670126, 0.13592499, 0.12230825, 0.13700625, 0.12500000, 0.15645374, 0.13348250, 0.14787750, 0.13252500, 0.12503751, 0.12562625, 0.15511000, 0.14021000, 0.14155875, 0.16941249, 0.15420374, 0.16094625, 0.13531375, 0.15737376, 0.13791500]

cevl=float(evla) ;calibrated event list

;do not calibrate 0 valued items

FOR i=0, 34 DO BEGIN
   xx=where(cevl[i,*] NE 0)
   FOR j=0, N_ELEMENTS(xx)-1L DO cevl[i,xx[j]]=evla[i,xx[j]]*gain[i]+offset[i]
ENDFOR

;some definitions

  singlep=[12,13,16,17,23,24,25]
  mediump=[1,3,4,5,6,9,10,11,14,15,18,19,20,21,22,27,31,32,33]
  largep=[0,2,7,8,26,28,29,30,34]


;now clean below threshold to avoid wrong summations and continue
noise_events_ind=where(evla lt an_thr, noise_count)
IF noise_count NE 0 THEN evla(noise_events_ind)=0

;following irfan determine singles,doubles,triples and quadrupoles at once

event_ind=where(evla ge an_thr, event_count)
temporary_evl=evla
evla(event_ind)=1
share=total(evla(0:34,*),1)
singles=where(share eq 1)
doubles=where(share eq 2)
mults=where(share gt 2)

dets=(where(evla(*,singles) eq 1) mod 35)
IF doubles[0] ne -1 THEN detd=(where(evla(*,doubles) eq 1) mod 35)

;detm=(where(evla(*,mults) eq 1) mod 16) this is not useful as is

evla=temporary_evl

;start with singles
;find sub-flags

;there could be faster ways, but this is what I can think of now

single1=where(dets eq singlep[0])
FOR k=1, n_elements(singlep)-1 DO BEGIN
   single1k=where(dets eq singlep[k])
   single1=[single1,single1k]
ENDFOR

medium1=where(dets eq mediump[0])
FOR k=1, n_elements(mediump)-1 DO BEGIN
   medium1k=where(dets eq mediump[k])
   medium1=[medium1,medium1k]
ENDFOR

large1=where(dets eq largep[0])
FOR k=1, n_elements(largep)-1 DO BEGIN
   large1k=where(dets eq largep[k])
   large1=[large1,large1k]
ENDFOR


sums=total(cevl(0:34,singles),1) ;summing is stupid with singles
outstr[single1].flag='single1'
outstr[medium1].flag='single2'
outstr[large1].flag='single3'


outstr[singles].en[0]=sums
outstr[singles].toten=sums
outstr[singles].det[0]=dets
outstr[singles].caten=evlc(singles)

;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doubles[0] ne -1 THEN BEGIN
  sums=total(cevl(0:34,doubles),1)
  outstr[doubles].toten=sums
  outstr[doubles].caten=evlc(doubles)


  ;outstr[doubles].flag='double'
  FOR j=0L,n_elements(doubles)-1L DO BEGIN
    dts=[detd[2*j],detd[2*j+1L]]
    ens=cevl(dts,doubles(j))
    ;assign the event to the largest energy
    IF ens[0] ge ens[1] THEN BEGIN
      outstr[doubles(j)].det[0:1]=dts
      outstr[doubles(j)].en[0:1]=ens
    ENDIF ELSE BEGIN
      outstr[doubles(j)].det[0:1]=reverse(dts)
      outstr[doubles(j)].en[0:1]=reverse(ens)
   ENDELSE
   ;determine type of double
    fac=where(singlep eq dts[0],ns1)
    fac=where(singlep eq dts[1],ns2)
    fac=where(mediump eq dts[0],nm1)
    fac=where(mediump eq dts[1],nm2)
    fac=where(largep eq dts[0],nl1)
    fac=where(largep eq dts[1],nl2)
    ns=ns1+ns2
    nm=nm1+nm2
    nl=nl1+nl2
    IF ns eq 2 THEN outstr[doubles(j)].flag='double1'
    IF nm eq 2 THEN outstr[doubles(j)].flag='double4'
    IF nl eq 2 THEN outstr[doubles(j)].flag='double6'
    IF (ns NE 2) AND (nm NE 2) AND (nl NE 2) THEN BEGIN
       IF (ns+nm) eq 2 THEN outstr[doubles(j)].flag='double2'
       IF (ns+nl) eq 2 THEN outstr[doubles(j)].flag='double3'
       IF (nm+nl) eq 2 THEN outstr[doubles(j)].flag='double5'
    ENDIF
  ENDFOR
ENDIF


;continue with multiples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure multiple events exist

IF mults(0) ne -1 THEN BEGIN

  sums=total(cevl(0:34,mults),1)
  outstr[mults].flag='mult'
  outstr[mults].toten=sums
  outstr[mults].caten=evlc(mults)
 
  
   FOR j=0,n_elements(mults)-1L DO BEGIN
      dms=where(evla(0:34,mults[j]) gt 0)
      IF n_elements(dms) eq 3 THEN BEGIN
         outstr[mults(j)].det[0:2]=dms[0:2]
         outstr[mults(j)].en[0:2]=cevl(dms[0:2],mults(j))
         ENDIF ELSE BEGIN
    outstr[mults(j)].det[0:3]=dms[0:3]
    outstr[mults(j)].en[0:3]=cevl(dms[0:3],mults(j))
 ENDELSE
      ENDFOR
  
ENDIF

;final cleaning, there may be still cases with multiple anodes below threshold
;
;final check, everything must be flagged
;
remain=where(outstr.flag eq '')
IF remain[0] ne -1 THEN BEGIN
 print,'Some events not flagged! This should not have happened'
 print,'Dumping indices to check in the input event list'
 ner=n_elements(remain)
 IF ner LT 10 THEN print,remain ELSE print,remain[0:8]
 ENDIF
  

;here clean means only anode cathode coincident events
clean = outstr(where((outstr.flag eq 'single1') or (outstr.flag eq 'double1') $
  or (outstr.flag eq 'single2') or (outstr.flag eq 'single3') $
  or (outstr.flag eq 'mult')))

END
