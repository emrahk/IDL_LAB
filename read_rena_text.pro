pro read_rena_text,codat,pl, data_dir=data_dir, fname=fname

;This program reads the text output of RENA 3 evaluation system and
;converts it into the event list similar to MPA system.

;INPUT
;
;pl: an array of channel numbers of planar or cathodes
;
;OUTPUT
;
;codat: event list
;
;OPTIONAL INPUTS
;
;data_dir: directory with the data
;
;fname: filename to be read
;
;NOTES & BUG FIXES
;
;JAN 24 2012
;
;Now the program handles an array of channels
;

;get the full filename
IF (keyword_set(data_dir) AND keyword_set(fname)) THEN filename=data_dir+fname
IF ((NOT keyword_set(data_dir)) AND keyword_set(fname)) THEN filename=fname
IF (keyword_set(data_dir) AND (NOT keyword_set(fname))) THEN fname=dialog_pickfile(filter='*.txt',title='filename',GET_PATH=path,PATH=data_dir)
IF ((NOT keyword_set(data_dir)) AND (NOT keyword_set(fname))) THEN fname=dialog_pickfile(filter='*.txt',title='filename',GET_PATH=path,PATH='.')

;read the file
openr,1,fname
nlines=file_lines(fname)
morehits=strarr(nlines-1)
sline=strarr(1)

;read the header, skip
readf,1,sline

;initiate variables
ts=0L
tsl=0L
timestamps=0L
ind=0L
codat=intarr(36,nlines)
j=0L

;read the first line
readf,1,sline
cleave = STRSPLIT(sline, ' ', /EXTRACT)
channel=fix(cleave[0]) ;pixel info
amp=fix(cleave[1])     ;amplitude
tsfix=fix(cleave[2])   ;time stamp
codat[channel,j]=amp   ;write the first lines
tsfixc=tsfix           ;record the time stamp

;read the other lines, record to the same column until time stamp changes
FOR i=1L,nlines-2 DO BEGIN
  readf,1,sline
  cleave = STRSPLIT(sline, ' ', /EXTRACT)
  channel=fix(cleave[0])
  amp=fix(cleave[1])
  tsfix=fix(cleave[2])

  IF tsfix NE tsfixc THEN BEGIN
    tsfixc=tsfix
    j=j+1L
    ENDIF
  codat[channel,j]=amp
 
ENDFOR
  
close,1
  
codat=codat[*,0:j]

;take care of the planar

FOR k=0, n_elements(pl)-1 DO BEGIN
   xx=where(codat[pl[k],*] ne 0)
   IF xx[0] NE -1 THEN codat[pl[k],xx]=16384-codat[pl[k],xx]
ENDFOR
  
END
  

