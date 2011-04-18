function search_header, byte_array , key

s1=size(key)
p0=where(byte_array eq key(0))

for i=1,s1(1)-1 do begin
    p=where(byte_array(p0+i) eq key(i))

    ;print,byte_array(p0(p)),key(i)
endfor

return,p0(p)
end