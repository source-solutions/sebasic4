; --- THE SYTNAX TABLES -------------------------------------------------------

; THE OFFSET TABLE
; There is an offset value for each of the 56 BASIC commands.

org 0x3bc7
offst_tbl:
	defb	p_def_fn - $
	defb	p_put - $				; cat
	defb	p_mode - $				; format
	defb	p_udg - $				; move
	defb	p_reset - $				; erase
	defb	p_open  - $
	defb	p_close - $
	defb	p_merge - $
	defb	p_trace - $				; verify
	defb	p_beep - $
	defb	p_circle - $
	defb	p_pen - $				; ink
	defb	p_paper - $
	defb	p_clut - $				; bright
	defb	p_color - $				; flash
	defb	p_inverse - $
	defb	p_over - $
	defb	p_out - $
	defb	p_speed - $				; lprint
	defb	p_scroll - $			; llist
	defb	p_stop - $
	defb	p_read - $
	defb	p_data - $
	defb	p_restore - $
	defb	p_new - $
	defb	p_border - $
	defb	p_continue - $
	defb	p_dim - $
	defb	p_rem - $
	defb	p_for - $
	defb	p_goto - $
	defb	p_gosub - $
	defb	p_input - $
	defb	p_load - $
	defb	p_list - $
	defb	p_let - $
	defb	p_pause - $
	defb	p_next - $
	defb	p_poke - $
	defb	p_print - $
	defb	p_plot - $
	defb	p_run - $
	defb	p_save - $
	defb	p_randomize - $
	defb	p_if - $
	defb	p_cls - $
	defb	p_draw - $
	defb	p_clear - $
	defb	p_return - $
	defb	p_call - $				; copy
	defb	p_delete - $
	defb	p_edit - $
	defb	p_renum - $
	defb	p_palette - $
	defb	p_sound - $
	defb	p_on_error - $

; -----------------------------------------------------------------------------

org 0x3bff
	defs	2, 255					; IM2 vector

; -----------------------------------------------------------------------------

; THE PARAMETER TABLE
; For each of the 56 BASIC commands there are up to eight entries in the
; parameter table. These entries comprise command class details, required
; separators and, where appropriate, command routine addresses.

p_save:
	defb	tap_offst

p_load:
	defb	tap_offst

p_merge:
	defb	tap_offst

p_def_fn:
	defb	var_syn
	defw	def_fn

p_put:
	defb	two_c_s_num, ',', numexp_nofops
	defw	put
	
p_mode:
	defb	numexp_nofops
	defw	c_mode

p_udg:
	defb	numexp_nofops
	defw	c_udg

p_reset:
	defb	no_f_ops
	defw	reset

p_open:
	defb	num_exp, ',', str_exp, no_f_ops
	defw	open

p_close:
	defb	numexp_nofops
	defw	close

p_trace:
	defb	numexp_nofops
	defw	trace

p_beep:
	defb	two_c_s_num, no_f_ops
	defw	beep

p_circle:
	defb	two_csn_col, var_syn
.ifdef ROM0
	defw	rem					; no direct graphics support in text mode
.endif
.ifdef ROM1
	defw	circle
.endif

p_pen:
	defb	col_offst

p_paper:
	defb	col_offst

p_clut:
	defb	col_offst

p_color:
	defb	col_offst

p_inverse:
	defb	col_offst

p_over:
	defb	col_offst

p_out:
	defb	two_c_s_num, no_f_ops
	defw	fn_out

p_speed:
	defb	num_exp_0
	defw	speed

p_scroll:
	defb	num_exp_0
	defw	scroll

p_stop:
	defb	no_f_ops
	defw	stop

p_read:
	defb	var_syn
	defw	read

p_data:
	defb	var_syn
	defw	data

p_restore:
	defb	num_exp_0
	defw	restore

p_new:
	defb	num_exp_0
	defw	new

p_border:
	defb	numexp_nofops
	defw	border

p_continue:
	defb	no_f_ops
	defw	continue

p_dim:
	defb	var_syn
	defw	dim

p_rem:
	defb	var_syn
	defw	rem

p_for:
	defb	chr_var, '=', num_exp, tk_to, num_exp, var_syn
	defw	for

p_goto:
	defb	numexp_nofops
	defw	goto

p_gosub:
	defb	numexp_nofops
	defw	gosub

p_input:
	defb	var_syn
	defw	input

p_list:
	defb	var_syn
	defw	list

p_let:
	defb	var_rqd, '=', expr_num_str

p_pause:
	defb	num_exp_0
	defw	pause

p_next:
	defb	chr_var, no_f_ops
	defw	next

p_poke:
	defb	two_c_s_num, no_f_ops
	defw	poke

p_print:
	defb	var_syn
	defw	print

p_plot:
	defb	two_csn_col, no_f_ops
.ifdef ROM0
	defw	rem					; no direct graphics support in text mode
.endif
.ifdef ROM1
	defw	plot
.endif

p_run:
	defb	num_exp_0
	defw	run

p_randomize:
	defb	num_exp_0
	defw	randomize

p_if:
	defb	num_exp, tk_then, var_syn
	defw	c_if

p_cls:
	defb	no_f_ops
	defw	cls

p_draw:
	defb	two_csn_col, var_syn
.ifdef ROM0
	defw	rem					; no direct graphics support in text mode
.endif
.ifdef ROM1
	defw	draw
.endif

p_clear:
	defb	num_exp_0
	defw	clear

p_return:
	defb	no_f_ops
	defw	return

p_call:
	defb	num_exp_0
	defw	c_call

p_delete:
	defb	two_c_s_num, no_f_ops
	defw	delete

p_edit:
	defb	num_exp_0
	defw	edit

p_renum:
	defb	var_syn
	defw	renum

p_palette:
	defb	two_c_s_num, no_f_ops
	defw	palette

p_sound:
	defb	var_syn
	defw	sound

p_on_error:
	defb	var_syn
	defw	on_error
