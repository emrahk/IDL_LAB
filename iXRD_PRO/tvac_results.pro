pro tvac_results, outstr
  
;This program reads TVAC output files and merge with the recorded data
;to create a complete dataset
  
;INPUTS
;
; NONE
;
; OUTPUTS
;
; outstr: output structure with the given information
;
; OPTIONAL INPUTS
;
; NONE
;
; USED BY
;
; NONE
;
; USES
;
; read_rawnv
; readixrd_hk
;
;
; LOGS
;
; Created by EK, Jan 2022
;

  ;change if you are running in another directory
  mdir='../../tests_documents/spectrum_tests/Spectrum_Raw/HV_TVAC_iXRD/'

  dirs=['tvac2_01_07_inbox','tvac2_01_07_intvac','tvac_01_07_tvroom3',$
        'tvac_01_07_tvroom6','tvac_01_07_tvroom9','tvac_01_07_tv30',$
        'tvac_01_07_tv45','tvac_01_07_tv55s','tvac_01_07_tv55l',$
        'tvac_01_07_tv59s2','tvac_01_07_tv45d','tvac_01_07_tv30d',$
        'tvac_01_07_tv15d','tvac_01_07_tv0d','tvac_01_07_tvm15s',$
        'tvac_01_07_tvm15d','tvac_01_07_tvm15s2','tvac_01_07_tv0u',$
        'tvac_01_07_tvlast']
  trena=[[18.5,18.5],[19.5,20.0],[20.7,21.0],$
         [25.,25.],[23.1,23.1],[29.3,30.6],$
         [44.3,46.], [54.7,56.6],[56.8,58.8],$
         [58.8,60.5],[45.1,44.1],[29.8,29.],$
         [14.6,14.],[0.8,0.8],[-11.7,-11.1],$
        [-10.7,-10.9],[-9.3,-9.3],[2.0,3.0],[12.3,16.9]]
  tcoll=[[18.5,18.5],[19.5,20.0],[17.9,18.8],$
         [21.,21.],[21.3,21.3],[23.7,24.3],$
         [34.1,35.0],[49.9,50.8],[52.0,55.3],$
         [55.3,56.7],[50.9,49.5],[38.9,37.9],$
         [27.6,26.5],[14.3,13.6],[-7.3,-7.5],$
        [-8.4,-9.4],[-9.4,9.4],[-5.3,-4.4],[2.5,6.2]]
  pressure=[[1E5,1E5],[1e5,1e5],[1.3e-3,1.2e-3],$
            [1e-3,1e-3],[8e-4,8e-4],[4e-3,4e-3],$
            [6e-3,6.5e-3],[1.6e-3,1.5e-3],[1.5e-3,1.5e-3],$
            [1.0e-3,9e-4],[2e-4,2.2e-4],[1.3e-4,1.3e-4],$
            [1e-4,1e-4],[8.4e-5,8.2e-5],[6.4e-5,6.4e-5],$
           [6.2e-5,6.0e-5],[6.0e-5,6.0e-5],[7.1e-5,7.3e-5],[8.2e-5,8.4e-5]]
  runtime=[30,30, 30, 30, 300, 30, $
           30, 30, 580, 300, 30, 30,$
          30, 30, 30 , 580, 30, 30, 580]
  hitlimit=[2000, 2000, 2000, 2000, 4000, 4000, $
            4000, 4000, 12000, 4000, 4000, 6000, $
           4000, 4000, 4000, 8000, 4000, 4000, 12000]
  cond=['box','tvac','vacroom','vacroom','vacroom','vac30',$
        'vac45','vac55','vac55','vac55','vac45','vac30',$
       'vac15','vac0','vacm15','vacm15','vacm15','vac0','vacroom']


  outstr1=create_struct('dir',dirs[0],'trena',fltarr(2),'tcoll',fltarr(2),$
                       'tdb',fltarr(2),'pres',fltarr(2),'runtime',0, $
                       'hitlimit',0,'centch',fltarr(2,4),'fwhm',fltarr(2,4),$
                       'spe',intarr(5,512),'lc',fltarr(600),'nhits',0,$
                       'etrig',0,'cond','box','errors',ulonarr(2,20))

  outstr=replicate(outstr1,19)
  

  FOR i=0, 18 DO BEGIN
     
    ;find files

     rawf=FILE_SEARCH(mdir+dirs[i], '*.raw')
     hkf=FILE_SEARCH(mdir+dirs[i], '*.hk')

    ;read raw and housekeeping files

     read_rawnv,rawf, outb, oute, outt
     readxrdhk,hkf, outhk

    ;populate outstr
     outstr[i].dir=dirs[i]
     outstr[i].trena=trena[*,i]
     outstr[i].tcoll=tcoll[*,i]
     outstr[i].tdb=[outhk.temp_i,outhk.temp_f]
     outstr[i].pres=pressure[*,i]
     outstr[i].runtime=runtime[i]
     outstr[i].hitlimit=hitlimit[i]
     outstr[i].nhits=n_elements(oute)/36
     outstr[i].etrig=outhk.etrig
     outstr[i].cond=cond[i]
     outstr[i].errors=outhk.errors

     ;spectral stuff

     pixn=[0,16,17,24,35]
     FOR j=0, 3 DO BEGIN
        spe=histogram(oute[pixn[j],*],min=1,max=4095,bins=8)
        x=findgen(512)
        yy=where(spe NE 0)
        yfit = GAUSSFIT(x[yy], spe[yy], coeff, NTERMS=3, measure_errors=sqrt(spe[yy]), sigma=sigmax)
        fwhm=2*SQRT(2*ALOG(2))*coeff[2]
        fwhm_err=2*SQRT(2*ALOG(2))*sigmax[2]
        outstr[i].spe[j,*]=spe
        outstr[i].fwhm[*,j]=[fwhm,fwhm_err]
        outstr[i].centch[*,j]=[coeff[1],sigmax[1]]
     ENDFOR
     spec=histogram(4096-oute[pixn[j],*],min=1,max=4095,bins=8)
     outstr[i].spe[4,*]=spec

     ;light curve

     tims=outt-outt[0]
     lc=histogram(tims,min=0, max=599, bins=1)
     outstr[i].lc=lc
ENDFOR
  
  
END

  
