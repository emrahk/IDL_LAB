pro readxrdproc, inpf, procstr, update=update, bincontent=allproc

;This program reads iXRD processed mode file and places the contents into the
;procstr structure
;
; INPUTS
;
; inpf: name of the input processed mode binary
; procstr: if update set, existing processed mode structure
;
; OUTPUTS
;
; procstr: processed mode output structure containing spectra and
;          light curves
;
; OPTIONAL INPUTS
;
; update: If set, update the given procstr
;
; OPTIONAL OUTPUT
;
; bincontent: If given, the binary file can be accessed for diagnostic
;             purposes
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
; 27/09/2022
;
; fixed negative temperature cases
;

;check if updating existing structure

IF NOT keyword_set(update) THEN update=0
  
;get file information

openr,1,inpf
status=fstat(1)

allproc=bytarr(status.size)
readu,1,allproc
close,1


IF NOT update THEN procstr=create_struct('unread',0,'runnum',uint(0),$
                                         'rtcnt',ulong(0),'src_id',0,$
                           'single1',uintarr(300),'single2',uintarr(300),$
                           'single3',uintarr(300),'double1',uintarr(300),$
                           'double2',uintarr(300),'double3',uintarr(300),$
                           'double4',uintarr(300),'double4',uintarr(300),$
                           'double6',uintarr(300),'mult',uintarr(300),$
                           'lc1',uintarr(2000),'lc2',uintarr(2000),$
                           'lc3',uintarr(2000))


procstr.unread=allproc[0]
procstr.runnum=allproc[1]+allproc[2]*256U
procstr.rtcnt=allproc[3]+allproc[4]*256UL+allproc[5]*256UL*256UL+allproc[6]*256UL*256UL*256UL
peocstr.src_id=allproc[7]

subtype=allproc[8]
pacno=allproc[9]

case subtype OF
   0:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.single1[i+15]=spval
      ENDFOR
   END
   1:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.single2[i+15]=spval
      ENDFOR
   END
   2:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.single3[i+15]=spval
      ENDFOR
   END
   3:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double1[i+15]=spval
      ENDFOR
   END
   4:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double2[i+15]=spval
      ENDFOR
   END
   5:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double3[i+15]=spval
      ENDFOR
   END
   6:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double4[i+15]=spval
      ENDFOR
   END
   7:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double5[i+15]=spval
      ENDFOR
   END
   8:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.double6[i+15]=spval
      ENDFOR
   END
   9:BEGIN
      FOR i=0, 250 DO BEGIN
         spval=2*i+(2*i+1)*256
         procstr.mult[i+15]=spval
      ENDFOR
   END
   10:BEGIN
      FOR i=0, 250 DO BEGIN
         lcval=2*i+(2*i+1)*256
         procstr.lc1[(250*pacno)+i]=lcval
      ENDFOR
   END
   11:BEGIN
      FOR i=0, 250 DO BEGIN
         lcval=2*i+(2*i+1)*256
         procstr.lc2[(250*pacno)+i]=lcval
      ENDFOR
   END
   12:BEGIN
      FOR i=0, 250 DO BEGIN
         lcval=2*i+(2*i+1)*256
         procstr.lc3[(250*pacno)+i]=lcval
      ENDFOR
   END
ENDCASE

   
END

