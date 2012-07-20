FUNCTION READ_TABLE, filename, $
    columns=columns, nrows=nrows, nmax=nmax, double=double, text=text, head=head

; ----------------------------------------------------------
;+
; NAME:
;       READ_TABLE
;
; PURPOSE:
;       Read an ASCII table into a data array.
;
; AUTHOR:
;       Simon Vaughan (U.Leicester)
;
; CALLING SEQUENCE:
;       data = READ_TABLE('file.dat')
;
; INPUTS:
;       file - (string) file name 
;
; OPTIONAL INPUTS:  
;       columns - (integer vector) which columns of table to retain 
;       nrows   - (integer) number of lines to read 
;       nmax    - (integer) minimum size of file, default is 100,000
;       double  - (logical) whether to use double or single prec.
;       text    - (logical) whether to load text from file       
;       head    - (integer) number of lines to skip in header
;
; OUTPUTS:
;       2-dimensional data array (floating point values)
;
; DETAILS:
;       Data are assumed to be floating point numbers, by
;       default single precision, seperated by spaces in a
;       rectangular grid (ncols*nrow)
;
; Example calls:
;
; IDL> data = read_table('table.txt')
; IDL> data = read_table('table.txt',columns=[2,3])
; IDL> data = read_table('table.txt',n=100)
;
; HISTORY:
;       Based losely on DDREAD.PRO by Frank Knight (MIT)
;       11/01/2007 -  v1.0  - first working version
;       27/04/2007 -  v1.1  - added TEXT option
;       22/11/2007 -  v1.2  - added HEAD option
;       22/09/2008 -  v1.3  - HEAD now takes integer input
;       16/06/2010 -  v1.4  - fixed handling of text input
;                             using STRSPLIT function.
;
;-
; ----------------------------------------------------------

; options for compilation (recommended by RSI)

  COMPILE_OPT idl2, HIDDEN

; watch out for errors
  on_error,2

; ----------------------------------------------------------
; Check the arguments

; is the file name defined?
  if (n_elements(filename) eq 0) then begin
      filename=''
      read,'-- Enter file name (ENTER to list current directory): ',filename
      if (filename eq '') then begin
          list = findfile()
          print, list
          read,'-- Enter file name: ',filename
      endif
  endif

; is there a user-defined maximum file size?
  if (n_elements(nmax) eq 0) then nmax=100000L

; is there a user-defined number of lines to read
  if (n_elements(nrows) eq 0) then nrows=nmax

; sanity check
  if (nrows gt nmax) then nmax = nrows

; are we reading in single (=4) or double precision (=5)?
  type=4
  if (keyword_set(double)) then type=5

; are we reading numbers or text?
  if (keyword_set(text)) then type=7

; ----------------------------------------------------------
; Checks of the file existance and shape

; check the file exists
  if ((findfile(filename))[0] eq '') then begin
      print,'** File not found.'
      return,0
  endif

; find the number of columns in the file by reading first line
; into a string (tmp)
  ncols = 0
  tmp = ''
  openr, lun, filename, /get_lun
  if keyword_set(head) then begin
      for i=0,head-1 do readf, lun, tmp ; skip header
  endif
  readf,lun,tmp
  free_lun, lun

; remove whitespace
  tmp = ' ' + strcompress(strtrim(tmp,2))

; count the spaces (there is one per column)
  for i=0,strlen(tmp)-1 do begin
      ncols = ncols + (strpos(tmp,' ',i) eq i)
  end

; ----------------------------------------------------------
; load the data into an array

; define the data array ready to receive data

  data = make_array(size=[2,ncols,nrows,type,ncols*nrows])

; define a single line (row) array for reading each line
; except for text which is loaded a whole line at a time 

  if NOT KEYWORD_SET(text) then begin
      record = make_array(size=[1,ncols,type,ncols])
  endif else begin
      record = ''
  endelse

; Open the file ready to read

  openr, lun, filename, /get_lun

; skip header line if HEAD keyword is set

  if keyword_set(head) then begin
      for i=0,head-1 do readf, lun, tmp ; skip header
  endif

; Read each line one at a time, until either end-of-file
; or we reach nrows.

  n = 0L
  while (eof(lun) ne 1) do begin
      on_ioerror, IOERR
      error = 1
      readf, lun, record
;      print,record
;      help,record
      error = 0
      if KEYWORD_SET(text) then begin
          data[*,n] = STRSPLIT(record, ' ', /EXTRACT)
      endif else begin
          data[*,n] = record
      endelse
      n = n + 1L
      if (n eq nrows) then break

      IOERR:
      if (error eq 1) then begin
          print, '** Error reading line',n,' in READ_TABLE'
          free_lun,lun
          return,0
      endif

  endwhile

; Did we finish with the file or run out of rows in array?
  if (eof(lun) ne 1 && n ge nmax) then begin
      print,"** Increase nmax in READ_TABLE."
  endif

; Close the file
  free_lun, lun

; ----------------------------------------------------------
; Return the data array to the user

; trim the unused rows
  data = data[*,0:(n-1)]

; if no column selection, return entire array 
  if (n_elements(columns) eq 0) then return, data

; otherwise remove unwanted columns before returning
  indx=where((columns ge ncols-1),count)
  if (count eq 0) then begin
      data = data[columns,*]
  endif else begin
      print,'** Requested columns outside allowed range'
      print,'** Returning all columns from READ_TABLE'
  endelse

  return,data

END
; ----------------------------------------------------------
