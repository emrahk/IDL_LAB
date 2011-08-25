pro read_rena_binary, infile, outev, pl, allevents=allevents

;this program reads RENA binary files. 
;
;INPUT
;
;infile : name of the RENA binary file
;
;pl: the channel number for planar
;
;OUTPUTS
;
;outev: Output event list file in the similar form to mpa lists
;
;OPTIONAL OUTPUTS
;
;allevents: includes stamps and early hits
;
;NOTES BUG FIXES
;
;In the case of reading just one channel, there are no "morehits". Now program checks for it
;
openr,1,infile
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
IF morehits[0] NE -1 THEN mhind(morehits)=1
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

xx=where(outev[pl,*] ne 0)
IF xx[0] NE -1 THEN outev[pl,xx]=16384-outev[pl,xx]
end
