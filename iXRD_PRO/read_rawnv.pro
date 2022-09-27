pro read_rawnv, fname, outblocks, outev, outtime

;This program reads iXRD data and outputs event list compatible with
;other IDL programs

;INPUTS
;
; fname: Name of the file
;
; OUTPUTS
;
; outev: event list that can be used with the old RENA programs
; outblocks: The binary file expected from the iXRD with the given
;            fake data
; outtime: times of each hits
;
; OPTIONAL INPUTS
;
; NONE
;
; USED BY
;
; reorganize programs
;
; USES
;
; NONE
;
; LOGS
;
; Created by EK, Dec 2021
;
; Fixed timebits, but may be updated again
;

;read the file

  openr,1,fname
  fst=fstat(1)
  numblocks=fst.size/512L
  outblocks=bytarr(512,numblocks)
  outev=intarr(36,numblocks*40L) ;maximum, will be shortened to exact number later
  outtime=dblarr(numblocks*40L)
  readu,1,outblocks ; read the content to the array
  close,1

  p_i=0                         ; index inside a package
  hitbytes=bytarr(5)     ;bytes that hold the hit pixels
 
  j=0L                          ;actual number of hits
  hits=intarr(36)
 
  FOR i=0, numblocks-1 DO BEGIN   
       p_i=8
       WHILE p_i LE 428 DO BEGIN
       ; calculate time (to be fixed once again later)
       ;timesec=outblocks[p_i+3,i]+outblocks[p_i+4,i]*256.
       ;timesubs=(outblocks[p_i+1,i]+outblocks[p_i+2,i]*256.)/65536.
       
          timesec=outblocks[p_i+2,i]+outblocks[p_i+3,i]*256D
          timesec=timesec+outblocks[p_i+4,i]*(256D*256D)+outblocks[p_i+5,i]*(256D*256D*256D)
       timesubs=(outblocks[p_i,i]+outblocks[p_i+1,i]*256D)/65536D
       outtime[j]=timesec+timesubs
       p_i=p_i+6 ;pass to hitbytes
       hitbytes=outblocks[p_i:p_i+4,i]
       FOR k=0, 4 DO BEGIN
          FOR m=0,7 DO BEGIN
           IF hitbytes[k].bitget(m) EQ 1 THEN hits[k*8+m]=1
        ENDFOR
       ENDFOR
       
       p_i=p_i+5 ;pass to hit ADC values
       nhits=total(hits)

       ;Check if we have any hits
       IF ((nhits eq 0) AND (i eq numblocks-1)) THEN BEGIN
          print, 'Reading of blocks ended at hit number: ',j
          BREAK
       ENDIF
       
       FOR p=0,nhits-1 DO BEGIN
          hitin=where(hits EQ 1)
          outev[hitin[p],j]=(outblocks[p_i,i]+outblocks[p_i+1,i]*256.)
          p_i=p_i+2
       ENDFOR
       j=j+1
       hits=intarr(36) ;reset hits
       ENDWHILE
    ENDFOR

outev=outev[*,0:j-1] 
outtime=outtime[0:j-1]

 END

  
