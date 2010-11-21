function pickread, data_dir=data_dir

;This program is the simplest wrapper to query a MPA .lst file, read and give the event list as output.
; It only returns the cleaned up structure


IF NOT keyword_set(data_dir) THEN data_dir='C:\Documents and Settings\ekalemci\Desktop\'
fname=dialog_pickfile(filter='*.lst',title='filename',GET_PATH=path,PATH=data_dir)

read_singlempalist, fname, ev, adc_mode=adc_mode, active_adc=active_adc

return,ev

end