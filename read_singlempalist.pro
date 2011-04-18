pro read_singlempalist, fname, ev, adc_mode=adc_mode, active_adc=active_adc, endtime=endtime
;
;This program reads CZT pixel detector data and writes events into ev array
;for later use adc_mode and active_adc can be optionally read
;use only for reading the MPA3 binary .LST files
;
;USES
;
;find_header
;read_data
;
; Pick the lst file
list_header_end=byte("[LISTDATA]")

fil=fname
l=strlen(fname)

IF (l eq 0) THEN BEGIN
  print,'No file selected......'
  return
ENDIF

;**************************************************************
; Find and read the header info
Header=find_header(data_file=fil,header_text_ends=header_text_ends,active_adc=active_adc,adc_mode=adc_mode,$
endtime=endtime)
;**************************************************************

;**************************************************************
; Read the MPA3 list mode data into an array (EV) event by event.
; Each row contains recorded coincident data (by 16 pixels)
; after an event trigger.
ev=read_data(data_file=fil,header_text_ends=header_text_ends,active_adc)
;**************************************************************

END
;////////////////////////////////////////////////////////////////////////////////////////////
