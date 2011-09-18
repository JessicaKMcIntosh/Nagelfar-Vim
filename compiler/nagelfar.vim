" Vim compiler file
" =============================================================================
" Compiler:     tcl (Uses Nagelfar to check Syntax)
" Maintainer:   Lorance Stinson AT Gmail...
" Last Change:  2011-09-17
" License:      Public Domain
" GitHub URL:   https://github.com/LStinson/Nagelfar-Vim
" =============================================================================
" Description:
" This file allows syntax checking of .tcl files using Nagelfar.
" This is done using the compiler/quickfix features of Vim.
" Nagelfar can be downloaded from <http://nagelfar.berlios.de/>

if exists("current_compiler")
  finish
endif
let current_compiler = "tcl"

" Set defaults.
function! s:SetDefault(option, default)
    if !exists(a:option)
        exec 'let ' . a:option . '="' . a:default . '"'
    endif
endfunction
call s:SetDefault('g:nagelfar_disable_mappings', '0')
call s:SetDefault('g:nagelfar_map_prefix', '<Leader>n')
call s:SetDefault('g:nagelfar_options', '-H')
call s:SetDefault('g:nagelfar_signs', '0')
call s:SetDefault('g:loaded_nagelfar_ext', '0')

" Autocommand to create the marker signs after running :make.
if g:nagelfar_signs == 1
    autocmd QuickfixCmdPost make call nagelfar#CreateSigns()
endif

" Create user commands.
if g:loaded_nagelfar_ext == 0
    command! -nargs=0 NagelfarClear     :call nagelfar#ClearSigns()
    command! -nargs=0 NagelfarSigns     :call nagelfar#CreateSigns()
endif

" Key Mappings.
if g:nagelfar_disable_mappings == 0
    call nagelfar#MapKeys()
endif

" Build the 'make' command.
if exists('g:nagelfar_file')
    if exists('g:nagelfar_tclsh')
        let s:nagelfar_cmd=g:nagelfar_tclsh
    else
        let s:nagelfar_cmd='tclsh'
    endif
    let s:nagelfar_cmd.=' ' . g:nagelfar_file
else
    let s:nagelfar_cmd='nagelfar.tcl'
endif
let s:nagelfar_cmd.=' ' .g:nagelfar_options . ' %'
" Spaces MUST be escaped.
let s:nagelfar_cmd=substitute(s:nagelfar_cmd, '\s\+', '\\ ', 'g')

" From the Vim compiler files.
if exists(":CompilerSet") != 2 " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" Make sure the continuation lines below do not cause problems in
" compatibility mode.
let s:cpo_save = &cpo
set cpo-=C

execute 'CompilerSet makeprg=' . s:nagelfar_cmd 

CompilerSet errorformat=
    \%I%f:\ %l:\ N\ %m,
    \%f:\ %l:\ %t\ %m,
    \%-GChecking\ file\ %f

" Restore the saved compatibility options.
let &cpo = s:cpo_save
unlet s:cpo_save
