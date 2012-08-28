pro reorganize_anodes,evlist,an_thr,outstr,anotn=anots

;this program creates a structure that holds all share information neatly for event lists
;coming either from RENA or MPA system. The program only deals with anodes

;rename so that we do not overwrite
evl=evlist
;inputs:

;evlist: event list array, can be channels or calibrated energies
;an_thr: minimum acceptable anode signal (be careful it depends on channel or energy depending on your event list)

;output
;outstr: structure that holds all information
;
;optional arguments
;anots=array of the anodes
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
;
;Aug 2012
;steering electrode part added, corrected to make yigit simulation works



;set anode channels if not given
IF NOT keyword_set(anots) THEN anots=[17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]

;necessary variable

sz=size(evl)

;definition of anode flags
;
;general and noise related
;
; thresh : everything 0 (no anode signal at all)
; thresh_x : x=1,2,3,4,m x number of anodes below threshold

; anode flags
; single : single anode above anode threshold
; double : double anode above anode threshold
; triple : triple anode above anode threshold
; quad : quadrupole anode above anode threshold
; mult : multiple anode above anode threshold

;create the standard output structure

IF NOT keyword_set(outstr) THEN BEGIN
 outstr1=create_struct('aflag','','cflag','','sflag','','flag','',$
  'en',fltarr(4),'toten',0.,'det',intarr(4), $
  'cadet',intarr(4),'caten',0.,'catend',fltarr(4),'car',0.,$
  'sedet',intarr(3),'seen',0.,'seend',fltarr(3))
  outstr=replicate(outstr1,sz(2))
ENDIF

;seperate anodes

evla=reform(evl[anots,*])
evl=evla ;keep only the anodes

;This part takes care of all 0 anodes 
maxan=n_elements(anots)
check0=where(total(evla(0:maxan-1,*),1) eq 0)
outstr[check0].aflag='thresh'

temporary_evl=evla
;now take care of events below threshold
;handle below threshold for diagnostic purposes

noise_events_ind=where((temporary_evl lt an_thr) and (temporary_evl gt 0) ,noise_count)

IF noise_events_ind[0] NE -1 THEN BEGIN
  evln=intarr(maxan,sz(2))
  evln[noise_events_ind]=1
  sharen=total(evln(0:maxan-1,*),1)


  singlen=where(sharen eq 1)
  doublen=where(sharen eq 2)
  triplen=where(sharen eq 3)
  quadn=where(sharen eq 4)
  multn=where(sharen gt 4)
  detn=(where(evln(*,singlen) eq 1) mod maxan)

  IF doublen[0] ne -1 THEN detdn=(where(evln(*,doublen) eq 1) mod maxan)
  IF triplen[0] ne -1 THEN dettn=(where(evln(*,triplen) eq 1) mod maxan)
  IF quadn[0] ne -1 THEN detqn=(where(evln(*,quadn) eq 1) mod maxan)


  ;start with singles


  evla=temporary_evl

  IF singlen[0] NE -1 THEN BEGIN
     sumn=total(evla(0:maxan-1,singlen),1)
     outstr[singlen].aflag='thresh_1'  
     outstr[singlen].en[0]=sumn
     outstr[singlen].toten=sumn
     outstr[singlen].det[0]=detn
  ENDIF

  ;continue with doubles

  ;since the number is much less easier to work with a for loop to
  ;ease further calculations

  IF doublen[0] ne -1 THEN BEGIN
    sumn=total(evla(0:maxan-1,doublen),1)
    outstr[doublen].aflag='thresh_2'
    outstr[doublen].toten=sumn

    FOR j=0L,n_elements(doublen)-1L DO BEGIN
      dtsn=[detdn[2*j],detdn[2*j+1L]]
      ensn=evl(dtsn,doublen(j))
      outstr[doublen(j)].det[0:1]=dtsn
      outstr[doublen(j)].en[0:1]=ensn
      ENDFOR
      ENDIF

  ;first make sure triple events exist
  IF triplen(0) ne -1 THEN BEGIN

    sumn=total(evla(0:maxan-1,triplen),1)
    outstr[triplen].aflag='thresh_3'
    outstr[triplen].toten=sumn

    FOR j=0L,n_elements(triplen)-1L DO BEGIN
      dettjn=[dettn[3*j],dettn[3*j+1L],dettn[3*j+2L]]
      ensn=evl(dettjn,triplen(j))
      outstr[triplen(j)].det[0:2]=dettjn
      outstr[triplen(j)].en[0:2]=evla(dettjn,triplen(j))
      ENDFOR
      ENDIF

  IF quadn(0) ne -1 THEN BEGIN

    sumn=total(evla(0:maxan-1,quadn),1)
    outstr[quadn].aflag='thresh_4'
    outstr[quadn].toten=sumn

    FOR j=0L,n_elements(quadn)-1L DO BEGIN
      detqjn=[detqn[4*j],detqn[4*j+1L],detqn[4*j+2L],detqn[4*j+3L]]
      ensn=evl(detqjn,quadn(j))
      outstr[quadn(j)].det[0:3]=detqjn
      outstr[quadn(j)].en[0:3]=evla(detqjn,quadn(j))
      ENDFOR
      ENDIF

  IF multn(0) ne -1 THEN BEGIN

    sumn=total(evla(0:maxan-1,multn),1)
    outstr[multn].aflag='thresh_m'
    outstr[multn].toten=sumn

    FOR j=0,n_elements(multn)-1L DO BEGIN
      dmn=where(evla(0:maxan-1,multn[j]) gt 0)
      outstr[multn(j)].det[0:3]=dmn[0:3]
      outstr[multn(j)].en[0:3]=evla(dmn[0:3],multn(j))
      ENDFOR
      ;no individual energy information
  ENDIF

ENDIF ELSE evla=temporary_evl
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;now clean below threshold to avoid wrong summations and continue
;here we omit everything below threshold, so if we need to include them later
;for some reason we need to rerun the whole program with a lower threshold

noise_events_ind=where(evla lt an_thr ,noise_count)
IF noise_events_ind[0] NE -1 THEN evla(noise_events_ind)=0

;following irfan determine singles,doubles,triples and quadrupoles at once

event_ind=where(evla ge an_thr, event_count)
temporary_evl=evla
evla(event_ind)=1
share=total(evla(0:maxan-1,*),1)
singles=where(share eq 1)
doubles=where(share eq 2)
triples=where(share eq 3)
quads=where(share eq 4)
mults=where(share gt 4)
dets=(where(evla(*,singles) eq 1) mod maxan)
IF doubles[0] ne -1 THEN detd=(where(evla(*,doubles) eq 1) mod maxan)
IF triples[0] ne -1 THEN dett=(where(evla(*,triples) eq 1) mod maxan)
IF quads[0] ne -1 THEN detq=(where(evla(*,quads) eq 1) mod maxan)
;detm=(where(evla(*,mults) eq 1) mod 16) this is not useful as is

evla=temporary_evl

;start with singles

IF singles[0] NE -1 THEN BEGIN
   sums=total(evla(0:maxan-1,singles),1)
   outstr[singles].aflag='single'
   outstr[singles].en[0]=sums
   outstr[singles].en[1:3]=0.
   outstr[singles].toten=sums
   outstr[singles].det[0]=dets
   outstr[singles].det[1:3]=0
ENDIF
;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doubles[0] ne -1 THEN BEGIN
  sums=total(evla(0:maxan-1,doubles),1)
  outstr[doubles].aflag='double'
  outstr[doubles].toten=sums

  FOR j=0L,n_elements(doubles)-1L DO BEGIN
    dts=[detd[2*j],detd[2*j+1L]]
    ens=evl(dts,doubles(j))
    ;assign the event to the largest energy
    IF ens[0] ge ens[1] THEN BEGIN
      outstr[doubles(j)].det[0:1]=dts
      outstr[doubles(j)].en[0:1]=ens
    ENDIF ELSE BEGIN
      outstr[doubles(j)].det[0:1]=reverse(dts)
      outstr[doubles(j)].en[0:1]=reverse(ens)
   ENDELSE
     outstr[doubles(j)].en[2:3]=0.
     outstr[doubles(j)].det[2:3]=0
  ENDFOR
ENDIF
;continue with triples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure triple events exist
IF triples(0) ne -1 THEN BEGIN

  sums=total(evla(0:maxan-1,triples),1)
  outstr[triples].aflag='triple'
  outstr[triples].toten=sums


  FOR j=0L,n_elements(triples)-1L DO BEGIN
    dettj=[dett[3*j],dett[3*j+1L],dett[3*j+2L]]
    ens=evl(dettj,triples(j))
    sdett=sort(ens)
    outstr[triples(j)].det[0]=dettj(sdett(2))
    outstr[triples(j)].det[1]=dettj(sdett(1))
    outstr[triples(j)].det[2]=dettj(sdett(0))
    outstr[triples(j)].en[0]=evla(dettj(sdett(2)),triples(j))
    outstr[triples(j)].en[1]=evla(dettj(sdett(1)),triples(j))
    outstr[triples(j)].en[2]=evla(dettj(sdett(0)),triples(j))
    outstr[triples(j)].en[3]=0.
    outstr[triples(j)].det[3]=0
    ENDFOR
ENDIF

;continue with quadruples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure quadrupole events exist
IF quads(0) ne -1 THEN BEGIN

  sums=total(evla(0:maxan-1,quads),1)
  outstr[quads].aflag='quad'
  outstr[quads].toten=sums

  FOR j=0L,n_elements(quads)-1L DO BEGIN
    detqj=[detq[4*j],detq[4*j+1L],detq[4*j+2L],detq[4*j+3L]]
    ens=evl(detqj,quads(j))
    sdetq=sort(ens)
    outstr[quads(j)].det[0]=detqj(sdetq(3))
    outstr[quads(j)].det[1]=detqj(sdetq(2))
    outstr[quads(j)].det[2]=detqj(sdetq(1))
    outstr[quads(j)].det[3]=detqj(sdetq(0))
    outstr[quads(j)].en[0]=evla(detqj(sdetq(3)),quads(j))
    outstr[quads(j)].en[1]=evla(detqj(sdetq(2)),quads(j))
    outstr[quads(j)].en[2]=evla(detqj(sdetq(1)),quads(j))
    outstr[quads(j)].en[3]=evla(detqj(sdetq(0)),quads(j))
  ENDFOR
ENDIF

;continue with multiples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure multiple events exist

IF mults(0) ne -1 THEN BEGIN

  sums=total(evla(0:maxan-1,mults),1)
  outstr[mults].aflag='mult'
  outstr[mults].toten=sums
  
   FOR j=0,n_elements(mults)-1L DO BEGIN
    dms=where(evla(0:maxan-1,mults[j]) gt 0)
    outstr[mults(j)].det[0:3]=dms[0:3]
    outstr[mults(j)].en[0:3]=evla(dms[0:3],mults(j))
  ENDFOR
  
ENDIF

;final cleaning, there may be still cases with multiple anodes below threshold
;
;final check, everything must be flagged
;
remain=where(outstr.aflag eq '')
IF remain[0] ne -1 THEN BEGIN
 print,'Some events not flagged! This should not have happened'
 print,'Dumping indices to check in the input event list'
 ner=n_elements(remain)
 IF ner LT 10 THEN print,remain ELSE print,remain[0:8]
 ENDIF


END
