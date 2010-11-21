function pickreadorg_wp, an_thr=an_thr, cat_thr=cat_thr, pln=pln, data_dir=data_dir, renumerate=renumerate

;This program is the simplest wrapper to query a MPA .lst file,
; read and organize it. It only returns the cleaned up structure


IF NOT keyword_setx(pln) then catn=0 ELSE catn=pln
IF NOT keyword_set(an_thr) then an_thr=150.
IF NOT keyword_set(cat_thr) then cat_thr=150.
IF NOT keyword_set(data_dir) THEN data_dir='C:\Documents and Settings\ekalemci\Desktop\'
IF NOT keyword_set(renumerate) THEN renumerate=0.
fname=dialog_pickfile(filter='*.lst',title='filename',GET_PATH=path,PATH=data_dir)

read_singlempalist, fname, ev, adc_mode=adc_mode, active_adc=active_adc
reorganize_wc,ev,an_thr,cat_thr,clean,catn=catn,maxc=n_elements(active_adc),renumerate=renumerate

return,clean

end