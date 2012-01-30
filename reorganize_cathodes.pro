pro reorganize_cathodes,evlist,cat_thr,outstr,catn=cats

;this program creates a structure that holds all share information neatly for event lists
;coming either from RENA or MPA system. The program only deals with cathodes

;rename so that we do not overwrite
evl=evlist
;inputs:

;evlist: event list array, can be channels or calibrated energies
;cat_thr: minimum acceptable cathode signal (be careful it depends on channel or energy depending on your event list)

;output
;outstr: structure that holds all information
;
;optional arguments
;cats=array of the cathodes
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
;30/01/2012
;
;NOTES & BUG FIXES

;set anode channels if not given
IF NOT keyword_set(cats) THEN cats=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]

;necessary variable

sz=size(evl)

;definition of anode flags
;
;general and noise related
;
; thresh : everything 0 (no anode signal at all)
; thresh_x : x=1,2,3,4,m x number of cathodes below threshold

; cathode flags
; single : single cathode above anode threshold
; double : double cathode above anode threshold
; triple : triple cathode above anode threshold
; quad : quadrupole cathode above anode threshold
; mult : multiple cathode above cathode threshold

;create the standard output structure if not given

IF NOT keyword_set(outstr) THEN BEGIN 
  outstr1=create_struct('cflag','','flag','','en',fltarr(4),'toten',0.,$
  'det',intarr(4),'cadet',intarr(4),'caten',0.,'catend',fltarr(4),'car',0.)
  outstr=replicate(outstr1,sz(2))
ENDIF

;seperate anodes

evlc=reform(evl[cats,*])
evl=evlc ;keep only the anodes
;;;;;;
;This part takes care of all 0 cathodes 
maxcat=n_elements(cats)
check0=where(total(evlc(0:maxcat-1,*),1) eq 0)
outstr[check0].cflag='thresh'

temporary_evl=evlc
;now take care of events below threshold
;handle below threshold for diagnostic purposes

noise_events_ind=where((temporary_evl lt cat_thr) and (temporary_evl ne 0) ,noise_count)

IF noise_events_ind[0] NE -1 THEN BEGIN
  evln=intarr(maxcat,sz(2))
  evln[noise_events_ind]=1
  sharen=total(evln(0:maxcat-1,*),1)


  singlen=where(sharen eq 1)
  doublen=where(sharen eq 2)
  triplen=where(sharen eq 3)
  quadn=where(sharen eq 4)
  multn=where(sharen gt 4)
  detn=(where(evln(*,singlen) eq 1) mod maxcat)
  IF doublen[0] ne -1 THEN detdn=(where(evln(*,doublen) eq 1) mod maxcat)
  IF triplen[0] ne -1 THEN dettn=(where(evln(*,triplen) eq 1) mod maxcat)
  IF quadn[0] ne -1 THEN detqn=(where(evln(*,quadn) eq 1) mod maxcat)


  ;start with singles

  evlc=temporary_evl
  sumn=total(evlc(0:maxcat-1,singlen),1)
  outstr[singlen].cflag='thresh_1'  
  outstr[singlen].catend[0]=sumn
  outstr[singlen].caten=sumn
  outstr[singlen].cadet[0]=detn

  ;continue with doubles

  ;since the number is much less easier to work with a for loop to
  ;ease further calculations

  IF doublen[0] ne -1 THEN BEGIN
    sumn=total(evlc(0:maxcat-1,doublen),1)
    outstr[doublen].cflag='thresh_2'
    outstr[doublen].caten=sumn

    FOR j=0L,n_elements(doublen)-1L DO BEGIN
      dtsn=[detdn[2*j],detdn[2*j+1L]]
      ensn=evl(dtsn,doublen(j))
      outstr[doublen(j)].cadet[0:1]=dtsn
      outstr[doublen(j)].catend[0:1]=ensn
      ENDFOR
      ENDIF

  ;first make sure triple events exist
  IF triplen(0) ne -1 THEN BEGIN

    sumn=total(evlc(0:maxcat-1,triplen),1)
    outstr[triplen].cflag='thresh_3'
    outstr[triplen].caten=sumn

    FOR j=0L,n_elements(triplen)-1L DO BEGIN
      dettjn=[dettn[3*j],dettn[3*j+1L],dettn[3*j+2L]]
      ensn=evl(dettjn,triplen(j))
      outstr[triplen(j)].cadet[0:2]=dettjn
      outstr[triplen(j)].catend[0:2]=evlc(dettjn,triplen(j))
      ENDFOR
      ENDIF

  IF quadn(0) ne -1 THEN BEGIN

    sumn=total(evlc(0:maxcat-1,quadn),1)
    outstr[quadn].cflag='thresh_4'
    outstr[quadn].caten=sumn

    FOR j=0L,n_elements(quadn)-1L DO BEGIN
      detqjn=[detqn[4*j],detqn[4*j+1L],detqn[4*j+2L],detqn[4*j+3L]]
      ensn=evl(detqjn,quadn(j))
      outstr[quadn(j)].cadet[0:3]=detqjn
      outstr[quadn(j)].catend[0:3]=evlc(detqjn,quadn(j))
      ENDFOR
      ENDIF

  IF multn(0) ne -1 THEN BEGIN

    sumn=total(evlc(0:maxcat-1,multn),1)
    outstr[multn].cflag='thresh_m'
    outstr[multn].caten=sumn

    FOR j=0,n_elements(multn)-1L DO BEGIN
      dmn=where(evlc(0:maxcat-1,multn[j]) gt 0)
      outstr[multn(j)].cadet[0:3]=dmn[0:3]
      outstr[multn(j)].catend[0:3]=evlc(dmn[0:3],multn(j))
      ENDFOR
      ;no individual energy information
  ENDIF

ENDIF ELSE evlc=temporary_evl
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;now clean below threshold to avoid wrong summations and continue
;here we omit everything below threshold, so if we need to include them later
;for some reason we need to rerun the whole program with a lower threshold

noise_events_ind=where(evlc lt cat_thr ,noise_count)
IF noise_events_ind[0] NE -1 THEN evlc(noise_events_ind)=0

;following irfan determine singles,doubles,triples and quadrupoles at once

event_ind=where(evlc ge cat_thr, event_count)
temporary_evl=evlc
evlc(event_ind)=1
share=total(evlc(0:maxcat-1,*),1)
singles=where(share eq 1)
doubles=where(share eq 2)
triples=where(share eq 3)
quads=where(share eq 4)
mults=where(share gt 4)
dets=(where(evlc(*,singles) eq 1) mod maxcat)
IF doubles[0] ne -1 THEN detd=(where(evlc(*,doubles) eq 1) mod maxcat)
IF triples[0] ne -1 THEN dett=(where(evlc(*,triples) eq 1) mod maxcat)
IF quads[0] ne -1 THEN detq=(where(evlc(*,quads) eq 1) mod maxcat)
;detm=(where(evlc(*,mults) eq 1) mod 16) this is not useful as is

evlc=temporary_evl

;start with singles

sums=total(evlc(0:maxcat-1,singles),1)
outstr[singles].cflag='single'
outstr[singles].catend[0]=sums
outstr[singles].caten=sums
outstr[singles].cadet[0]=dets

;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doubles[0] ne -1 THEN BEGIN
  sums=total(evlc(0:maxcat-1,doubles),1)
  outstr[doubles].cflag='double'
  outstr[doubles].caten=sums

  FOR j=0L,n_elements(doubles)-1L DO BEGIN
    dts=[detd[2*j],detd[2*j+1L]]
    ens=evl(dts,doubles(j))
    ;assign the event to the largest energy
    IF ens[0] ge ens[1] THEN BEGIN
      outstr[doubles(j)].cadet[0:1]=dts
      outstr[doubles(j)].catend[0:1]=ens
    ENDIF ELSE BEGIN
      outstr[doubles(j)].cadet[0:1]=reverse(dts)
      outstr[doubles(j)].catend[0:1]=reverse(ens)
    ENDELSE
  ENDFOR
ENDIF
;continue with triples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure triple events exist
IF triples(0) ne -1 THEN BEGIN

  sums=total(evlc(0:maxcat-1,triples),1)
  outstr[triples].cflag='triple'
  outstr[triples].caten=sums


  FOR j=0L,n_elements(triples)-1L DO BEGIN
    dettj=[dett[3*j],dett[3*j+1L],dett[3*j+2L]]
    ens=evl(dettj,triples(j))
    sdett=sort(ens)
    outstr[triples(j)].cadet[0]=dettj(sdett(2))
    outstr[triples(j)].cadet[1]=dettj(sdett(1))
    outstr[triples(j)].cadet[2]=dettj(sdett(0))
    outstr[triples(j)].catend[0]=evlc(dettj(sdett(2)),triples(j))
    outstr[triples(j)].catend[1]=evlc(dettj(sdett(1)),triples(j))
    outstr[triples(j)].catend[2]=evlc(dettj(sdett(0)),triples(j))
  ENDFOR
ENDIF

;continue with quadruples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure quadrupole events exist
IF quads(0) ne -1 THEN BEGIN

  sums=total(evlc(0:maxcat-1,quads),1)
  outstr[quads].cflag='quad'
  outstr[quads].caten=sums


  FOR j=0L,n_elements(quads)-1L DO BEGIN
    detqj=[detq[4*j],detq[4*j+1L],detq[4*j+2L],detq[4*j+3L]]
    ens=evl(detqj,quads(j))
    sdetq=sort(ens)
    outstr[quads(j)].cadet[0]=detqj(sdetq(3))
    outstr[quads(j)].cadet[1]=detqj(sdetq(2))
    outstr[quads(j)].cadet[2]=detqj(sdetq(1))
    outstr[quads(j)].cadet[3]=detqj(sdetq(0))
    outstr[quads(j)].catend[0]=evlc(detqj(sdetq(3)),quads(j))
    outstr[quads(j)].catend[1]=evlc(detqj(sdetq(2)),quads(j))
    outstr[quads(j)].catend[2]=evlc(detqj(sdetq(1)),quads(j))
    outstr[quads(j)].catend[3]=evlc(detqj(sdetq(0)),quads(j))
  ENDFOR
ENDIF

;continue with multiples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure multiple events exist

IF mults(0) ne -1 THEN BEGIN

  sums=total(evlc(0:maxcat-1,mults),1)
  outstr[mults].cflag='mult'
  outstr[mults].caten=sums
  
   FOR j=0,n_elements(mults)-1L DO BEGIN
    dms=where(evlc(0:maxcat-1,mults[j]) gt 0)
    outstr[mults(j)].cadet[0:3]=dms[0:3]
    outstr[mults(j)].catend[0:3]=evlc(dms[0:3],mults(j))
  ENDFOR
  
ENDIF

;final cleaning, there may be still cases with multiple cathodes below threshold
;
;final check, everything must be flagged
;
remain=where(outstr.cflag eq '')
IF remain[0] ne -1 THEN BEGIN
 print,'Some cathode events not flagged! This should not have happened'
 print,'Dumping indices to check in the input event list'
 ner=n_elements(remain)
 IF ner LT 10 THEN print,remain ELSE print,remain[0:8]
 ENDIF


END
