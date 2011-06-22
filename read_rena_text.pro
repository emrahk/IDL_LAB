pro read_rena_text,codat,pl, data_dir=data_dir, fname=fname

;This program reads RENA Text outputs, almost obsolete as binary files are used
;for IO

;INPUT
;
;pl: planar channel
;
;OUTPUT
;
;codat: event list file same format as the MPA event list
;
;OPTIONAL INPUTS
;
;data_dir: provide if you want to pick a file with a prompt. If not given 
;default is the currecnt directory
;
;fname: provide if you want to directly read out a filename
;

IF NOT keyword_set(fname) THEN BEGIN
  IF NOT keyword_set(data_dir) THEN data_dir='.\'
  fname=dialog_pickfile(filter='*.txt',title='filename',GET_PATH=path,PATH=data_dir)
ENDIF

openr,1,fname
nlines=file_lines(fname)
;data=intarr(3L,nlines-1)
morehits=strarr(nlines-1)
sline=strarr(1)
readf,1,sline

ts=0L
tsl=0L
timestamps=0L
ind=0L
codat=intarr(36,nlines)
j=0L

readf,1,sline
cleave = STRSPLIT(sline, ' ', /EXTRACT)
channel=fix(cleave[0])
amp=fix(cleave[1])
tsfix=fix(cleave[2])
codat[channel,j]=amp
tsfixc=tsfix

for i=1L,nlines-2 do begin
;for i=1L,20 do begin
  readf,1,sline
  cleave = STRSPLIT(sline, ' ', /EXTRACT)
  channel=fix(cleave[0])
  amp=fix(cleave[1])
  tsfix=fix(cleave[2])

  IF tsfix ne tsfixc THEN BEGIN
    tsfixc=tsfix
    j=j+1L
    ENDIF
  codat[channel,j]=amp
 ; morehits[i]=cleave[3]
 
  endfor
  
  close,1
  
  
  codat=codat[*,0:j]

  xx=where(codat[pl,*] ne 0)
  codat[pl,xx]=16384-codat[pl,xx]
  
  
 
  end
  