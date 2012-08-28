pro reorganize_se,evlist,se_thr,outstr,sen=ses, semap=mapse

;this program creates a structure that holds all share information neatly for event lists
;coming either from RENA or MPA system. The program only deals with
;steering electrodes

;rename so that we do not overwrite
evl=evlist
;inputs:

;evlist: event list array, can be channels or calibrated energies
;an_thr: minimum acceptable anode signal (be careful it depends on channel or energy depending on your event list)

;output
;outstr: structure that holds all information
;
;optional arguments
;ses=array of the steering electrodes
;
;Used by:
;
;reorganize_mix.pro
;
;Uses
;
;NONE
;
;Created by Emrah Kalemci
;06/02/2012
;
;NOTES & BUG FIXES
;
;since there are 3 se channels but 5 steering electrodes we need a map
;
;Aug 2012
;a typo fixed

;set anode channels if not given
IF NOT keyword_set(ses) THEN ses=[33,34,35]
IF NOT keyword_set(mapse) THEN mapse=[0,2,4]

;necessary variable

sz=size(evl)

;definition of anode flags
;
;general and noise related
;
; thresh : everything 0 (no steering signal at all)
; thresh_x : x=1,2,3,4,m x number of anodes below threshold

; se flags
; single : single anode above anode threshold
; double : double anode above anode threshold
; triple : triple anode above anode threshold

;create the standard output structure

IF NOT keyword_set(outstr) THEN BEGIN
  outstr1=create_struct('aflag','','cflag','','sflag','','flag','',$
  'en',fltarr(4),'toten',0.,'det',intarr(4), $
  'cadet',intarr(4),'caten',0.,'catend',fltarr(4),'car',0.,$
  'sedet',intarr(3),'seen',0.,'seend',fltarr(3))
  outstr=replicate(outstr1,sz(2))
ENDIF

;seperate steering electrodes

evls=reform(evl[ses,*])
evl=evls ;keep only the steering electrodes

;This part takes care of all 0 steering electrodes 
maxs=n_elements(ses)
check0=where(total(evls(0:maxs-1,*),1) eq 0)
outstr[check0].sflag='thresh'

temporary_evl=evls
;now take care of events below threshold
;handle below threshold for diagnostic purposes

noise_events_ind=where((temporary_evl lt se_thr) and (temporary_evl gt 0) ,noise_count)

IF noise_events_ind[0] NE -1 THEN BEGIN
  evln=intarr(maxs,sz(2))
  evln[noise_events_ind]=1
  sharen=total(evln(0:maxs-1,*),1)


  singlen=where(sharen eq 1)
  doublen=where(sharen eq 2)
  triplen=where(sharen eq 3)
  detn=(where(evln(*,singlen) eq 1) mod maxs)
  IF doublen[0] ne -1 THEN detdn=(where(evln(*,doublen) eq 1) mod maxs)
  IF triplen[0] ne -1 THEN dettn=(where(evln(*,triplen) eq 1) mod maxs)

  ;start with singles

  evls=temporary_evl
  sumn=total(evls(0:maxs-1,singlen),1)
  outstr[singlen].aflag='thresh_1'  
  outstr[singlen].seend[0]=sumn
  outstr[singlen].seen=sumn
  outstr[singlen].sedet[0]=detn

  ;continue with doubles

  ;since the number is much less easier to work with a for loop to
  ;ease further calculations

  IF doublen[0] ne -1 THEN BEGIN
    sumn=total(evls(0:maxs-1,doublen),1)
    outstr[doublen].sflag='thresh_2'
    outstr[doublen].seen=sumn

    FOR j=0L,n_elements(doublen)-1L DO BEGIN
      dtsn=[detdn[2*j],detdn[2*j+1L]]
      ensn=evl(dtsn,doublen(j))
      outstr[doublen(j)].sedet[0:1]=dtsn
      outstr[doublen(j)].seend[0:1]=ensn
      ENDFOR
      ENDIF

  ;first make sure triple events exist
  IF triplen(0) ne -1 THEN BEGIN

    sumn=total(evls(0:maxs-1,triplen),1)
    outstr[triplen].sflag='thresh_3'
    outstr[triplen].seen=sumn

    FOR j=0L,n_elements(triplen)-1L DO BEGIN
      dettjn=[dettn[3*j],dettn[3*j+1L],dettn[3*j+2L]]
      ensn=evl(dettjn,triplen(j))
      outstr[triplen(j)].sedet[0:2]=dettjn
      outstr[triplen(j)].seend[0:2]=evls(dettjn,triplen(j))
      ENDFOR
      ENDIF

ENDIF ELSE evls=temporary_evl
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;now clean below threshold to avoid wrong summations and continue
;here we omit everything below threshold, so if we need to include them later
;for some reason we need to rerun the whole program with a lower threshold

noise_events_ind=where(evls lt se_thr ,noise_count)
IF noise_events_ind[0] NE -1 THEN evls(noise_events_ind)=0

;following irfan determine singles,doubles,triples and quadrupoles at once

event_ind=where(evls ge se_thr, event_count)
temporary_evl=evls
evls(event_ind)=1
share=total(evls(0:maxs-1,*),1)
singles=where(share eq 1)
doubles=where(share eq 2)
triples=where(share eq 3)

dets=(where(evls(*,singles) eq 1) mod maxs)
IF doubles[0] ne -1 THEN detd=(where(evls(*,doubles) eq 1) mod maxs)
IF triples[0] ne -1 THEN dett=(where(evls(*,triples) eq 1) mod maxs)

evls=temporary_evl

;start with singles

IF singles[0] ne -1 THEN BEGIN
   sums=total(evls(0:maxs-1,singles),1)
   outstr[singles].sflag='single'
   outstr[singles].seend[0]=sums
   outstr[singles].seen=sums
   outstr[singles].sedet[0]=dets
   outstr[singles].sedet[1:2]=0
   outstr[singles].seend[1:2]=0.
ENDIF
;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doubles[0] ne -1 THEN BEGIN
  sums=total(evls(0:maxs-1,doubles),1)
  outstr[doubles].sflag='double'
  outstr[doubles].seen=sums

  FOR j=0L,n_elements(doubles)-1L DO BEGIN
    dts=[detd[2*j],detd[2*j+1L]]
    ens=evl(dts,doubles(j))
    ;assign the event to the largest energy
    IF ens[0] ge ens[1] THEN BEGIN
      outstr[doubles(j)].sedet[0:1]=dts
      outstr[doubles(j)].seend[0:1]=ens
    ENDIF ELSE BEGIN
      outstr[doubles(j)].sedet[0:1]=reverse(dts)
      outstr[doubles(j)].seend[0:1]=reverse(ens)
   ENDELSE
   outstr[doubles(j)].sedet[2]=0
   outstr[doubles(j)].seend[2]=0.
  ENDFOR
ENDIF
;continue with triples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure triple events exist
IF triples(0) ne -1 THEN BEGIN

  sums=total(evls(0:maxs-1,triples),1)
  outstr[triples].sflag='triple'
  outstr[triples].seen=sums


  FOR j=0L,n_elements(triples)-1L DO BEGIN
    dettj=[dett[3*j],dett[3*j+1L],dett[3*j+2L]]
    ens=evl(dettj,triples(j))
    sdett=sort(ens)
    outstr[triples(j)].sedet[0]=dettj(sdett(2))
    outstr[triples(j)].sedet[1]=dettj(sdett(1))
    outstr[triples(j)].sedet[2]=dettj(sdett(0))
    outstr[triples(j)].seend[0]=evls(dettj(sdett(2)),triples(j))
    outstr[triples(j)].seend[1]=evls(dettj(sdett(1)),triples(j))
    outstr[triples(j)].seend[2]=evls(dettj(sdett(0)),triples(j))
  ENDFOR
ENDIF

;map steering electrode channels, just singles

sedet=outstr.sedet
orsedet=sedet
FOR i=0,n_elements(mapse)-1 DO BEGIN
  mape=where(orsedet eq i)
  sedet[mape]=mapse[i]
  ENDFOR
outstr.sedet=sedet

;final cleaning, there may be still cases with multiple anodes below threshold
;
;final check, everything must be flagged
;
remain=where(outstr.sflag eq '')
IF remain[0] ne -1 THEN BEGIN
 print,'Some events not flagged! This should not have happened'
 print,'Dumping indices to check in the input event list'
 ner=n_elements(remain)
 IF ner LT 10 THEN print,remain ELSE print,remain[0:8]
 ENDIF


END
