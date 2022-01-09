pro readxrdhk, inpf, hkstr

;This program reads iXRD housekeeping file and places the contents into the
;hkstr structure
;
; INPUTS
;
; fname: name of the input housekeeping binary
;
; OUTPUTS
;
; hkstr: housekeeping structure
;
; OPTIONAL INPUTS
;
; NONE
;
; USED BY
;
; NONE
;
; USES
;
; NONE
;
; LOGS
;
; Created by EK
;
; 27/12/2021
;
; fixed negative temperature cases
;

;get file information

openr,1,inpf
status=fstat(1)

allhk=bytarr(status.size)
readu,1,allhk
close,1

hkstr=create_struct('unread',0,'runnum',uint(0),'rtcnt',ulong(0),'time',0d,$
                    'src_id',0,'version',0,'conf_ver',0,'temp_i',0.,$
                    'temp_f',0.,'nhits',ulong(0),'etrig',uint(0), $
                    'errors',ulonarr(2,20))


hkstr.unread=allhk[0]
hkstr.runnum=allhk[1]+allhk[2]*256U
hkstr.rtcnt=allhk[3]+allhk[4]*256UL+allhk[5]*256UL*256UL+allhk[6]*256UL*256UL*256UL
;
;time1=allhk[7]+allhk[7]*256UL+allhk[7]*256UL*256UL+allhk[10]*256UL*256UL*256UL
;time2= (allhk[11]*256 + allhk[12])/65536.
;hkstr.time=time1+time2
hkstr.src_id=allhk[13]
hkstr.version=allhk[14]
hkstr.conf_ver=allhk[15]
temp_i=allhk[16]*10+allhk[17]+allhk[18]/10.
temp_f=allhk[19]*10+allhk[20]+allhk[21]/10.

IF temp_i GT 128. THEN temp_i=-(255.-temp_i)
IF temp_f GT 128. THEN temp_f=-(255.-temp_f)

hkstr.temp_i=temp_i
hkstr.temp_f=temp_f
;hkstr.nhits=allhk[22]+allhk[4]*256UL+allhk[5]*256UL*256UL
hkstr.etrig=allhk[25]+allhk[26]*256U
;allhk[27:38] for last raw, processed, hk to be filled later

;errors
nerrs=0
errors=ulonarr(2,20)

FOR i=0,19 DO BEGIN
   IF allhk[39+i*5] NE 0 THEN BEGIN
      nerrs=nerrs+1
      errors[0,i]=allhk[39]
      errors[1,i]=allhk[40]+allhk[41]*256UL+allhk[42]*256UL*256UL+allhk[43]*256UL*256UL*256UL
      print,errors[*,i]
   ENDIF
ENDFOR

hkstr.errors=errors
END

;                            unsigned char lastRawBlockWritten[4] = {};
;                            *(unsigned long*)lastRawBlockWritten = ii;
;                            hk_payload[27] = lastRawBlockWritten[0];
;                            hk_payload[28] = lastRawBlockWritten[1];
;                            hk_payload[29] = lastRawBlockWritten[2];
;                            hk_payload[30] = lastRawBlockWritten[3];
;                            hk_payload[31] = 0;
;                            hk_payload[32] = 0;
;                            hk_payload[33] = 0;
;                            hk_payload[34] = 0;
;                            unsigned char lastHKBlockWritten[4] = {};
;                            *(unsigned long*)lastHKBlockWritten = ii_hk;
;                            hk_payload[35] = lastHKBlockWritten[0];
;                            hk_payload[36] = lastHKBlockWritten[1];
;                            hk_payload[37] = lastHKBlockWritten[2];
;                            hk_payload[38] = lastHKBlockWritten[3];
;                            unsigned char timestamp[6];
;                            getTimeStamp(timestamp);

;                            if(temps_final[0] < 3){
;                                hk_payload[39+(last_error_index * 5)] = 0x05;
;                                hk_payload[40+(last_error_index * 5)] = timesta;mp[2];
;                                hk_payload[41+(last_error_index * 5)] = timestamp[3];
;                                hk_payload[42+(last_error_index * 5)] = timestamp[4];
;                                hk_payload[43+(last_error_index * 5)] = timestamp[5];
;                                last_error_index++;
 



  
