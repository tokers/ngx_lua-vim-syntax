" Vim syntax file
" Language:	Lua 4.0, Lua 5.0, Lua 5.1 and Lua 5.2
" Maintainer:	Marcus Aurelius Farias <masserahguard-lua 'at' yahoo com>
" First Author:	Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:	2012 Aug 12
" Options:	lua_version = 4 or 5
"		lua_subversion = 0 (4.0, 5.0) or 1 (5.1) or 2 (5.2)
"		default 5.2

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("lua_version")
  " Default is lua 5.2
  let lua_version = 5
  let lua_subversion = 2
elseif !exists("lua_subversion")
  " lua_version exists, but lua_subversion doesn't. So, set it to 0
  let lua_subversion = 0
endif

syn case match

" syncing method
syn sync minlines=100

" Comments
syn keyword luaTodo            contained TODO FIXME XXX
syn match   luaComment         "--.*$" contains=luaTodo,@Spell
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaComment start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]"
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  " Comments in Lua 5.1: --[[ ... ]], [=[ ... ]=], [===[ ... ]===], etc.
  syn region luaComment        matchgroup=luaComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
endif

" First line may start with #!
syn match luaComment "\%^#!.*"

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks
syn region luaParen      transparent                     start='(' end=')' contains=ALLBUT,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=ALLBUT,luaBraceError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement

syn match  luaParenError ")"
syn match  luaBraceError "}"
syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" function ... end
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" if ... then
syn region luaIfThen transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4           contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaIn nextgroup=luaThenEnd skipwhite skipempty

" then ... end
syn region luaThenEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaThenEnd,luaIn

" elseif ... then
syn region luaElseifThen contained transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" else
syn keyword luaElse contained else

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>"          contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" repeat ... until
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>"   contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" while ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaIn nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2   contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd nextgroup=luaBlock skipwhite skipempty

syn keyword luaIn contained in

" other keywords
syn keyword luaStatement return local break
if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaStatement goto
  syn match luaLabel "::\I\i*::"
endif
syn keyword luaOperator and or not
syn keyword luaConstant nil
if lua_version > 4
  syn keyword luaConstant true false
endif

" Strings
if lua_version < 5
  syn match  luaSpecial contained "\\[\\abfnrtv\'\"]\|\\[[:digit:]]\{,3}"
elseif lua_version == 5
  if lua_subversion == 0
    syn match  luaSpecial contained #\\[\\abfnrtv'"[\]]\|\\[[:digit:]]\{,3}#
    syn region luaString2 matchgroup=luaString start=+\[\[+ end=+\]\]+ contains=luaString2,@Spell
  else
    if lua_subversion == 1
      syn match  luaSpecial contained #\\[\\abfnrtv'"]\|\\[[:digit:]]\{,3}#
    else " Lua 5.2
      syn match  luaSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
    endif
    syn region luaString2 matchgroup=luaString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
  endif
endif
syn region luaString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

" integer number
syn match luaNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match luaNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=\>"
" floating point number, starting with a dot, optional exponent
syn match luaNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match luaNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
if lua_version >= 5
  if lua_subversion == 1
    syn match luaNumber "\<0[xX]\x\+\>"
  elseif lua_subversion >= 2
    syn match luaNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
  endif
endif

syn keyword luaFunc assert collectgarbage dofile error next
syn keyword luaFunc print rawget rawset tonumber tostring type _VERSION

if lua_version == 4
  syn keyword luaFunc _ALERT _ERRORMESSAGE gcinfo
  syn keyword luaFunc call copytagmethods dostring
  syn keyword luaFunc foreach foreachi getglobal getn
  syn keyword luaFunc gettagmethod globals newtag
  syn keyword luaFunc setglobal settag settagmethod sort
  syn keyword luaFunc tag tinsert tremove
  syn keyword luaFunc _INPUT _OUTPUT _STDIN _STDOUT _STDERR
  syn keyword luaFunc openfile closefile flush seek
  syn keyword luaFunc setlocale execute remove rename tmpname
  syn keyword luaFunc getenv date clock exit
  syn keyword luaFunc readfrom writeto appendto read write
  syn keyword luaFunc PI abs sin cos tan asin
  syn keyword luaFunc acos atan atan2 ceil floor
  syn keyword luaFunc mod frexp ldexp sqrt min max log
  syn keyword luaFunc log10 exp deg rad random
  syn keyword luaFunc randomseed strlen strsub strlower strupper
  syn keyword luaFunc strchar strrep ascii strbyte
  syn keyword luaFunc format strfind gsub
  syn keyword luaFunc getinfo getlocal setlocal setcallhook setlinehook
elseif lua_version == 5
  syn keyword luaFunc getmetatable setmetatable
  syn keyword luaFunc ipairs pairs
  syn keyword luaFunc pcall xpcall
  syn keyword luaFunc _G loadfile rawequal require
  if lua_subversion == 0
    syn keyword luaFunc getfenv setfenv
    syn keyword luaFunc loadstring unpack
    syn keyword luaFunc gcinfo loadlib LUA_PATH _LOADED _REQUIREDNAME
  else
    syn keyword luaFunc load select
    syn match   luaFunc /\<package\.cpath\>/
    syn match   luaFunc /\<package\.loaded\>/
    syn match   luaFunc /\<package\.loadlib\>/
    syn match   luaFunc /\<package\.path\>/
    if lua_subversion == 1
      syn keyword luaFunc getfenv setfenv
      syn keyword luaFunc loadstring module unpack
      syn match   luaFunc /\<package\.loaders\>/
      syn match   luaFunc /\<package\.preload\>/
      syn match   luaFunc /\<package\.seeall\>/
    elseif lua_subversion == 2
      syn keyword luaFunc _ENV rawlen
      syn match   luaFunc /\<package\.config\>/
      syn match   luaFunc /\<package\.preload\>/
      syn match   luaFunc /\<package\.searchers\>/
      syn match   luaFunc /\<package\.searchpath\>/
      syn match   luaFunc /\<bit32\.arshift\>/
      syn match   luaFunc /\<bit32\.band\>/
      syn match   luaFunc /\<bit32\.bnot\>/
      syn match   luaFunc /\<bit32\.bor\>/
      syn match   luaFunc /\<bit32\.btest\>/
      syn match   luaFunc /\<bit32\.bxor\>/
      syn match   luaFunc /\<bit32\.extract\>/
      syn match   luaFunc /\<bit32\.lrotate\>/
      syn match   luaFunc /\<bit32\.lshift\>/
      syn match   luaFunc /\<bit32\.replace\>/
      syn match   luaFunc /\<bit32\.rrotate\>/
      syn match   luaFunc /\<bit32\.rshift\>/
    endif
    syn match luaFunc /\<coroutine\.running\>/
  endif
  syn match   luaFunc /\<coroutine\.create\>/
  syn match   luaFunc /\<coroutine\.resume\>/
  syn match   luaFunc /\<coroutine\.status\>/
  syn match   luaFunc /\<coroutine\.wrap\>/
  syn match   luaFunc /\<coroutine\.yield\>/
  syn match   luaFunc /\<string\.byte\>/
  syn match   luaFunc /\<string\.char\>/
  syn match   luaFunc /\<string\.dump\>/
  syn match   luaFunc /\<string\.find\>/
  syn match   luaFunc /\<string\.format\>/
  syn match   luaFunc /\<string\.gsub\>/
  syn match   luaFunc /\<string\.len\>/
  syn match   luaFunc /\<string\.lower\>/
  syn match   luaFunc /\<string\.rep\>/
  syn match   luaFunc /\<string\.sub\>/
  syn match   luaFunc /\<string\.upper\>/
  if lua_subversion == 0
    syn match luaFunc /\<string\.gfind\>/
  else
    syn match luaFunc /\<string\.gmatch\>/
    syn match luaFunc /\<string\.match\>/
    syn match luaFunc /\<string\.reverse\>/
  endif
  if lua_subversion == 0
    syn match luaFunc /\<table\.getn\>/
    syn match luaFunc /\<table\.setn\>/
    syn match luaFunc /\<table\.foreach\>/
    syn match luaFunc /\<table\.foreachi\>/
  elseif lua_subversion == 1
    syn match luaFunc /\<table\.maxn\>/
  elseif lua_subversion == 2
    syn match luaFunc /\<table\.pack\>/
    syn match luaFunc /\<table\.unpack\>/
  endif
  syn match   luaFunc /\<table\.concat\>/
  syn match   luaFunc /\<table\.sort\>/
  syn match   luaFunc /\<table\.insert\>/
  syn match   luaFunc /\<table\.remove\>/
  syn match   luaFunc /\<math\.abs\>/
  syn match   luaFunc /\<math\.acos\>/
  syn match   luaFunc /\<math\.asin\>/
  syn match   luaFunc /\<math\.atan\>/
  syn match   luaFunc /\<math\.atan2\>/
  syn match   luaFunc /\<math\.ceil\>/
  syn match   luaFunc /\<math\.sin\>/
  syn match   luaFunc /\<math\.cos\>/
  syn match   luaFunc /\<math\.tan\>/
  syn match   luaFunc /\<math\.deg\>/
  syn match   luaFunc /\<math\.exp\>/
  syn match   luaFunc /\<math\.floor\>/
  syn match   luaFunc /\<math\.log\>/
  syn match   luaFunc /\<math\.max\>/
  syn match   luaFunc /\<math\.min\>/
  if lua_subversion == 0
    syn match luaFunc /\<math\.mod\>/
    syn match luaFunc /\<math\.log10\>/
  else
    if lua_subversion == 1
      syn match luaFunc /\<math\.log10\>/
    endif
    syn match luaFunc /\<math\.huge\>/
    syn match luaFunc /\<math\.fmod\>/
    syn match luaFunc /\<math\.modf\>/
    syn match luaFunc /\<math\.cosh\>/
    syn match luaFunc /\<math\.sinh\>/
    syn match luaFunc /\<math\.tanh\>/
  endif
  syn match   luaFunc /\<math\.pow\>/
  syn match   luaFunc /\<math\.rad\>/
  syn match   luaFunc /\<math\.sqrt\>/
  syn match   luaFunc /\<math\.frexp\>/
  syn match   luaFunc /\<math\.ldexp\>/
  syn match   luaFunc /\<math\.random\>/
  syn match   luaFunc /\<math\.randomseed\>/
  syn match   luaFunc /\<math\.pi\>/
  syn match   luaFunc /\<io\.close\>/
  syn match   luaFunc /\<io\.flush\>/
  syn match   luaFunc /\<io\.input\>/
  syn match   luaFunc /\<io\.lines\>/
  syn match   luaFunc /\<io\.open\>/
  syn match   luaFunc /\<io\.output\>/
  syn match   luaFunc /\<io\.popen\>/
  syn match   luaFunc /\<io\.read\>/
  syn match   luaFunc /\<io\.stderr\>/
  syn match   luaFunc /\<io\.stdin\>/
  syn match   luaFunc /\<io\.stdout\>/
  syn match   luaFunc /\<io\.tmpfile\>/
  syn match   luaFunc /\<io\.type\>/
  syn match   luaFunc /\<io\.write\>/
  syn match   luaFunc /\<os\.clock\>/
  syn match   luaFunc /\<os\.date\>/
  syn match   luaFunc /\<os\.difftime\>/
  syn match   luaFunc /\<os\.execute\>/
  syn match   luaFunc /\<os\.exit\>/
  syn match   luaFunc /\<os\.getenv\>/
  syn match   luaFunc /\<os\.remove\>/
  syn match   luaFunc /\<os\.rename\>/
  syn match   luaFunc /\<os\.setlocale\>/
  syn match   luaFunc /\<os\.time\>/
  syn match   luaFunc /\<os\.tmpname\>/
  syn match   luaFunc /\<debug\.debug\>/
  syn match   luaFunc /\<debug\.gethook\>/
  syn match   luaFunc /\<debug\.getinfo\>/
  syn match   luaFunc /\<debug\.getlocal\>/
  syn match   luaFunc /\<debug\.getupvalue\>/
  syn match   luaFunc /\<debug\.setlocal\>/
  syn match   luaFunc /\<debug\.setupvalue\>/
  syn match   luaFunc /\<debug\.sethook\>/
  syn match   luaFunc /\<debug\.traceback\>/
  if lua_subversion == 1
    syn match luaFunc /\<debug\.getfenv\>/
    syn match luaFunc /\<debug\.setfenv\>/
    syn match luaFunc /\<debug\.getmetatable\>/
    syn match luaFunc /\<debug\.setmetatable\>/
    syn match luaFunc /\<debug\.getregistry\>/
  elseif lua_subversion == 2
    syn match luaFunc /\<debug\.getmetatable\>/
    syn match luaFunc /\<debug\.setmetatable\>/
    syn match luaFunc /\<debug\.getregistry\>/
    syn match luaFunc /\<debug\.getuservalue\>/
    syn match luaFunc /\<debug\.setuservalue\>/
    syn match luaFunc /\<debug\.upvalueid\>/
    syn match luaFunc /\<debug\.upvaluejoin\>/
  endif
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_lua_syntax_inits")
  if version < 508
    let did_lua_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink luaStatement		Statement
  HiLink luaRepeat		Repeat
  HiLink luaFor			Repeat
  HiLink luaString		String
  HiLink luaString2		String
  HiLink luaNumber		Number
  HiLink luaOperator		Operator
  HiLink luaIn			Operator
  HiLink luaConstant		Constant
  HiLink luaCond		Conditional
  HiLink luaElse		Conditional
  HiLink luaFunction		Function
  HiLink luaComment		Comment
  HiLink luaTodo		Todo
  HiLink luaTable		Structure
  HiLink luaError		Error
  HiLink luaParenError		Error
  HiLink luaBraceError		Error
  HiLink luaSpecial		SpecialChar
  HiLink luaFunc		Identifier
  HiLink luaLabel		Label

  delcommand HiLink
endif

syntax match ngx_lua_func /ngx\.location\.capture/
syntax match ngx_lua_func /ngx\.location\.capture_multi/
syntax match ngx_lua_func /ngx\.resp\.get_headers/
syntax match ngx_lua_func /ngx\.req\.is_internal/
syntax match ngx_lua_func /ngx\.req\.start_time/
syntax match ngx_lua_func /ngx\.req\.http_version/
syntax match ngx_lua_func /ngx\.req\.raw_header/
syntax match ngx_lua_func /ngx\.req\.get_method/
syntax match ngx_lua_func /ngx\.req\.set_method/
syntax match ngx_lua_func /ngx\.req\.set_uri/
syntax match ngx_lua_func /ngx\.req\.set_uri_args/
syntax match ngx_lua_func /ngx\.req\.get_uri_args/
syntax match ngx_lua_func /ngx\.req\.get_post_args/
syntax match ngx_lua_func /ngx\.req\.get_headers/
syntax match ngx_lua_func /ngx\.req\.set_header/
syntax match ngx_lua_func /ngx\.req\.clear_header/
syntax match ngx_lua_func /ngx\.req\.read_body/
syntax match ngx_lua_func /ngx\.req\.discard_body/
syntax match ngx_lua_func /ngx\.req\.get_body_data/
syntax match ngx_lua_func /ngx\.req\.get_body_file/
syntax match ngx_lua_func /ngx\.req\.set_body_data/
syntax match ngx_lua_func /ngx\.req\.set_body_file/
syntax match ngx_lua_func /ngx\.req\.init_body/
syntax match ngx_lua_func /ngx\.req\.append_body/
syntax match ngx_lua_func /ngx\.req\.finish_body/
syntax match ngx_lua_func /ngx\.req\.socket/
syntax match ngx_lua_func /ngx\.exec/
syntax match ngx_lua_func /ngx\.redirect/
syntax match ngx_lua_func /ngx\.send_headers/
syntax match ngx_lua_func /ngx\.print/
syntax match ngx_lua_func /ngx\.say/
syntax match ngx_lua_func /ngx\.log/
syntax match ngx_lua_func /ngx\.flush/
syntax match ngx_lua_func /ngx\.exit/
syntax match ngx_lua_func /ngx\.eof/
syntax match ngx_lua_func /ngx\.sleep/
syntax match ngx_lua_func /ngx\.escape_uri/
syntax match ngx_lua_func /ngx\.unescape_uri/
syntax match ngx_lua_func /ngx\.encode_args/
syntax match ngx_lua_func /ngx\.decode_args/
syntax match ngx_lua_func /ngx\.encode_base64/
syntax match ngx_lua_func /ngx\.decode_base64/
syntax match ngx_lua_func /ngx\.crc32_short/
syntax match ngx_lua_func /ngx\.crc32_long/
syntax match ngx_lua_func /ngx\.hmac_sha1/
syntax match ngx_lua_func /ngx\.md5/
syntax match ngx_lua_func /ngx\.md5_bin/
syntax match ngx_lua_func /ngx\.sha1_bin/
syntax match ngx_lua_func /ngx\.quote_sql_str/
syntax match ngx_lua_func /ngx\.today/
syntax match ngx_lua_func /ngx\.time/
syntax match ngx_lua_func /ngx\.now/
syntax match ngx_lua_func /ngx\.update_time/
syntax match ngx_lua_func /ngx\.localtime/
syntax match ngx_lua_func /ngx\.utctime/
syntax match ngx_lua_func /ngx\.cookie_time/
syntax match ngx_lua_func /ngx\.http_time/
syntax match ngx_lua_func /ngx\.parse_http_time/
syntax match ngx_lua_func /ngx\.re\.match/
syntax match ngx_lua_func /ngx\.re\.find/
syntax match ngx_lua_func /ngx\.re\.gmatch/
syntax match ngx_lua_func /ngx\.re\.sub/
syntax match ngx_lua_func /ngx\.re\.gsub/
syntax match ngx_lua_func /ngx\.socket\.udp/
syntax match ngx_lua_func /ngx\.socket\.stream/
syntax match ngx_lua_func /ngx\.socket\.tcp/
syntax match ngx_lua_func /ngx\.socket\.connect/
syntax match ngx_lua_func /ngx\.get_phase/
syntax match ngx_lua_func /ngx\.thread\.spawn/
syntax match ngx_lua_func /ngx\.thread\.wait/
syntax match ngx_lua_func /ngx\.thread\.kill/
syntax match ngx_lua_func /ngx\.on_abort/
syntax match ngx_lua_func /ngx\.timer\.at/
syntax match ngx_lua_func /ngx\.timer\.running_count/
syntax match ngx_lua_func /ngx\.timer\.pending_count/
syntax match ngx_lua_func /ngx\.config\.nginx_configure/
syntax match ngx_lua_func /ngx\.worker\.exiting/
syntax match ngx_lua_func /ngx\.worker\.pid/
syntax match ngx_lua_func /ngx\.worker\.id/
syntax match ngx_lua_func /ngx\.worker\.count/


syntax match ngx_lua_var /ngx\.arg/
syntax match ngx_lua_var /ngx\.var\.[0-9a-zA-Z_]\+/
syntax match ngx_lua_var /ngx\.status/
syntax match ngx_lua_var /ngx\.header/
syntax match ngx_lua_var /ngx\.headers_sent/
syntax match ngx_lua_var /ngx\.is_subrequest/
syntax match ngx_lua_var /ngx\.shared\.DICT/
syntax match ngx_lua_var /ngx\.config\.subsystem/
syntax match ngx_lua_var /ngx\.config\.debug/
syntax match ngx_lua_var /ngx\.config\.prefix/
syntax match ngx_lua_var /ngx\.config\.nginx_version/
syntax match ngx_lua_var /ngx\.config\.ngx_lua_version/


syntax match ngx_lua_const /ngx\.OK/
syntax match ngx_lua_const /ngx\.ERROR/
syntax match ngx_lua_const /ngx\.AGAIN/
syntax match ngx_lua_const /ngx\.DONE/
syntax match ngx_lua_const /ngx\.DECLINED/
syntax match ngx_lua_const /ngx\.null/
syntax match ngx_lua_const /ngx\.HTTP_GET/
syntax match ngx_lua_const /ngx\.HTTP_HEAD/
syntax match ngx_lua_const /ngx\.HTTP_POST/
syntax match ngx_lua_const /ngx\.HTTP_PUT/
syntax match ngx_lua_const /ngx\.HTTP_DELETE/
syntax match ngx_lua_const /ngx\.HTTP_OPTIONS/
syntax match ngx_lua_const /ngx\.HTTP_MKCOL/
syntax match ngx_lua_const /ngx\.HTTP_COPY/
syntax match ngx_lua_const /ngx\.HTTP_MOVE/
syntax match ngx_lua_const /ngx\.HTTP_PROPFIND/
syntax match ngx_lua_const /ngx\.HTTP_PROPPATCH/
syntax match ngx_lua_const /ngx\.HTTP_LOCK/
syntax match ngx_lua_const /ngx\.HTTP_UNLOCK/
syntax match ngx_lua_const /ngx\.HTTP_PATCH/
syntax match ngx_lua_const /ngx\.HTTP_TRACE/
syntax match ngx_lua_const /ngx\.HTTP_CONTINUE/
syntax match ngx_lua_const /ngx\.HTTP_SWITCHING_PROTOCOLS/
syntax match ngx_lua_const /ngx\.HTTP_OK/
syntax match ngx_lua_const /ngx\.HTTP_CREATED/
syntax match ngx_lua_const /ngx\.HTTP_ACCEPTED/
syntax match ngx_lua_const /ngx\.HTTP_NO_CONTENT/
syntax match ngx_lua_const /ngx\.HTTP_PARTIAL_CONTENT/
syntax match ngx_lua_const /ngx\.HTTP_SPECIAL_RESPONSE/
syntax match ngx_lua_const /ngx\.HTTP_MOVED_PERMANENTLY/
syntax match ngx_lua_const /ngx\.HTTP_MOVED_TEMPORARILY/
syntax match ngx_lua_const /ngx\.HTTP_SEE_OTHER/
syntax match ngx_lua_const /ngx\.HTTP_NOT_MODIFIED/
syntax match ngx_lua_const /ngx\.HTTP_TEMPORARY_REDIRECT/
syntax match ngx_lua_const /ngx\.HTTP_BAD_REQUEST/
syntax match ngx_lua_const /ngx\.HTTP_UNAUTHORIZED/
syntax match ngx_lua_const /ngx\.HTTP_PAYMENT_REQUIRED/
syntax match ngx_lua_const /ngx\.HTTP_FORBIDDEN/
syntax match ngx_lua_const /ngx\.HTTP_NOT_FOUND/
syntax match ngx_lua_const /ngx\.HTTP_NOT_ALLOWED/
syntax match ngx_lua_const /ngx\.HTTP_NOT_ACCEPTABLE/
syntax match ngx_lua_const /ngx\.HTTP_REQUEST_TIMEOUT/
syntax match ngx_lua_const /ngx\.HTTP_CONFLICT/
syntax match ngx_lua_const /ngx\.HTTP_GONE/
syntax match ngx_lua_const /ngx\.HTTP_UPGRADE_REQUIRED/
syntax match ngx_lua_const /ngx\.HTTP_TOO_MANY_REQUESTS/
syntax match ngx_lua_const /ngx\.HTTP_CLOSE/
syntax match ngx_lua_const /ngx\.HTTP_ILLEGAL/
syntax match ngx_lua_const /ngx\.HTTP_INTERNAL_SERVER_ERROR/
syntax match ngx_lua_const /ngx\.HTTP_METHOD_NOT_IMPLEMENTED/
syntax match ngx_lua_const /ngx\.HTTP_BAD_GATEWAY/
syntax match ngx_lua_const /ngx\.HTTP_SERVICE_UNAVAILABLE/
syntax match ngx_lua_const /ngx\.HTTP_GATEWAY_TIMEOUT/
syntax match ngx_lua_const /ngx\.HTTP_VERSION_NOT_SUPPORTED/
syntax match ngx_lua_const /ngx\.HTTP_INSUFFICIENT_STORAGE/
syntax match ngx_lua_const  /ngx\.STDERR/
syntax match ngx_lua_const  /ngx\.EMERG/
syntax match ngx_lua_const  /ngx\.ALERT/
syntax match ngx_lua_const  /ngx\.CRIT/
syntax match ngx_lua_const  /ngx\.ERR/
syntax match ngx_lua_const  /ngx\.WARN/
syntax match ngx_lua_const  /ngx\.NOTICE/
syntax match ngx_lua_const  /ngx\.INFO/
syntax match ngx_lua_const  /ngx\.DEBUG/

highlight link ngx_lua_func Function
highlight link ngx_lua_var Include
highlight link ngx_lua_const Constant


let b:current_syntax = "lua"

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: et ts=8 sw=2
