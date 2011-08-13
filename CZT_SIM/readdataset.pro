;This program reads an entire dataset of weighting potentials and electric field files 
; to be used by electron_motion and hole_motion pro


pro readdataset, eoutx, eoutz, fullwpa, fullwpc, fullwpst,$
  dirwpa=wpadir, dirste=stedir, dircat=catdir, diref=efdir,$
  maindir=dirmain, arrsize=sizearr, justef=justef
  
;INPUTS : none
;
;OPTIONAL INPUTS
;
;IF none of the directories are provided below, the program prompts for them
;wpadir: directory of the weighting potential anode Comsol files
;stedir: directory of weighting potential steering electrode Comsol files
;catdir: directory of weighting potential cathode Comsol files
;efdir: directory of electric field comsol files
;dirmain: main directory that includes these directories above
;sizearr: size of the output array
;justef: most of the time it is only necessary to read electric field files
;         EVEN IF YOU CHOOSE JUSTEF, YOU STILL NEED TO SPECIFY DUMMY VARIABLES
;         FOR fullwpa, fullwpc and fullwpst
;
;OUTPUTS
;
;eoutx: electric field in x direction
;eoutz: electric field in z direction
;fullwpa: all anode weighting potentials in a single array
;fullwpc: all cathode weighting potentials in a single array
;fullwpc: all steering electrode weighting potentials in a single array
  
IF NOT keyword_set(sizearr) THEN sizearr=[3909,1001]
IF NOT keyword_set(dirmain) THEN dirmain='/Users/emrahkalemci/CZTMODEL/COMSOL_OUT/'

IF NOT KEYWORD_SET(justef) THEN BEGIN
  fullwpa=fltarr(16, sizearr[0],sizearr[1])
  fullwpc=fltarr(16, sizearr[0],sizearr[1])
  fullwpst=fltarr(5, sizearr[0],sizearr[1])

  IF NOT keyword_set(wpadir) THEN pickf=dialog_pickfile(/READ,filter='*.txt',title='Pick any anode wp File',PATH=dirmain, GET_PATH=wpadir) 

  print,'Reading all anode weighting potential values into a single array'
  FOR i=0,15 DO BEGIN
    fname='WPA_'+strtrim(string(i+1),1)+'.txt'
    print,'Reading '+fname+' as the anode no '+strtrim(string(i),1)
    read_single_wp, wpout, data_dir=wpadir, infile=fname
    fullwpa(i,*,*)=wpout
  ENDFOR
  
 
  IF NOT keyword_set(stedir) THEN pickf=dialog_pickfile(/READ,filter='*.txt',title='Pick any steering electrode wp File',PATH=dirmain, GET_PATH=stedir) 

  print,'Reading all steering weighting potential values into a single array'
  FOR i=0,4 DO BEGIN
    fname='WPST_'+strtrim(string(i+1),1)+'.txt'
    print,'Reading '+fname+' as the steering electrode no '+strtrim(string(i),1)
    read_single_wp, wpout, data_dir=stedir, infile=fname
    fullwpst(i,*,*)=wpout
  ENDFOR
  
  IF NOT keyword_set(catdir) THEN pickf=dialog_pickfile(/READ,filter='*.txt',title='Pick any cathode wp File',PATH=dirmain, GET_PATH=catdir) 

  print,'Reading all cathode weighting potential values into a single array'
  FOR i=0,15 DO BEGIN
    fname='WPC_'+strtrim(string(i+1),1)+'.txt'
    print,'Reading '+fname+' as the cathode no '+strtrim(string(i),1)
    read_single_wp, wpout, data_dir=catdir, infile=fname
    fullwpc(i,*,*)=wpout
  ENDFOR

ENDIF
  
print, 'Reading electric field file and writing to arrays'
  
IF NOT keyword_set(efdir) THEN read_single_ef, eoutx, eoutz ELSE $
  read_single_ef, eoutx, eoutz, data_dir=efdir


END

