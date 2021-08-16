" Innovative reST section folding
" Author: Landon Bouma <https://tallybark.com/>
" Online: https://github.com/landonb/vim-reSTfold#🙏
" License: https://creativecommons.org/publicdomain/zero/1.0/
"  vim:tw=0:ts=2:sw=2:et:norl:ft=vim
" Copyright © 2018-21 Landon Bouma.

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

" USAGE: Open a reST file, and press <F5> to fold sections.
"
" - Sections should be formatted with two horizontal rulers.
"
"   Use '@', '#', '=', or '-' to make the rulers.
"
"   E.g.,
"
"     @@@@@@@@@@@@
"     Level 1 FOLD
"     @@@@@@@@@@@@
"
"     ############
"     Level 2 FOLD
"     ############
"
"     ============
"     Level 3 FOLD
"     ============
"
"     ------------
"     Level 4 FOLD
"     ------------
"
" - There are a number of configurable options.
"
"   See the function:
"
"     s:SetDefaultConfig()
"
"   to see all the options you can set.

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

" YOU: Uncomment next 'unlet', then <F9> to reload this file.
"      (Iff: https://github.com/landonb/vim-source-reloader)
"
" ALSO: Disable the guard clause `return` below, in
"         s:ApplyDefault()
"       if you also want to update the g:vars on <F9>.
"       Look for:
"         " DEV: Comment this if using vim-source-reloader to reset globals.
"         "return
"
" silent! unlet g:loaded_restfold_after_ftplugin_rst

if exists("g:loaded_restfold_after_ftplugin_rst") || &cp
  finish
endif

let g:loaded_restfold_after_ftplugin_rst = 1

" ################################################################# "

let s:DEBUG_TRACE = 0
" Set DEBUG_TRACE to 1 for :message blather.
"  let s:DEBUG_TRACE = 1

" ################################################################# "

" Disable folding until user presses <F5> to engage.

" Otherwise, the user is likely to be annoyed at how long it takes to
" open a new buffer.
"
" And the user won't always care about folding (or they won't care about
" folding until they care about folding; so lazy-enable folding when the
" user decides to care).

" HINT: Press <F5> to engage the restfolder.
"       And then press <S-F5> to refresh.
"       (See bindings at the bottom.)

" Note that, once engaged, the plugin will not automatically update
" fold levels as the user edits. The values calculated on <F5> remain
" cached until the next full <F5> reload; or until a soft <S-F5> refresh.
"
" If the plugin did recalculate folds automatically, you'd likely see a
" degradation in performance (especially on reST files w/ 1000s of lines).
"
" - For instance, deleting a block of text might block Vim for a few seconds
"   while this plugin rescans all lines in the buffer and rebuilds the cache.
"
"   (And although Vim might appear unresponsive during scanning, the user
"    is still able to Ctrl-C to interrupt parsing. But they cannot edit.)
"
" - Note, too, that syntax highlighting can also affect performance when
"   opening a buffer, entering a buffer, and editing, which makes gleaning
"   useful data from profiling a little trickier (i.e., trying to determine
"   what impact calculating folding has versus highlighting).
"   - See :help syntime for some hints on profiling syntax and folding.

" For reference, here's what Vim does by default in its ftplugin/rst.vim
" (which is from https://github.com/marshallward/vim-restructuredtext):
"
"   setlocal foldmethod=expr
"   setlocal foldexpr=RstFold#GetRstFold()
"   setlocal foldtext=RstFold#GetRstFoldText()
"
" Here we essentially disable folding until the user enables it (<F5>).

setlocal foldmethod=manual
setlocal foldexpr="0"

" ################################################################# "

" Be lazy about setting defaults, so user won't have to use an
" after/ script to override these.
let s:SetDefaultConfigOnFirstRun = 1

function! s:SetDefaultConfig()
  if !s:SetDefaultConfigOnFirstRun
    return
  endif

  " YOU: Set this global variable zero to set up your own bindings.
  "
  "   If the global is unset or truthy, this plugin will bind <F5> in
  "   each reST buffer to folding it according to restfold rules. It'll
  "   also map <C-Up> and <C-Down> to moving (transposing) reST sections
  "   within each reST buffer.
  "
  " E.g., if your private ~/.vimrc or private Vim plugin, such as
  " ~/.vim/pack/yourname/start/yourplug/plugin/my.vim, you'd set:
  "
  "   let g:restfold_create_default_mappings = 0
  "
  " You could then copy the nmap, etc., from the bottom of this file to
  " your own ~/.vimrc or plugin and edit to your taste.
  call s:ApplyDefault('g:restfold_create_default_mappings', 1)

  " ***

  " Set this variable truthy to disable piping ornamentation.
  "
  " - Note that piping is separate from the lines count, so if you want
  "   to disable all fold style (so this plugin only calculates folds
  "   and shows fold titles), enable this option as well as the lines
  "   count hide, e.g.,
  "
  "     let g:restfold_disable_piping = 1
  "     let g:restfold_lines_count_hide = 1
  "
  call s:ApplyDefault('g:restfold_disable_piping', 0)

  " ***

  " Note: The &fillchars setting is completely ignored.
  "
  " - By default, Vim sets fillchars="vert:|,fold:-". This plugin
  "   could (and used to! before piping) extract the 'fold' character,
  "   e.g., the dash. But this plugin makes folds looks best with a
  "   thin horizontal line, e.g., '-------' vs '───────' (try folding
  "   a document, and you'll see). So rather than require everyone to
  "   set &fillchars specially for this plugin, this plugin instead
  "   ignores that variable and uses its own.
  "
  " Use the fold-piping variable to set the default piping character to
  " use. This is essentially similar to how Vim uses the dash character
  " '-' from &fillchars, except this plugin is lots more magical with it.
  "
  " - The default fold (fill) character is a thin horizontal line, '─'.
  "
  " Disabling: Set this to the empty string to use whitespace instead
  " of the pipe character (or you could set this to a space character,
  " but that adds an additional prefix space before the title).
  "
  " - E.g., if you want to see folds without horizontal pipe characters,
  "   but still showing the vertical bars and has-subfolds markers ▽ (i.e.,
  "   not completely disabling piping via g:restfold_disable_piping), try:
  "
  "     let g:restfold_fold_piping = ''
  "
  call s:ApplyDefault('g:restfold_fold_piping', "'─'")

  " Whether or not to use ┌ ┐ └ ┘ to connect folds at the same level. Set
  " this nonzero to skip corners (and to always use the fold character,
  " g:restfold_fold_piping).
  call s:ApplyDefault('g:restfold_no_corners', 0)

  " The icon to use to indicate that a fold has sub-sections
  " (folds w/in the fold). Set to the empty string to disable
  " (which is the same as setting to g:restfold_fold_piping).
  " - Some other characters I demoed, similar to the one I chose:
  "     call s:ApplyDefault('g:restfold_subfolds_marker', "'┬'")
  "     call s:ApplyDefault('g:restfold_subfolds_marker', "'∇'")
  call s:ApplyDefault('g:restfold_subfolds_marker', "'▽'")

  " Whether to magically connect section headers that start with the pipe
  " character (g:restfold_fold_piping) without separating with whitespace.
  " Set this nonzero to always use a space between the piping and the title.
  call s:ApplyDefault('g:restfold_no_pipe_welding', 0)

  " *** Rules for identifying content folds vs. ornamental.

  " By default, reSTfold will not add horizontal piping into a title unless
  " it starts with an ASCII (one-byte) character, or if it starts with any
  " of the unicode characters specified in this string. (The idea is to let
  " you use Unicode to beautify your documents without also creating a
  " distraction by having dangling horizontal piping leading into these
  " ornamentative lines. Another way to think of this is that the lead
  " piping is meant to signify folds with content, and not border folds.)
  call s:ApplyDefault('g:restfold_weldable_unicode_allow_list',
    \ "'🔇🔈🔉🔊❕❔❓📢⭕✓✅➕❌'")

  " Or set g:restfold_weldable_unicode_enable_all truthy to always connect to Unicode.
  call s:ApplyDefault('g:restfold_weldable_unicode_enable_all', 0)

  " Set g:restfold_weldable_blank_lines truthy to always weld to blank titles.
  call s:ApplyDefault('g:restfold_weldable_blank_lines', 0)

  " Set g:restfold_weldable_max_lead_spaces to number of leading spaces to
  " allow and still consider that a title line is weldable. To put it the
  " other way, set this value one less than how many spaces you'd like to
  " use to indicate a fold is ornamentation. E.g., if you want to start
  " ornamenation folds with 2+ spaces, than a value of '1' here means that
  " the title, '  ⭐ ⭐ ⭐', would be identified as ornamentation, but then
  " the title, ' My Fold Title', would be identified as weldable. The
  " default value of 0 means that any title that starts with a space is
  " considered an ornamental line (max leading spaces to be weldable is 0),
  " and such a line will not be connected to pipe welding. Set to -1 to
  " disable completely (assume weldable unless another condition applies).
  call s:ApplyDefault('g:restfold_weldable_max_lead_spaces', 0)

  " Set g:restfold_weldable_min_content_lines to the minimum number of
  " content lines (lines in the fold not including the first 3 lines
  " that are used for the reSTfold header) that a fold must have to be
  " considered weldable. The default value, 2, means that a fold must
  " have two lines of content to be weldable. E.g., if the fold is just
  " its 3 header lines and 1 content line (in practice, the first line
  " after the header is blank, but it does not have to be), then assume
  " the fold is for ornamentation. (Another way to think about this is
  " that horizontal piping (welding) should only occur to fold titles
  " whose folds contain content -- the piping draws your eye to the
  " fold and tells you to open the fold to find more. (Also, the author
  " uses a lot of 4-line folds for beautifying my documents, and I like
  " the cleaner look of not having horizontal piping at the start of all
  " the design folds.))
  call s:ApplyDefault('g:restfold_weldable_min_content_lines', 2)

  " ***

  " If nonzero, pad the title with whitespace to this width, which has the
  " effect of lining up the tail piping (otherwise, if this is 0, the title
  " is followed by a single space and then the tail piping starts).
  " This feature is disabled by default because it's depends on one's taste
  " or at least one's display's width.
  call s:ApplyDefault('g:restfold_min_title_width', 0)
  " (lb): I like setting a minimum width, so that the tail piping
  " starts at the same column, but this value is display-dependent.
  " - E.g., on my 1920x1080 monitor with two side-by-side file buffer
  "   panes and the project tray open, a width of 93 is perfect: I see
  "   two leading fold_piping characters, and also two trailing pipings.
  "   - So in my private Vim plugin, e.g., at
  "       ~/.vim/pack/myname/start/my_private_vim/plugin/my.vim
  "    I've got the following specified:
  "       let g:restfold_min_title_width = 93
  " - In fact, this is the only setting the author customizes in their
  "   private Vim plugin (that's used for such things).

  " ***

  " Set this option truthy to disable the line count column.
  call s:ApplyDefault('g:restfold_lines_count_hide', 0)

  " This setting determines the minimum width of the lines count column,
  " so that it looks and aligns nicely.
  " - MAGIC_NUMBER: Use 4 characters for the lines count width.
  "   This ensures columns align for counts into the 1000s.
  "   - E.g.,
  "       ── FIRST FOLD TITLE ───┨  123 ll. ├──
  "       ── SECOND FOLD TITLE ──┨ 4567 ll. ├──
  "       ── THIRD FOLD TITLE ───┨    8 ll. ├──
  "                                ^^^^ 4 column-wide lines count value.
  "   - Note that, in this author's experience, users probably won't want
  "     to work on reST files larger than 10K lines, because syntax
  "     highlighting on BufEnter takes noticeable time. (You'll want to
  "     consider splitting your reST files when they grow larger than 8K
  "     lines, if you're like me and take copious notes in reST files.)
  "     So this value -- 4 -- should be sufficient, as you'd neither want
  "     a file longer, nor any fold therein longer, than 10k lines. So
  "     this width of four accommodates line counts up to '9999'.
  call s:ApplyDefault('g:restfold_lines_count_width', 4)

  " What to label the lines count unit.
  " - (lb): I used to use a longer units string:
  "     call s:ApplyDefault('g:restfold_lines_count_units', "' lines'")
  "   but I like the (possibly not very well known) 'll.' abbreviation,
  "   to afford the fold title that much more width-room.
  " - Note that the minimum fold length is 3 lines, so this label will
  "   never be used on a single value, e.g., '1 ll.' will never happen.
  call s:ApplyDefault('g:restfold_lines_count_units', "' ll.'")

  " ***

  " This value specifies how many trailing pipe characters to show after
  " the lines count column. This defaults to 2, to match the prefix format,
  " which is 0-3 spaces followed by two leading pipe characters. (And we
  " could/should make the prefix count configurable, for parity with this
  " setting... but, mehhhhhhhhhh. =)
  call s:ApplyDefault('g:restfold_tail_width', 2)

  " ***

  let s:SetDefaultConfigOnFirstRun = 0
endfunction

" ***

function! s:ApplyDefault(varname, value)
  if exists(a:varname)
    " DEV: Comment this if using vim-source-reloader to reset globals.
    return
  endif

  let l:let_cmd = "let " . a:varname . " = " . a:value

  execute l:let_cmd
endfunction

" ################################################################# "

" Double-ruled reST header folding engine.
function! ReSTfoldFoldLevel(lnum)
  call s:SetDefaultConfig()

  if !s:IsFoldLevelLookupPopulated()
    call s:HydrateFoldLevelLookup()
  endif

  let l:fold_level = s:LookupFoldLevelAtLine(a:lnum)

  if s:DEBUG_TRACE && a:lnum < 30
    echom "a:lnum: " . a:lnum . " / l:fold_level: " . l:fold_level
  endif

  return l:fold_level
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

function! s:IsFoldLevelLookupPopulated()
  return exists("b:RESTFOLD_SCANNER_LOOKUP") && len(b:RESTFOLD_SCANNER_LOOKUP) > 0
endfunction

function! s:HydrateFoldLevelLookup()
  let l:file_length = line('$')

  let b:RESTFOLD_SCANNER_LOOKUP = s:ArrayFill(l:file_length + 1, -1)

  for lnum in range(l:file_length)
    let l:lnum += 1
    let b:RESTFOLD_SCANNER_LOOKUP[l:lnum] = s:IdentifyFoldLevelAtLine(l:lnum)
  endfor
endfunction

" ***

" See also:
"   return repeat([a:value], a:length)
" - (lb): I have no idea whether map-range or repeat is more performant.
function! s:ArrayFill(length, value)
  return map(range(a:length), a:value)
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

function! s:LookupFoldLevelAtLine(lnum)
  if a:lnum < 1 || a:lnum >= len(b:RESTFOLD_SCANNER_LOOKUP)
    return -1
  endif

  return b:RESTFOLD_SCANNER_LOOKUP[a:lnum]
endfunction

function! s:LookupFoldLevelNumber(lnum)
  let l:fold_level = s:LookupFoldLevelAtLine(a:lnum)

  " Remove '>' starts-at-this-line delimiter.
  if type(l:fold_level) == type('') && stridx(l:fold_level, '>') != -1
    let l:fold_level = strcharpart(l:fold_level, 1)
  endif

  return str2nr(l:fold_level)
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

function! s:IdentifyFoldLevelAtLine(lnum)
  if a:lnum == 1
    let b:cur_level_fold = 0
    let b:cur_level_lnum = 0
  endif

  " MAGIC_NUMBER: Skip 2 lines following a new level (or beginning of file).
  if (b:cur_level_fold == 0) || (a:lnum > (b:cur_level_lnum + 2))
    let l:new_level = GetFoldLevelIfNewReSTSection(a:lnum)

    if l:new_level > 0
      let b:cur_level_lnum = a:lnum
      let b:cur_level_fold = l:new_level
      " Indicate that a new fold '>' starts at this line.
      " NOTE: There's also '<' *ends at this line* but does not seem useful.
      let l:start_level = '>' . str2nr(l:new_level)

      if s:DEBUG_TRACE && a:lnum < 60
        echom "Folding: a:lnum: " . a:lnum . " / l:start_level: " . l:start_level
      endif

      return l:start_level
    endif
  endif

  if s:DEBUG_TRACE && a:lnum < 30
    echom "Folding: a:lnum: " . a:lnum . " / b:cur_level_fold: " . b:cur_level_fold
  endif

  return b:cur_level_fold
endfunction

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

function! GetFoldLevelIfNewReSTSection(lnum)
  " 2018-09-16: (lb): Before I added ReSTSectionTitleFoldText to deliberately
  " set the folded section title, I instead started the fold on the title text,
  " rather than on the leading section delimiter. So here I had to look behind
  " for the leading delimiter, and look ahead for the trailing delimiter, e.g.,
  "     let l:lnum_uppr = a:lnum - 1
  "     let l:lnum_lowr = a:lnum + 1
  " but then folds would be off by one, e.g., consider a section title like this:
  "      #############
  "      Section Title    <==== Where the fold used to start.
  "      #############
  " But now that ReSTSectionTitleFoldText looks a line ahead for the folded title,
  " we can set the fold on the leading delimiter, in which case here we check the
  " current line, and the line two lines ahead:
  let l:lnum_uppr = a:lnum
  let l:lnum_lowr = a:lnum + 2

  " We could just look for 1 or more repeating symbols:
  "   if getline(l:lnum_uppr) =~ '^@\+$' && getline(l:lnum_lowr) =~ '^@\+$'
  " but default /usr/share/vim/vim80/syntax/rst.vim checks 2+. Search file for:
  "   syn match rstSections
  let l:new_level = 0

  if getline(l:lnum_uppr) =~ '^@\{2,\}$' && getline(l:lnum_lowr) =~ '^@\{2,\}$'
    let l:new_level = 1
  elseif getline(l:lnum_uppr) =~ '^#\{2,\}$' && getline(l:lnum_lowr) =~ '^#\{2,\}$'
    let l:new_level = 2
  elseif getline(l:lnum_uppr) =~ '^=\{2,\}$' && getline(l:lnum_lowr) =~ '^=\{2,\}$'
    let l:new_level = 3
  elseif getline(l:lnum_uppr) =~ '^-\{2,\}$' && getline(l:lnum_lowr) =~ '^-\{2,\}$'
    let l:new_level = 4
  endif

  return l:new_level
endfunction

" ################################################################# "

function! ReSTFolderUpdateFolds(reset_folding)
  if !&foldenable
    if a:reset_folding == 0 || a:reset_folding == 1
      echom "Run 'zi' to foldenable!"
    end

    return
  endif

  call s:SetDefaultConfig()

  let l:was_folding_already = s:IsFoldLevelLookupPopulated()

  let b:RESTFOLD_SCANNER_LOOKUP = []

  setlocal foldexpr=ReSTfoldFoldLevel(v:lnum)
  setlocal foldmethod=expr

  " Update folds (zx) after MoveUp/MoveDown.
  " - But do not Update folds on <S-F5>, only recalculate fold levels.
  " - And it's no longer necessary for <F5>, either, now with caching.
  " - For MoveUp/MoveDown, this re-closes the fold that was opened by
  "   the move.
  " - For <F5>, Update folds is not necessary anymore, now with caching.
  "   - Before caching was added, calculating fold levels on foldexpr was
  "     expensive, so this plugin would set foldexpr, execute `zx` to
  "     generate fold levels, and then set foldexpr="0" to disable it
  "     (and then Vim would use the values that it retrieved on `zx`
  "     but never update fold levels until the used pressed <F5> again).
  "   - But now with caching, we can leave foldexpr set, and there's no
  "     need for the `zx` prefetch.
  if a:reset_folding == 2
    normal! zx
  endif
  " Before caching was implemented, this plugin would disable the foldmethod
  " after calculating fold levels, because the old fold level function was a
  " drag on performance. But now that the fold levels are cached, there's no
  " drag. But rather, now we *need* to keep foldexpr set to support <S-F5>
  " recalculating folds without starting over (collapsing all folds).
  " - No longer necessary, and not desirable; but here for remembrance:
  "    setlocal foldmethod=manual
  "    setlocal foldexpr="0"

  setlocal foldtext=ReSTSectionTitleFoldText()

  " Close all folds (set foldlevel to 0).
  normal! zM
  " Reduce folding (set foldlevel to 1, opening top-level folds).
  normal! zr

  if !l:was_folding_already || a:reset_folding == 1
    " Move cursor to the top of the file (gg); then
    " move it down to the start of the next (first) fold (zj); then
    " move that line to the top of the screen (`zt`; or `z<CR>` to
    " send to first non-blank column, which won't matter for folds).
    " - [Or, if you just want the fold to scroll into view but not
    "    to obscure what's above the first fold, replace `zt` with
    "    `zz` to center the first fold instead.].
    " Ref: :help scroll-cursor
    normal! gg
    normal! zj
    normal! zt
    "  echom "Updated folds!"
  else
    " Move current line to center (to help user relocate themselves).
    normal! zz
    " Expand only the current fold.
    normal! zv
  endif
endfunction

" ################################################################# "

" Transpose folds (reposition/move folds "up" and "down")
"
" Related documentation:
"
"   http://vim.wikia.com/wiki/Transposing
"
"   http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines
"
"   http://vimcasts.org/episodes/swapping-two-regions-of-text-with-exchange-vim/
"
" Related projects:
"
"   https://github.com/tpope/vim-unimpaired
"
"   https://github.com/tommcdo/vim-exchange

" Move the entity under the cursor up a line.
function! ReSTFolderMoveUp()
  let l:lineno = line('.')
  if l:lineno == 1
    return
  endif

  let l:fc = foldclosed('.')
  if l:fc == -1
    " (lb): Note that we use bang! to tell Vim to skip our mappings
    " and use the original meaning of Ctrl-y; and we use execute to
    " be able to specify the key to execute as a literal.
    execute "normal! \<C-y>"
    return
  end

  let l:a_reg = @a
  " "a   Use register `a` for the next delete, yank or put.
  " dd   Delete [count=1] lines [into register `a`] *linewise*.
  " k    Move up
  " "a   Use register `a` for the next delete, yank or put.
  " P    Put the text [from register `a`] before the cursor.
  " Note that, *linewise*, dd will delete all lines in a fold. Sweet!
  if l:lineno == line('$')
    normal! "add"aP
  else
    normal! "addk"aP
  endif

  let @a = l:a_reg
  if l:fc != -1
    call ReSTFolderUpdateFolds(2)
    normal! zc
  endif
endfunction

" Move the entity under the cursor down a line.
function! ReSTFolderMoveFoldDown()
  let l:fc = foldclosed('.')
  if l:fc == -1
    execute "normal! \<C-e>"

    return
  end

  let l:a_reg = @a
  normal! "add"ap
  let @a = l:a_reg
  if (l:fc != -1) && (foldclosed('.') == -1)
    call ReSTFolderUpdateFolds(2)
    normal! zc
  endif
endfunction

" ################################################################# "

function! ReSTSectionTitleFoldText()
  " The reSTfold format specifies horizontal rules above and below the title (a
  " section title sandwich). So the fold starts on the first horizontal rule (at
  " v:foldstart), and the title is the first line after v:foldstart. Unless EOF.
  let l:lineno_title = v:foldstart
  if l:lineno_title != line('$')
    " Not the last line.
    let l:lineno_title += 1
  end

  let l:pipe_chars = s:DeterminePipeChars(l:lineno_title)
  let l:lead_piping = l:pipe_chars[0]
  let l:tail_piping = l:pipe_chars[1]
  let l:line_piping = l:pipe_chars[2]

  let l:second_pipe = s:DeterminePipeTwo(l:line_piping)
  let l:first_pipes = l:lead_piping . l:second_pipe

  let l:line_prefix_and_has_welds = s:PreparePrefixedLine(
    \ l:lineno_title, l:first_pipes, l:line_piping)
  let l:level_prefix_and_line = l:line_prefix_and_has_welds[0]
  let l:has_welded_pipes = l:line_prefix_and_has_welds[1]

  let l:tail_and_count = s:PrepareTailPipeAndLinesCount(
    \ l:lead_piping, l:tail_piping, l:line_piping)

  let l:fold_line_lhs = s:TruncatePrefixedLine(
    \ l:level_prefix_and_line, l:tail_and_count, l:line_piping)

  let l:fold_line_rhs = s:AppendPipingSoilStack(l:tail_and_count, l:line_piping)

  let l:entire_fold_line = s:AssembleFoldLine(
    \ l:fold_line_lhs, l:fold_line_rhs, l:has_welded_pipes, line_piping)

  return l:entire_fold_line
endfunction

" ***

" Determines lead and tail piping by examining visibly adjacent folds.
function! s:DeterminePipeChars(lineno_title)
  let l:lead_piping = ''
  let l:tail_piping = ''
  let l:line_piping = ''

  " Check if user has disabled piping.
  if g:restfold_disable_piping
    return [ l:lead_piping, l:tail_piping, l:line_piping ]
  endif

  " Default lead, tail, and line piping to simple, thin horizontal pipe, '─'.
  let l:lead_piping = g:restfold_fold_piping
  let l:tail_piping = g:restfold_fold_piping
  let l:line_piping = g:restfold_fold_piping

  " See similar check in s:DeterminePipeTwo: When user opts-out of piping,
  " without setting line_piping = ' ', the plugin would not fill in the
  " line suffix to the window width, and Vim would step in and fill the
  " void with primitive dashes (e.g., '---------'). So ensure that lines
  " are padded with whitespace in the absence of fold piping.
  if g:restfold_fold_piping == ''
    let l:line_piping = ' '
  endif

  " Check if line is whitespace-only, or ornamental, i.e., likely does not
  " contain any content, so don't draw attention to it with horizontal piping.
  if !g:restfold_no_pipe_welding
    \ && s:IsOrnamentationFold(a:lineno_title, l:line_piping)

    let l:lead_piping = ' '
    let l:tail_piping = ' '
    let l:line_piping = ' '
  endif

  if g:restfold_no_corners
    return [ l:lead_piping, l:tail_piping, l:line_piping ]
  endif

  " We'll use data about the previous and next fold to determine pipe connections.
  let l:visible_fold_start_prev = foldclosed(v:foldstart - 1)
  let l:visible_fold_level_prev = s:LookupFoldLevelNumber(l:visible_fold_start_prev)
  let l:visible_fold_start_next = foldclosed(foldclosedend(v:foldstart) + 1)
  let l:visible_fold_level_next = s:LookupFoldLevelNumber(l:visible_fold_start_next)

  if l:line_piping != '─'
    " Our pipe welding only knows the one fitting. This isn't it.
    " So we can only plumb a vertical stack.
    let l:lead_piping = '│'
    let l:tail_piping = '│'
  elseif v:foldlevel == l:visible_fold_level_next
    if v:foldlevel == l:visible_fold_level_prev
      " Between Two Folds, all three at the same level.
      let l:lead_piping = '├'
      let l:tail_piping = '┤'
    else
      " Previous fold is a different level, so this one starts the fold group.
      let l:lead_piping = '┌'
      let l:tail_piping = '┐'
    endif
  elseif v:foldlevel == l:visible_fold_level_prev
    " Where v:foldlevel != l:visible_fold_level_next. Last one in fold group.
    let l:lead_piping = '└'
    let l:tail_piping = '┘'
  endif
  " else, if none of the above, lead/tail remain '─', aka a one-fold group.

  if s:DEBUG_TRACE
    echom "=== v:foldlvl: " . v:foldlevel
          \ . " / v:fldstrt: " . v:foldstart
          \ . " / v:foldend: " . v:foldend
          \ . " / vis-ln-prev: " . l:visible_fold_start_prev
          \ . " / vis-ln-next: " . l:visible_fold_start_next
          \ . " / vis-lvl-prev: " . l:visible_fold_level_prev
          \ . " / vis-lvl-next: " . l:visible_fold_level_next
  endif

  return [ l:lead_piping, l:tail_piping, l:line_piping ]
endfunction

" ***

" We try to reserve horizontal lead piping for folds that we assume contain
" content, and not for so-called 'border' folds, which are used for styling
" the document when folded (or 'ornamentation' folds, 'design' folds, etc.).
" - One assumption we make is that a leading space (or spaces, as configured
"   by the user, or disabled completely) indicates a style fold.
" - Another is that a blank title (all whitespace) is a design fold.
" - Or we can assume that a fold of 4 or fewer lines likely has no content
"   -- 3 lines for the fold title and sandwich buns, and 1 line after
"   (which is most often blank in practice).
" - Or that a leading Unicode character usually means the fold title is being
"   used for style, and not for content -- unless the Unicode character is
"   exempt from this rule by way of the g:restfold_weldable_unicode_allow_list
"   lookup. E.g., the plugin author sometimes uses a volume icon to indicate
"   the priority of Backlog item folds, e.g., '🔉 FTREQ: Don't pipe me, bruh'.
function! s:IsOrnamentationFold(lineno_title, line_piping)
  " Get the fold title and first character.
  let l:curr_line = getline(a:lineno_title)
  let l:line_char_0 = strcharpart(l:curr_line, 0, 1)

  " Easy way out: If first character is identifiably weldable, return early.
  if s:IsWeldablePiping(l:line_char_0, a:line_piping)
    return 0
  endif

  " Check if the line starts with some number of whitespace characters.
  if g:restfold_weldable_max_lead_spaces > -1
    let l:sp_lim = g:restfold_weldable_max_lead_spaces + 1

    if strcharpart(l:curr_line, 0, l:sp_lim) == repeat(' ', l:sp_lim)
      return 1
    endif
  endif

  " Check if the line is solely one or more whitespace characters.
  if !g:restfold_weldable_blank_lines
    \ && match(l:curr_line, '^\s\+$') == 0

    return 1
  endif

  " Check if the fold if less than some minimum number of lines.
  " - Get the start of the next fold, for counting lines.
  let l:visible_fold_start_next = foldclosed(foldclosedend(v:foldstart) + 1)
  " - MAGIC-NUMBER: 3 for the 3 header lines that start the fold section.
  let l:minimum_fold_lines = g:restfold_weldable_min_content_lines + 3
  if l:visible_fold_start_next > v:foldstart
     \ && (l:visible_fold_start_next - v:foldstart) < l:minimum_fold_lines

    return 1
  endif

  " Unless the user allows welding to any/all Unicode characters, check
  " if the first byte (strpart) is not the same as the first character
  " (strcharpart), which indicates a two-byte Unicode character; then,
  " check if the Unicode character is not itself a pipe character (which
  " the plugin prefers to pipe into); and then check that the user has
  " not made an exception for the character (e.g., '🔉').
  let l:starts_with_unweldable_two_byte_character = 1
    \ && !g:restfold_weldable_unicode_enable_all
    \ && l:line_char_0 != strpart(l:curr_line, 0, 1)
    \ && stridx(g:restfold_weldable_unicode_allow_list, l:line_char_0) == -1

  if l:starts_with_unweldable_two_byte_character
    return 1
  endif

  return 0
endfunction

" ***

function! s:DeterminePipeTwo(line_piping)
  if g:restfold_disable_piping
    return ''
  endif

  " Allow user to set g:restfold_fold_piping = '' without causing
  " Vim to add the '------' suffix in the absense of being explicit;
  " and also only only using 1 line between left-hand vertical line.
  if g:restfold_fold_piping == ''
    return ''
  endif

  let l:second_pipe = a:line_piping

  if !g:restfold_subfolds_marker
    " Could affect runtime (though would only double it).
    for l:foldline in range(v:foldstart, v:foldend)
      if v:foldlevel < s:LookupFoldLevelNumber(l:foldline)
        let l:second_pipe = g:restfold_subfolds_marker
        break
      endif
    endfor
  endif

  return l:second_pipe
endfunction

" ***

" Attached the title line to the piping prefix, usually with a space
" between the piping and the title, but sometimes -- if the title
" line itself is piping -- weld the piping to the title (no space).
function! s:PreparePrefixedLine(lineno_title, first_pipes, line_piping)
  let l:curr_line = getline(a:lineno_title)

  let l:line_char_0 = strcharpart(l:curr_line, 0, 1)

  let l:has_welded_pipes = 0
  if 1
    \ && !g:restfold_disable_piping
    \ && !g:restfold_no_pipe_welding
    \ && s:IsWeldablePiping(l:line_char_0, a:line_piping)

    " The fold title starts with the fold_piping character. Weld it.
    let l:has_welded_pipes = 1
  endif

  let l:lvl_prefix = ''
  if !g:restfold_disable_piping
    " Create the piping prefix, indented with spaces per its level.
    let l:lvl_prefix = a:first_pipes

    if v:foldlevel > 1
      " The maximum fold level reSTfold identifies is 4, so this will add
      " 0-3 spaces to the prefix (which itself, by default, is 2 characters).
      let l:lvl_prefix = repeat(' ', v:foldlevel - 1) . l:lvl_prefix
    endif
  endif

  if g:restfold_min_title_width > 0 && !l:has_welded_pipes
    let l:pad_width = g:restfold_min_title_width - strwidth(l:curr_line)
    if l:pad_width > 0
      let l:curr_line = l:curr_line . repeat(' ', l:pad_width)
    endif
  endif

  let l:prefixed_line = l:curr_line

  if !g:restfold_disable_piping
    if l:has_welded_pipes
      " I.e., previously tested and determined:
      "     !g:restfold_no_pipe_welding
      "     \ && s:IsWeldablePiping(l:line_char_0, a:line_piping)
      " Magic line: If line starts with piping, connect to the fold piping.
      let l:prefixed_line = a:line_piping . l:curr_line
      " Same path as above:
      "   let l:has_welded_pipes = 1
    else
      let l:whitespace_prefix = repeat(' ', strwidth(a:line_piping))

      if !g:restfold_no_pipe_welding
        \ && l:line_char_0 == ' '
        \ && s:IsWeldablePiping(strcharpart(l:curr_line, 1, 1), a:line_piping)
        " Because of magic line, if line starts with space and then piping,
        " remove the space, so user can have piping line with a space between
        " fold piping and title piping (i.e., and not two spaces minimum).
        let l:prefixed_line = l:whitespace_prefix . strcharpart(l:curr_line, 1)
      else
        let l:prefixed_line = l:whitespace_prefix . l:curr_line
      endif
    endif
  endif

  let l:level_prefix_and_line = l:lvl_prefix . l:prefixed_line

  return [ l:level_prefix_and_line, l:has_welded_pipes ]
endfunction

" ***

function! s:IsWeldablePiping(test_char, line_piping)
  if a:line_piping != '─'
    " If not using standard piping, only magic off that pipe character
    " (as none of the fancy pipes below will be known to be a good fit).
    return a:test_char == a:line_piping
  endif

  " If user sticks to standard (thin) piping, magic off anything that
  " similarly connects to horizontal thin piping (Vim's `hh` digraph,
  " which connects to: lu, lU, hu, hU, ld, lD, hd, hD, hv, and hV).

  " Check first if '─', aka g:restfold_fold_piping, then the others.
  return 0
    \ || a:test_char == '─'
    \ || a:test_char == '┘'
    \ || a:test_char == '┚'
    \ || a:test_char == '┴'
    \ || a:test_char == '┸'
    \ || a:test_char == '┐'
    \ || a:test_char == '┒'
    \ || a:test_char == '┬'
    \ || a:test_char == '┰'
    \ || a:test_char == '┤'
    \ || a:test_char == '┨'
    \ || a:test_char == '┼'
    \ || a:test_char == '╂'
endfunction

" ***

function! s:TruncatePrefixedLine(level_prefix_and_line, tail_and_count, line_piping)
  let l:tail_width = g:restfold_tail_width
  if g:restfold_disable_piping
    " (lb): I'd assume this should be zero, but then making the window
    " narrower shifts some of the line counts rightward as the title
    " lines get squished. But 1 works great, not sure why, no shifting.
    let l:tail_width = 1
  endif

  let l:num_col_width = s:CalculateNumberColumnWidth()

  " Calculate the start of the trailing piping, and truncate the title.
  " See comment after: use strwidth() and not strlen() or strdisplaywidth().
  let l:lhs_width_avail = winwidth(0)
    \ - l:num_col_width
    \ - strwidth(a:line_piping)
    \ - strwidth(a:tail_and_count)
    \ - l:tail_width

  if l:lhs_width_avail < 1
    " Unlikely path.
    return ''
  endif

  " NOTE: Use strcharpart, not strpart, to truncate at a display width,
  " and not at a byte count. The latter is dangerous and could chop a
  " Unicode in half, leaving phantom control bytes. E.g., consider the
  " 3-character string 'X' followed by a Tab followed by a 4-byte Unicode:
  "   echo strlen('X	🦅')            " 6
  "   echo strpart('X	🦅', 0, 4)      " 'X	<f0><9f>'  -- 4 is middle of 🦅
  "   echo strdisplaywidth('X	🦅')    " 6  -- 6 when tabstop=4 (Tab counts as 3)
  "   echo strwidth('X	🦅')          " 4  -- Counts tab as 1 (tabstop ignored)
  "   echo strchars('X	🦅')          " 3  -- Number of characters
  "   echo strcharpart('X	🦅', 0, 3)  " 'X	🦅'
  "   echo strcharpart('X	🦅', 0, 2)  " 'X	'
  " Note also difference between the strdisplaywidth/strwidth/strchars,
  " and that the target width is akin to strwidth(), but that strcharpart()
  " operates on strchars()-esque character indices. This means that the call
  " to strcharpart might not truncate to the desired width, and, in fact,
  " the call might not affect the string at all! E.g., consider again our
  " feathered friend as the title, but two of them, e.g., '🦅🦅'. The display
  " width is 4 (what strwidth/strdisplaywidth says), but strchars is 2. If
  " the user narrowed the window pane so that 3 characters were available,
  " we'd call strcharpart('🦅🦅', 0, 3), which does not affect the string,
  " which is only 2 characters long. Even adding one more does nothing, as
  " strcharpart('🦅🦅', 0, 2) is still the length of the string!
  " - Because we don't know the positions of the extra wide characters,
  "   I don't think there's a deterministic approach to calculating the
  "   character to truncate at. So we'll have to take an iterative approach.
  " - I suppose we can at least say that there are only 1- and 2-character
  "   wide characters.

  " Try first as though each character is also one width, the most generous cut.
  let l:fold_line_lhs = strcharpart(a:level_prefix_and_line, 0, l:lhs_width_avail)

  " Check the result to see if that worked. If not, iterate until we find a value
  " that works.
  let l:result_width = strwidth(l:fold_line_lhs)

  while l:result_width > l:lhs_width_avail
    let l:line_chars = strchars(l:fold_line_lhs)
    let l:fold_line_lhs = strcharpart(l:fold_line_lhs, 0, l:line_chars - 1)
    let l:result_width = strwidth(l:fold_line_lhs)
  endwhile

  return l:fold_line_lhs
endfunction

" ***

" Because winwidth(0) includes the number column, we need to subtract its
" width to determine how many columns wide the fold line can occupy.
function! s:CalculateNumberColumnWidth()
  " In practice, because Vim defaults numberwidth=4 and most files you'll
  " work on are less than 10k lines, l:num_col_width will resolve to 5.
  let l:num_col_width = 0

  if &number
    " The number column is showing, which is included in winwidth(0).
    let l:num_col_width = strlen(string(line('$')))
    " - MAGIC_NUMBER: There's one space always between the number and the text.
    let l:num_col_width += 1
    if l:num_col_width < &numberwidth
      l:num_col_width = &numberwidth
    endif
  endif

  return l:num_col_width
endfunction

" ***

function! s:PrepareTailPipeAndLinesCount(lead_piping, tail_piping, line_piping)
  if g:restfold_lines_count_hide
    return ''
  endif

  let l:llcnt_width = g:restfold_lines_count_width + strwidth(g:restfold_lines_count_units)

  let l:lines_count = v:foldend - v:foldstart + 1

  let l:line_ending = ' ' . a:lead_piping
  if g:restfold_disable_piping
    let l:line_ending = ' '
  endif

  let l:tail_and_count = ''
    \ . a:line_piping
    \ . a:tail_piping
    \ . ' '
    \ . printf("%" . l:llcnt_width . "s", l:lines_count . g:restfold_lines_count_units)
    \ . l:line_ending

  return l:tail_and_count
endfunction

" ***

function! s:AppendPipingSoilStack(tail_and_count, line_piping)
  let l:fold_line_rhs =
    \ a:tail_and_count . repeat(a:line_piping, g:restfold_tail_width)

  return l:fold_line_rhs
endfunction

" ***

function! s:CalculateFoldLineWidth(fold_line_lhs, fold_line_rhs)
  " Calculate the width used by the title, the piping, and the lines count.
  " Note that &foldcolumn is probably 0 (our line conveys the same info.).
  let l:fold_line_len = 0
    \ + strwidth(a:fold_line_lhs)
    \ + strwidth(a:fold_line_rhs)
    \ + &foldcolumn

  return l:fold_line_len
endfunction

" ***

function! s:AssembleFoldLine(fold_line_lhs, fold_line_rhs, has_welded_pipes, line_piping)
  let l:fold_line_len = s:CalculateFoldLineWidth(a:fold_line_lhs, a:fold_line_rhs)

  let l:hr_sep = ' '
  if a:has_welded_pipes
    let l:hr_sep = a:line_piping
  endif

  let l:num_col_width = s:CalculateNumberColumnWidth()

  let l:tail_len = winwidth(0)
    \ - l:num_col_width
    \ - l:fold_line_len
    \ - strwidth(l:hr_sep)

  if !g:restfold_disable_piping
    let l:var_length_hr = l:hr_sep . repeat(a:line_piping, l:tail_len)
  else
    " Interestingly, without this, Vim falls back to using '-' dashes.
    " But when piping is disabled, a whitespace tail looks nice.
    let l:var_length_hr = l:hr_sep . repeat(' ', l:tail_len)
  endif

  let l:entire_fold_line = a:fold_line_lhs . l:var_length_hr . a:fold_line_rhs

  return l:entire_fold_line
endfunction

" ################################################################# "

function! s:CreateMaps()
  augroup restfold_default_mappings
    au!

    " Wire <S-F5> to recalculating and collapsing folds,
    " and scrolling buffer window to the top. Aka *reload*.
    autocmd BufEnter,BufRead *.rst noremap <silent><buffer> <S-F5> :call ReSTFolderUpdateFolds(1)<CR>
    autocmd BufEnter,BufRead *.rst inoremap <silent><buffer> <S-F5> <C-O>:call ReSTFolderUpdateFolds(1)<CR>

    " Wire <F5> to recalculating folds (aka *refresh*), without
    " expanding or collapsing folds, and without scrolling. If
    " called before <S-F5>, behaves like <S-F5> the first time.
    " - Note that I tried two 'simpler' approaches:
    "     ... <F5> :let b:RESTFOLD_SCANNER_LOOKUP = []<CR>
    "   and
    "     ... <F5> :call <SID>HydrateFoldLevelLookup()<CR>
    "   but I think Vim needs us to set foldexpr again (or
    "   maybe foldmethod or foldtext) so that it bothers
    "   calling ReSTfoldFoldLevel for the recomputed levels.
    autocmd BufEnter,BufRead *.rst noremap <silent><buffer> <F5> :call ReSTFolderUpdateFolds(0)<CR>
    autocmd BufEnter,BufRead *.rst inoremap <silent><buffer> <F5> <C-O>:call ReSTFolderUpdateFolds(0)<CR>

    " Wire <Ctrl-Up> and <Ctrl-Down> to transposing fold with the fold above and the fold below.
    " - Note that fold levels will be recomputed after <Ctrl-Up> or <Ctrl-Down>,
    "   but not after an Undo.
    "   - MAYBE/2021-02-14: FTREQ: Recompute fold levels after Undo,
    "     or after undoing Ctrl-Up or Ctrl-Down, if easy to determine.
    autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Up>   \|:silent call ReSTFolderMoveUp()<CR>
    autocmd BufEnter,BufRead *.rst nnoremap <buffer> <silent> <C-Down> \|:silent call ReSTFolderMoveFoldDown()<CR>
  augroup END
endfunction

if !exists("g:restfold_create_default_mappings") || g:restfold_create_default_mappings
  call s:CreateMaps()
endif

" +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "

