function peakfind2,sp,x1,x2,show=show,npol=npol,errs=errs, par=par, cent=cent

;this program fits the given peak in the spectrum
;returns a structure with fit parameters and errors

if NOT keyword_set(show) then show=0  ; show the fit on screen (good for tests, not good for multiple fittings)
if NOT keyword_set(npol) then npol=1  ; degree of polynomial in the fit, choices are 1 and 2, but
                                      ; 2 degree of freedom sometimes behave like gauss

;input parameters
;
;sp: spectrum to be fitted
; x1 and x2 range in the spectrum to be used for fitting

;optional
;par: initial fit parameters. If not given, estimated from the data
;errs: errors can be provided with spe, or can be calculated assuming poisson

;03/05/2011
;make sure that x2 is within the spectra given


IF x2 GE n_elements(sp) THEN x2=n_elements(sp)-1

spec=sp(x1:x2) ; get the region to be fitted
s_sp=size(sp(x1:x2)) 
x_fit=indgen(s_sp(1))+x1;-1  ;create an x variable in the region of interest

dim=size(spec)
xcor=indgen(dim(1))
w=fltarr(dim(1))

IF NOT keyword_set(par) THEN BEGIN
  par=fltarr(6) ;3 for gauss, 3 for polynomial (5 will be used for degree 1)
  smax=max(spec,cent);=max(total(xcor*spec)/total(spec), max of the peak
  var=total((cent-xcor)^2*spec)/total(spec) ; to estimate width
  var=sqrt(var)
  par(0)=smax
  par(1)=cent ;centroid
  par(2)=var
;polynomial assumed to be 0
endif

;print,par
;w(*)=1
xx=where(spec ne 0)
IF NOT keyword_set(errs) THEN w(xx)=float(spec(xx))/sqrt(float(spec(xx))) ELSE w=1./errs

IF npol NE 1 THEN specfit=curvefit(xcor,spec,w,par, sigma) ELSE BEGIN               ;special treatment for one degree pol
                   par1p=[par(0:2),1.,0]
                   specfit=curvefit(xcor,spec,w,par1p, sigma, function_name = 'gauss1dpol')
                   ENDELSE
                   
LOADCT, 39      ;YK: loadct added

IF show eq 1 THEN BEGIN  ;to show fit

    plot,sp,psym=10,xr=[x1*0.9,x2*1.1],xstyle=1       ;YK: xrange uncommented, changed to +/- 10%
    oplot,x_fit,specfit,color=250,thick=3.0           ;YK: color changed to 250 from 100

  IF npol ne 1 THEN BEGIN
    z=(xcor-par(1))/par(2)
    oplot,x_fit,par(0)*exp(-z^2/2.),color=150,thick=2. 
    oplot,x_fit,par(3)+par(4)*xcor+par(5)*xcor^2.
    ENDIF ELSE BEGIN
      z=(xcor-par1p(1))/par1p(2)
    oplot,x_fit,par1p(0)*exp(-z^2/2.),color=150,thick=2. 
    oplot,x_fit,par1p(3)+par1p(4)*xcor
    par=par1p
    ENDELSE


  ;oplot,x_fit,par1p(3)+par1p(4)*xcor
  ;  print,par1p

    str1 = 'Centroid = ' + STRTRIM(par(1)+x1,1)       ;YK: added str1, str2, changed xyouts
    str2 = 'FWHM = ' + STRTRIM(abs(par(2))*2.35,1)
    XYOUTS, (x1+cent), !y.crange(1)*0.95, par(0), /ALIGN
    XYOUTS, (x1+cent), !y.crange(1)*0.90, str1, /ALIGN
    XYOUTS, (x1+cent), !y.crange(1)*0.85, str2, /ALIGN
;    xyouts,(x1+cent)*1.05,par(0),par(0)
;    xyouts,(x1+cent)*1.05,par(0)*0.9,par(1)+x1
;    xyouts,(x1+cent)*1.05,par(0)*0.8,abs(par(2))*2.35

 
ENDIF

par_str = CREATE_STRUCT('PAR', par, 'SIGMA', sigma) ;YK: output changed to structure, with sigma

return,par_str
end
