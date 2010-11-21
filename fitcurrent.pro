pro fitcurrent, finecurrent, data=data, dir=dir

;this program reads the ESRF log file for beam current which is taken with 5 minute intervals,
;and then interpolates it to one minute intervals. Sets a starttime, and put current with
;one minute intervals from this starttime into an array.
;srcur.log is the ESRF current log file

IF NOT keyword_set(data_dir) THEN dir='T:'
fname=dialog_pickfile(filter='*.log',title='filename',GET_PATH=path,PATH=dir)

openr,1,fname
nlines=file_lines(fname)
data=intarr(2,nlines)
sline=strarr(1)
;set starttime as May06, 19:30:00 2010;
;roll everything to minutes
starttime=19.*60.+30.

for i=0,nlines-1 do begin
  readf,1,sline
  cleave = STRSPLIT(sline, ' ', /EXTRACT)
  day=float(cleave[2])
  current=float(cleave[5])
  timeall=cleave[3]
  cleave2 = STRSPLIT(cleave[3], ':', /EXTRACT)
  hour=float(cleave2[0])
  min=float(cleave2[1])
  second=float(cleave2[2])
  IF second gt 30. THEN min=min+1.
  ;convert to minute from start time
  time=(day-6.)*(60.*24)+hour*60.+min-starttime
  data[0,i]=time
  data[1,i]=current
  endfor
  
  close,1
  
  ;we need to fix jumps as jumps occur quite fast but currently not sure how that problem will be fixed
  ;need to do a post check
  
  totaltime=long(max(data[0,*]))
  finetime=findgen(totaltime)
  finecurrent=interpol(data[1,*],data[0,*],finetime)
  
  end
  