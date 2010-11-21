function find_header, data_file=data_file,header_text_ends=header_text_ends,active_adc=active_adc,adc_mode=adc_mode,$
endtime=endtime


;***********************************************************************************

; read the sellected lst binary file
; Find the header in the MPA binary file.
; search_header finds the ( [LISTDATA] )
; in the binary file indiicate that
; the header data ends.
list_header_end=byte("[LISTDATA]")
if n_elements(data_file) ne 0 then $ ; Grab the file if given.
      fil = data_file
if n_elements(header_text_ends) ne 0 then $ ; Grab the file if given.
      header_text_ends = header_text_ends

if n_elements(active_adc) ne 0 then $ ; Grab the file if given.
      active_adc = active_adc

if n_elements(adc_mode) ne 0 then $ ; Grab the file if given.
      adc_mode = adc_mode
CLOSE, 25
OPENR, 25, Fil
STATUS=FSTAT(25)
MAXLEN=STATUS.SIZE
if maxlen gt 50000000 then maxlen=50000000
header_size=15024

if maxlen lt 15000 then header_size=5155
if maxlen lt 6000 then header_size=4912

temp=bytarr(header_size) & Readu, 25, temp

Header_text_ends=search_header(temp,list_header_end)+11
;get start time, and file creation time, EK
headertext=string(temp)
endpos=strpos(headertext,'written')+8
endtime=strmid(headertext,endpos,19)
;print,starttime
;print,endtime
; print  the header info on screen
Header=temp(Header_text_ends-12:Header_text_ends-1)
Header_text=string(Header)
;print,Header_text,header_text_ends

start_ptr=header_text_ends(0);+1 ;+1 is CR
POINT_LUN, 25, 0 ;back to start position
;read the full header text
temp=bytarr(header_text_ends(0)) & Readu, 25, temp ;

; Look for active ADC in the header
; active=0   : ADC is not active
; active=2   : ADC is active
; function returns an array of active ADC with index
; and search for active_adc_key1=byte("active=2") ; coincidence
; and active_adc_key2=byte("active=1") ; single

;adc_mode=active_adc_mode_v1(temp(0:Header_text_ends))
adc_mode=active_adc_mode_v1(temp)

active_adc=where(adc_mode gt 0)
;active_adc=indgen(16)
;print,'Active ADCs:',active_adc

;print,'end of file ...'
return,Header_text
END
;////////////////////////////////////////////////////////////////////////////////////////////
