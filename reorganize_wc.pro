pro reorganize_wc,evlist,an_thr,cat_thr,clean,outstr=outstr,catn=catn,maxc=maxc, renumerate=renumerate

;this program creates a structure that holds all share information neatly for event lists
;coming either from RENA or MPA system

;rename so that we do not overwrite
evl=evlist
;inputs:

;evlist: event list array, can be channels or calibrated energies
;an_thr: minimum acceptable anode signal (be careful it depends on channel or energy depending on your event list)
;cat_thr: minimum acceptable planar signal

;output
;clean: structure that holds only events above threshold with planar information
;
;optional arguments
;catn=ADC of the planar electrode
;maxc=number of channels that needs to be analyzed. If not given, max number of channels in the event list is used
;renumerate: If the planar electrode is not the last ADC, this gives you the option of recounting the anodes
;from 0. 
;outstr: optional structure with all events, used for diagnostics.


IF NOT keyword_set(catn) THEN catn=0
IF NOT keyword_set(maxc) THEN BEGIN
  sz=size(evl)
  maxc=sz(1)
  ENDIF


;definition of flags
;
; thresh : everything 0 (should not happen)
; thresh_x : x=1,2,3,4,m cathode below threshod, x number of anodes below threshold
; ca_only  : all anodes 0, cathode above cathode threshold
; ca_only_x  : x=1,2,3,4,m x # of anodes below threshold, cathode above cathode threshold
; single : single anode above anode threshold, cathode above cathode threshold
; single_an : single anode above anode threshold, cathode below cathode threshold
; double : double anode above anode threshold, cathode above cathode threshold
; double_an : double anode above anode threshold, cathode below cathode threshold
; triple : triple anode above anode threshold, cathode above cathode threshold
; triple_an : triple anode above anode threshold, cathode below cathode threshold
; quad : quadrupole anode above anode threshold, cathode above cathode threshold
; quad_an : quadrupole anode above anode threshold, cathode below cathode threshold
; mult : multiple anode above anode threshold, cathode above cathode threshold
; mult_an : multiple anode above anode threshold, cathode below cathode threshold



sz=size(evl)
outstr1=create_struct('flag','','en',fltarr(4),'toten',0.,$
  'det',intarr(4),'caten',0.,'car',0.)
outstr=replicate(outstr1,sz(2))

;seperate cathode and others

evlc=reform(evl(catn,*))

;since planar occupies one of the adcs you may want to renumerate anodes to take planar adc out
;this is not a problem if planar is chosen to be the last channel

IF NOT keyword_set(renumerate) THEN renumerate=0

IF renumerate THEN BEGIN
  evla=evl(where(indgen(maxc) ne catn),*)
  evl=evla
  maxc=maxc-1
ENDIF ELSE BEGIN
  evla=evl
  evla(catn,*)=0
ENDELSE

;Here, we have a problem when we use calibrated events as all 0s are now some offset
allhist=histogram(evl,min=-an_thr)
maxhist=max(allhist,indoff)
offs=indoff-an_thr
lowthresh=offs+2.
;print,lowthresh

;This part takes care of all 0 anodes 
all_ind=where(evla gt lowthresh, all_count)
zero_ind=where(evla le lowthresh, all_count)
temporary_evl=evla
evla[all_ind]=1
evla[zero_ind]=0
temporary_evl[zero_ind]=0
share1=total(evla(0:maxc-1,*),1)
singles0=where(share1 eq 0)

IF singles0[0] ne -1 THEN BEGIN
  thresh=where(evlc[singles0] lt cat_thr)
  IF thresh[0] ne -1 THEN BEGIN 
    outstr[singles0[thresh]].flag='thresh'
    outstr[singles0[thresh]].caten=evlc[singles0[thresh]]
    ENDIF
  caonly=where(evlc[singles0] ge cat_thr)
  IF caonly[0] ne -1 THEN BEGIN 
    outstr[singles0[caonly]].flag='ca_only'
    outstr[singles0[caonly]].caten=evlc[singles0[caonly]]
    ENDIF
ENDIF


;handle below threshold for diagnostic purposes

noise_events_ind=where((temporary_evl lt an_thr) and (temporary_evl gt 0) ,noise_count)
evln=evla
evln[noise_events_ind]=1
sharen=total(evln(0:maxc-1,*),1)


singlen=where(sharen eq 1)
doublen=where(sharen eq 2)
triplen=where(sharen eq 3)
quadn=where(sharen eq 4)
multn=where(sharen gt 4)
detn=(where(evln(*,singlen) eq 1) mod maxc)
IF doublen[0] ne -1 THEN detdn=(where(evln(*,doublen) eq 1) mod maxc)
IF triplen[0] ne -1 THEN dettn=(where(evln(*,triplen) eq 1) mod maxc)
IF quadn[0] ne -1 THEN detqn=(where(evln(*,quadn) eq 1) mod maxc)


;start with singles

evla=temporary_evl
sumn=total(evla(0:maxc-1,singlen),1)
outstr[singlen].flag='thresh_1'
cgt=where(evlc(singlen) GE cat_thr)
IF cgt[0] ne -1 THEN BEGIN
 outstr[singlen[cgt]].flag='ca_only_1'
 outstr[singlen[cgt]].caten=evlc[singlen[cgt]]
 ENDIF

outstr[singlen].en[0]=sumn
outstr[singlen].toten=sumn
outstr[singlen].det[0]=detn

;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doublen[0] ne -1 THEN BEGIN
  sumn=total(evla(0:maxc-1,doublen),1)
  outstr[doublen].flag='thresh_2'
  cgt=where(evlc(doublen) GE cat_thr)
  IF cgt[0] ne -1 THEN BEGIN
    outstr[doublen[cgt]].flag='ca_only_2'
    outstr[doublen[cgt]].caten=evlc[doublen[cgt]]
    ENDIF
    
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

  sumn=total(evla(0:maxc-1,triplen),1)
  outstr[triplen].flag='thresh_3'
  cgt=where(evlc(triplen) GE cat_thr)
  IF cgt[0] ne -1 THEN BEGIN
    outstr[triplen[cgt]].flag='ca_only_3'
    outstr[triplen[cgt]].caten=evlc[triplen[cgt]]
    ENDIF
    
  outstr[triplen].toten=sumn

  FOR j=0L,n_elements(triplen)-1L DO BEGIN
    dettjn=[dettn[3*j],dettn[3*j+1L],dettn[3*j+2L]]
    ensn=evl(dettjn,triplen(j))
    outstr[triplen(j)].det[0:2]=dettjn
    outstr[triplen(j)].en[0:2]=evla(dettjn,triplen(j))
  ENDFOR
ENDIF

IF quadn(0) ne -1 THEN BEGIN

  sumn=total(evla(0:maxc-1,quadn),1)
  outstr[quadn].flag='thresh_4'
  cgt=where(evlc(quadn) GE cat_thr)
  IF cgt[0] ne -1 THEN BEGIN
    outstr[quadn[cgt]].flag='ca_only_4'
    outstr[quadn[cgt]].caten=evlc[quadn[cgt]]
    ENDIF

  outstr[quadn].toten=sumn

  FOR j=0L,n_elements(quadn)-1L DO BEGIN
    detqjn=[detqn[4*j],detqn[4*j+1L],detqn[4*j+2L],detqn[4*j+3L]]
    ensn=evl(detqjn,quadn(j))
    outstr[quadn(j)].det[0:3]=detqjn
    outstr[quadn(j)].en[0:3]=evla(detqjn,quadn(j))
  ENDFOR
ENDIF

IF multn(0) ne -1 THEN BEGIN

  sumn=total(evla(0:maxc-1,multn),1)
  outstr[multn].flag='thresh_m'
  cgt=where(evlc(multn) GE cat_thr)
  IF cgt[0] ne -1 THEN BEGIN 
    outstr[multn[cgt]].flag='ca_only_m'
    outstr[multn[cgt]].caten=evlc[multn[cgt]]
    ENDIF
  outstr[multn].toten=sumn

  FOR j=0,n_elements(multn)-1L DO BEGIN
    dmn=where(evla(0:maxc-1,multn[j]) gt 0)
    outstr[multn(j)].det[0:3]=dmn[0:3]
    outstr[multn(j)].en[0:3]=evla(dmn[0:3],multn(j))
  ENDFOR
  ;no individual energy information
ENDIF

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;now clean below threshold to avoid wrong summations and continue
noise_events_ind=where(evla lt an_thr ,noise_count)
evla(noise_events_ind)=0

;following irfan determine singles,doubles,triples and quadrupoles at once

event_ind=where(evla ge an_thr, event_count)
temporary_evl=evla
evla(event_ind)=1
share=total(evla(0:maxc-1,*),1)
singles=where(share eq 1)
doubles=where(share eq 2)
triples=where(share eq 3)
quads=where(share eq 4)
mults=where(share gt 4)
dets=(where(evla(*,singles) eq 1) mod maxc)
IF doubles[0] ne -1 THEN detd=(where(evla(*,doubles) eq 1) mod maxc)
IF triples[0] ne -1 THEN dett=(where(evla(*,triples) eq 1) mod maxc)
IF quads[0] ne -1 THEN detq=(where(evla(*,quads) eq 1) mod maxc)
;detm=(where(evla(*,mults) eq 1) mod 16) this is not useful as is

evla=temporary_evl

;start with singles

sums=total(evla(0:maxc-1,singles),1)
outstr[singles].flag='single'
anon=where(evlc(singles) le cat_thr)
IF anon[0] ne -1 THEN outstr[singles(anon)].flag='single_an'
outstr[singles].en[0]=sums
outstr[singles].toten=sums
outstr[singles].det[0]=dets
outstr[singles].caten=evlc(singles)
outstr[singles].car=evlc(singles)/sums

;continue with doubles

;since the number is much less easier to work with a for loop to
;ease further calculations

IF doubles[0] ne -1 THEN BEGIN
  sums=total(evla(0:maxc-1,doubles),1)
  outstr[doubles].flag='double'
  anon=where(evlc(doubles) le cat_thr)
  IF anon[0] ne -1 THEN outstr[doubles(anon)].flag='double_an'
  outstr[doubles].toten=sums
  outstr[doubles].caten=evlc(doubles)
  outstr[doubles].car=evlc(doubles)/sums

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
  ENDFOR
ENDIF
;continue with triples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure triple events exist
IF triples(0) ne -1 THEN BEGIN

  sums=total(evla(0:maxc-1,triples),1)
  outstr[triples].flag='triple'
  anon=where(evlc(triples) le cat_thr)
  IF anon[0] ne -1 THEN outstr[triples(anon)].flag='triple_an'
  outstr[triples].toten=sums
  outstr[triples].caten=evlc(triples)
  outstr[triples].car=evlc(triples)/sums


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
  ENDFOR
ENDIF

;continue with quadruples

;since the number is much less easier to work with a for loop to
;ease further calculations

;first make sure quadrupole events exist
IF quads(0) ne -1 THEN BEGIN

  sums=total(evla(0:maxc-1,quads),1)
  outstr[quads].flag='quad'
  anon=where(evlc(quads) le cat_thr)
  IF anon[0] ne -1 THEN outstr[quads(anon)].flag='quad_an'
  outstr[quads].toten=sums
  outstr[quads].caten=evlc(quads)
  outstr[quads].car=evlc(quads)/sums


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

  sums=total(evla(0:maxc-1,mults),1)
  outstr[mults].flag='mult'
  anon=where(evlc(mults) le cat_thr)
  IF anon[0] ne -1 THEN outstr[mults(anon)].flag='mult_an'
  outstr[mults].toten=sums
  outstr[mults].caten=evlc(mults)
  outstr[mults].car=evlc(mults)/sums
  
   FOR j=0,n_elements(mults)-1L DO BEGIN
    dms=where(evla(0:maxc-1,mults[j]) gt 0)
    outstr[mults(j)].det[0:3]=dms[0:3]
    outstr[mults(j)].en[0:3]=evla(dms[0:3],mults(j))
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


;remain=where(outstr.flag eq '')
;IF remain[0] ne -1 then BEGIN
;  thresh=where(evlc[remain] lt cat_thr)
;  IF thresh[0] ne -1 THEN outstr[remain[thresh]].flag='thresh'
;  caonly=where(evlc[remain] ge cat_thr)
;  IF caonly[0] ne -1 THEN BEGIN
;    outstr[remain[caonly]].flag='ca_only'
;    outstr[remain[caonly]].caten=evlc[remain[caonly]]
;  ENDIF
;ENDIF   

;here clean means only anode cathode coincident events
clean = outstr(where((outstr.flag eq 'single') or (outstr.flag eq 'double') $
  or (outstr.flag eq 'triple') or (outstr.flag eq 'quad') $
  or (outstr.flag eq 'mult')))

END
