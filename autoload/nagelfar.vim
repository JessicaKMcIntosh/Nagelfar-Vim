" =============================================================================
" File:         nagelfar.vim (autoload plugin)
" Maintainer:   Lorance Stinson AT Gmail...
" Last Changed: 2011-09-17
" License:      Public Domain
" GitHub URL:   https://github.com/LStinson/Nagelfar-Vim
" =============================================================================
" Description:
" Extensions to the Nagelfar compiler plugin.
" Displays signs marking errors from Nagelfar.
" Creates keyboard mappings to make working with Nagelfar easier.
" =============================================================================

" Initialization.
" Allow user to avoid loading this plugin and prevent loading twice.
if exists('loaded_nagelfar_ext') && loaded_nagelfar_ext==1
    finish
endif
let loaded_nagelfar_ext=1

" Create the signs we will be using.
sign define nagelfarinfo    text=I>
sign define nagelfarwarning text=W>     texthl=Search
sign define nagelfarerror   text=E>     texthl=Error

" Clear signs set for the current buffer.
function! nagelfar#MapKeys()
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . '[ :cprevious<cr>'
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . '] :cnext<cr>'
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . 'c :NagelfarClear<cr>'
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . 'M :make!<cr>'
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . 'm :make<cr>'
    exec 'nnoremap <silent> <buffer> '. g:nagelfar_map_prefix . 'w :cwindow<cr>'
endfunction

" Clear signs set for the current buffer.
function! nagelfar#ClearSigns()
    if !exists('b:nagelfar_sign_list')
        let b:nagelfar_sign_list=[]
        return
    endif
    for item in b:nagelfar_sign_list
        exec 'sign unplace ' . item
    endfor
    let b:nagelfar_sign_list=[]
endfunction

" Command to create signs from the quickfix list.
" Called after the :make command is run.
function! nagelfar#CreateSigns()
    if exists('b:nagelfar_sign_list')
        call nagelfar#ClearSigns()
    else
        let b:nagelfar_sign_list=[]
    endif

    let l:bufnr=bufnr('$')
    for item in getqflist()
        if item.bufnr != l:bufnr
            continue
        endif
        let l:sign_num = (l:bufnr * 10000000) + item.lnum
        if item.type == 'E'
            exec ':sign place ' . l:sign_num . ' line=' . item.lnum . 
                \' name=nagelfarerror file=' . expand('%:p')
        elseif item.type == 'W'
            exec ':sign place ' . l:sign_num . ' line=' . item.lnum . 
                \' name=nagelfarwarning file=' . expand('%:p')
        else
            exec ':sign place ' . l:sign_num . ' line=' . item.lnum . 
                \' name=nagelfarinfo file=' . expand('%:p')
        endif
        call add(b:nagelfar_sign_list, l:sign_num)
    endfor
endfunction
