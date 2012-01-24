pro read_rena_bin, outev, pl, allevents=allevents, data_dir=data_dir

;this program reads RENA binary files. It is the same as read_rena_binary, except
; this version picks the file from a list

;
;INPUT
;
;infile : name of the RENA binary file
;
;pl: an array of the channel numbers for planar
;
;OUTPUTS
;
;outev: Output event list file in the similar form to mpa lists
;
;OPTIONAL OUTPUTS
;
;allevents: includes stamps and early hits
;
;OPTIONAL INPUT
;
;data_dir : data directory to search for files
;

;Jan 24, 2012
;
;Now the program allows an array of planar or cathode electrodes.

IF NOT keyword_set(data_dir) THEN data_dir='./'
fname=dialog_pickfile(filter='*.bin',title='filename',GET_PATH=path,PATH=data_dir)

openr,1,fname
status=fstat(1)
n_events=status.size/6L

;each event is 6 bytes
allevents=bytarr(6,n_events)
readu,1,allevents
close,1

;get channel number and more hits

morehits=where(allevents(1,*) ge 128)
hitborder=where(allevents(1,*) lt 128)

mhind=intarr(n_events)
mhind(morehits)=1
chan=reform(allevents(1,*)-mhind*128)

;get ADC

adc=intarr(n_events)
adc=reform(allevents(3,*)+256*allevents(2,*))

;get timestamps

ts=reform(allevents(5,*)+256*allevents(4,*))
ts=uint(ts)

nev=n_elements(hitborder)
outev=intarr(36,nev)
evhit=hitborder(0)
for k=0,evhit do outev(chan(evhit-k),0)=adc(evhit-k)

for j=1L, nev-1L do begin
  evhit=hitborder(j)-hitborder(j-1L)
  for k=0,evhit-1 do outev(chan(hitborder(j)-k),j)=adc(hitborder(j)-k)
  endfor

for k=0,n_elements(pl)-1 do begin
   xx=where(outev[pl[k],*] ne 0)
   IF xx[0] NE -1 THEN outev[pl[k],xx]=16384-outev[pl[k],xx]
endfor

end
