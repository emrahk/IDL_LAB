pro moncurs,image,format=format,_extra=_extra,x_tab=x_tab,y_tab=y_tab,i_tab=i_tab

;+
; moncurs,[image],[_extra],[format=format],[x_tab=x_tab],[y_tab=y_tab],[i_tab=i_tab]
; left button: give x and y (and intensity if image is given)
; middle button : give x and y and draw a cross
; right button: exit
;
; C. Morisset, 1997
; V 0.2 04/2004 : option to return the x and y values
;
;-

if n_elements(format) eq 0 then format = '(3f14.2)'
if n_params() eq 1 then image_included = 1 else image_included = 0

x_tab=dblarr(1)
y_tab=dblarr(1)
if image_included then i_tab=dblarr(1)

;if image_included then print,'      x     y    I' else print,'      x    y'

salida = 0
repeat begin
    cursor,x,y,/down
    if (!MOUSE.button  eq 4) then salida = 1
    if not salida then begin
        if image_included then begin
            intens = interpolate(reform(image),x,y)
            print,x,y,intens,format=format,_extra=_extra 
        endif else print,x,y,format=format,_extra=_extra
        if !MOUSE.button eq 2 then plots,x,y,psym=1
        x_tab = [x_tab,x]
        y_tab = [y_tab,y]
        if image_included then i_tab = [i_tab,intens]
    endif
endrep until salida eq 1

if n_elements(x_tab) gt 1 then begin
    x_tab = x_tab[1:*]
    y_tab = y_tab[1:*]
    if image_included then i_tab = i_tab[1:*]
endif
end

