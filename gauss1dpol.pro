pro gauss1dpol, x, a, f, pder

; Gauss + a0+ a1 x  to be used in fitting

        z = double( x - a[1] )/a[2]
        zz = z*z

        gaussx = exp( -zz / 2 )
        
        f = a[0] * gaussx+a[3]+a[4]*x
        
        pder = dblarr( n_elements(x), n_elements(a))
                
        fsig = a[0] / a[2]

        pder[*,0] = gaussx
        pder[*,1] = gaussx * z * fsig
        pder[*,2] = gaussx * zz * fsig
        pder[*,3] = 1.
        pder[*,4] = x  

return
 end
