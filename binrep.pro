pro binrep,num,ind,n_el
; This program is used in for reading the binary file of MPA3 system. It is used to find the starting bit.
order=indgen(16)
bit=bytarr(16)
n=long(2)^order
for i=15,0,-1 do begin
    if num ge n(i) then begin
    bit(i)=1
    num=num-n(i)
    endif
endfor
ind=where(bit eq 1)
n_el=n_elements(ind)
;print,'num :',num,' ind:',ind,' n_el:',n_el
end
