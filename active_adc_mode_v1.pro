function active_adc_mode_v1, byte_array
; new version
; coincidence, single and  not active sellection is implemented
; function name is changed to active_adc_mode
; returns mode array with adc_nr indexed from 0..7
;expmlp; mode=[0,0,1,1,1,0,0,0] is ADC3, ADC4, ADC5 is active and in single mode

key_adc=byte("[ADC")
key_adc_end=byte("]")
ADC_mode=intarr(16)

mode=0; 0:not active  1:single 2:coincidence

active_adc_key=bytarr(8,3)

; find the key for adc mode
key2=byte("active=2") ; coincidence
key1=byte("active=1") ; single
key0=byte("active=0") ; not active

active_adc_key(*,0)=key0
active_adc_key(*,1)=key1
active_adc_key(*,2)=key2

;***********************************************



    p0=where(byte_array eq key_adc(0) )
    p1=where(byte_array(p0+1) eq key_adc(1))
    p2=where(byte_array(p0(p1)+2) eq key_adc(2))

    synch_id=p0(p2)
    s_synch=size(synch_id)
    nsynch=s_synch(1)



for nsy=0,nsynch-1 do begin
    i=synch_id(nsy)+1

    if byte_array(i+4) eq key_adc_end(0) then begin  ; "[ADC" key word found
       ;print,string(byte_array(i+3))
       found=byte_array(i+16:i+26)
        ;print,string(found)
         ADC_mode(nsy)=byte_array(i+26)-48
         ;print,string(byte_array(i+26)-48)

    endif
    if byte_array(i+5) eq key_adc_end(0) then begin  ; "[ADC" key word found
       ;print,string(byte_array(i+3))+string(byte_array(i+4))
       ;print,byte_array(i+3),byte_array(i+4)
       found=byte_array(i+17:i+27)
        ;print,string(found)
        ADC_mode(nsy)=byte_array(i+27)-48
       ;print,string(byte_array(i+27)-48)

    endif

 endfor
;print,string(ADC_mode)
return,ADC_mode

end