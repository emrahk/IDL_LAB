function Read_data, data_file=data_file,header_text_ends=header_text_ends,active_adc

;***********************************************************************************
; read the sellected lst binary file
; in the binary file indiicate that
; the header data ends.

; Look for active ADC in the header
; active=0   : ADC is not active
; active=1   : ADC is active (SINGLE MODE)
; active=2   : ADC is active (COINCIDENT MODE, CAN START AN EVENT TRIGGER)
; function returns an array of active ADC with index
; and search for active_adc_key1=byte("active=2") ; coincidence
; and active_adc_key2=byte("active=1") ; single
;adopted from read_file_MPA3_2da_ratio.PRO
;use only for MPA3 binary .LST file reading

if n_elements(data_file) ne 0 then $ ; Grab the file if given.
      fil = data_file
if n_elements(header_text_ends) ne 0 then $ ; Grab the file if given.
      header_text_ends = header_text_ends
CLOSE, 25
OPENR, 25, Fil
STATUS=FSTAT(25)
MAXLEN=STATUS.SIZE
if maxlen gt 50000000 then maxlen=50000000

;************************************************************************
start_ptr=header_text_ends(0)+1 ;is CR

POINT_LUN, 25, 0 ;point back to start position

;read the full header text
temp=bytarr(start_ptr) & Readu, 25, temp ;
;print,string(temp(start_ptr-12:start_ptr-1))

s0=size(active_adc)
active=s0(1)

; check the sync key for the data (double word : 255 255 255 255)
temp=bytarr(4) & Readu, 25, temp ;

; SEARCH FOR ' DATA SYNC word ' 255 255 255 255 /ffff
;if temp(0) eq 255 and temp (1) eq  255 and temp(2) eq 255 and temp (3) eq  255 then  print, ' DATA SYNC word is OK...' else print, ' DATA SYNC word is MISSING...'

POINT_LUN, 25, start_ptr ;back to start position

MAXLEN=maxlen-start_ptr;-2

maxlen=maxlen- (maxlen mod 4)

temp=bytarr(MAXLEN) & Readu, 25, temp

; prepare the ARRAYS for the data
nw=(MAXLEN)/4
word=bytarr(4,nw)
word(*)=temp(0:MAXLEN-1)
ev=intarr(active,nw)
ev_time=bytarr(nw)

;******************************************************************************************************
; locate the sync data 0xffff
if 1 then begin

synch_id=where(word(0,*) eq 255 and word(1,*) eq 255 and word(2,*) eq 255 and word(3,*) eq 255,nsynch)
; start to fill ev(*,*) data array
for nsy=0L,nsynch-2 do begin
    i=synch_id(nsy)+1
    while i lt synch_id(nsy+1) do begin
       if word(2,i) eq 0 and (word(3,i) eq 0 or word(3,i) eq 128) then begin  ; event word
        ttt=uint(0)
         ttt=uint(word(0,i)+256*word(1,i))
         binrep,ttt,adc,n_adc
         ev_ind=i+1
         n_dwords=n_adc/2
         if 2*n_dwords eq n_adc then begin; even
           for dw=0,n_dwords-1 do begin
              i=i+1
              t1=where(active_adc eq adc(dw*2))
              t2=where(active_adc eq adc(dw*2+1))
              ev(t1(0),ev_ind)=word(0,i)+256*word(1,i)
              ev(t2(0),ev_ind)=word(2,i)+256*word(3,i)
           endfor
         endif else begin; odd
           i=i+1
           t0=where(active_adc eq adc(0))
           ev(t0(0),ev_ind)=word(0+2,i)+256*word(0+3,i)
           for dw=1,n_dwords do begin
              i=i+1
              t1=where(active_adc eq adc(dw*2-1))
              t2=where(active_adc eq adc(dw*2))
              ev(t1(0),ev_ind)=word(0,i)+256*word(1,i)
              ev(t2(0),ev_ind)=word(2,i)+256*word(3,i)
           endfor
         endelse
         i=i+1
         endif else begin
         if word(3,i) eq 64 then begin ; time event
             i=i+1
             ev_time(i)=1
         endif
         i=i+1
       endelse
    endwhile
endfor
temp=0
Word=0
synch_id=0
; end for reading

ind_ev=where(total(ev,1) gt 0)
;help,ind_ev
ev=ev(*,ind_ev)
;ev=ev and 8191

ev_time=total(ev_time,/cumulative)
ev_time=ev_time(ind_ev)
;ev=ev*1.0
endif
CLOSE, 25

return,ev

END
;////////////////////////////////////////////////////////////////////////////////////////////
