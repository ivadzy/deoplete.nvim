"=============================================================================
" FILE: custom.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! deoplete#custom#_init() abort
  let s:custom = {}
  let s:custom.source = {}
  let s:custom.source._ = {}
  let s:custom.option = deoplete#init#_option()
endfunction
function! deoplete#custom#_init_buffer() abort
  let b:custom = {}
  let b:custom.option = {}
  let b:custom.source_vars = {}
endfunction

function! deoplete#custom#_get() abort
  if !exists('s:custom')
    call deoplete#custom#_init()
  endif

  return s:custom
endfunction
function! deoplete#custom#_get_buffer() abort
  if !exists('b:custom')
    call deoplete#custom#_init_buffer()
  endif

  return b:custom
endfunction

function! deoplete#custom#_get_source(source_name) abort
  let custom = deoplete#custom#_get().source

  if !has_key(custom, a:source_name)
    let custom[a:source_name] = {}
  endif

  return custom[a:source_name]
endfunction
function! deoplete#custom#_get_option(name) abort
  if has_key(deoplete#custom#_get_buffer().option, a:name)
    return deoplete#custom#_get_buffer().option[a:name]
  endif
  return deoplete#custom#_get().option[a:name]
endfunction
function! deoplete#custom#_get_filetype_option(name, filetype, default) abort
  let buffer_option = deoplete#custom#_get_buffer().option
  if has_key(buffer_option, a:name)
    " Use buffer_option instead
    return buffer_option[a:name]
  endif

  let option = deoplete#custom#_get_option(a:name)
  let filetype = has_key(option, a:filetype) ? a:filetype : '_'
  return get(option, filetype, a:default)
endfunction
function! deoplete#custom#_get_source_vars(name) abort
  let global_vars = get(deoplete#custom#_get_source(a:name), 'vars', {})
  let buffer_vars = get(deoplete#custom#_get_buffer().source_vars,
        \ a:name, {})
  return extend(copy(global_vars), buffer_vars)
endfunction

function! deoplete#custom#source(source_name, option_name, value) abort
  let value = index([
        \ 'filetypes', 'disabled_syntaxes',
        \ 'matchers', 'sorters', 'converters'
        \ ], a:option_name) < 0 ? a:value :
        \ deoplete#util#convert2list(a:value)
  for key in deoplete#util#split(a:source_name)
    let custom_source = deoplete#custom#_get_source(key)
    let custom_source[a:option_name] = value
  endfor
endfunction

function! deoplete#custom#var(source_name, var_name, value) abort
  for key in deoplete#util#split(a:source_name)
    let custom_source = deoplete#custom#_get_source(key)
    let vars = get(custom_source, 'vars', {})
    call s:set_value(vars, a:var_name, a:value)
    call deoplete#custom#source(key, 'vars', vars)
  endfor
endfunction
function! deoplete#custom#buffer_var(source_name, var_name, value) abort
  let custom = deoplete#custom#_get_buffer().source_vars
  for key in deoplete#util#split(a:source_name)
    if !has_key(custom, key)
      let custom[key] = {}
    endif
    let vars = custom[key]
    call s:set_value(vars, a:var_name, a:value)
  endfor
endfunction

function! deoplete#custom#option(name_or_dict, ...) abort
  let custom = deoplete#custom#_get().option
  call s:set_custom(custom, a:name_or_dict, get(a:000, 0, ''))
endfunction
function! deoplete#custom#buffer_option(name_or_dict, ...) abort
  let custom = deoplete#custom#_get_buffer().option
  call s:set_custom(custom, a:name_or_dict, get(a:000, 0, ''))
endfunction

function! s:set_custom(dest, name_or_dict, value) abort
  if type(a:name_or_dict) == v:t_dict
    call extend(a:dest, a:name_or_dict)
  else
    call s:set_value(a:dest, a:name_or_dict, a:value)
  endif
endfunction
function! s:set_value(dest, name, value) abort
  if type(a:value) == v:t_dict && !empty(a:value)
    if !has_key(a:dest, a:name)
      let a:dest[a:name] = {}
    endif
    call extend(a:dest[a:name], a:value)
  else
    let a:dest[a:name] = a:value
  endif
endfunction
