" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/vim-reST-highfive#🖐
" License: GPLv3
" Summary: Highlight FIVER words in your notes. #FIVERs #WORDS

" +----------------------------------------------------------------------+

" REFER: See complementary reST highlights plugins from this author
"        (pairs well with this plugin to help you take notes in Vim):
"
"   https://github.com/landonb/vim-reSTfold#🙏
"   https://github.com/landonb/vim-reST-highdefs#🎨
"   https://github.com/landonb/vim-reST-highfive#🖐
"   https://github.com/landonb/vim-reST-highline#➖

" REFER: See the reST syntax file included with Vim.
" - E.g.:
"     /usr/share/vim/vim81/syntax/rst.vim
"   Or maybe:
"     ${HOME}/.local/share/vim/vim81/syntax/rst.vim
" See also the most current upstream source of the same:
"   https://github.com/marshallward/vim-restructuredtext

" +======================================================================+
" +======================================================================+

" SAVVY: You can `hi clear {group-name}` and `hi def...` in a reST file to live-test.
"        But for `syn clear ...` and `syn match ...` you need to `:e` reload the file
"        (or `do Syntax`/`doautocmd Syntax` (`syntax sync fromstart` did not work FM)).

" +======================================================================+
" +======================================================================+

" Highlight FIVER words, but split the pattern into two categories:
" - Always highlight *any* FIVER followed by certain punctuation:
"   - Highlight any FIVER followed by a slash or a colon, e.g.,
"     `FIVER:` and `FIVER/` are highlighted, but not `any FIVER alone`.
" - Selectively highlight specific FIVER words chosen to be special:
"   - E.g., `FIXME` is always highlighted.
"   - See the l:fivers list below.

" +----------------------------------------------------------------------+

" First match: Selectively highlight FIVER words that appear alone
" (FIVERs surrounded by whitespace), otherwise we might highlight
" acronyms that we don't want to emphasize (such as STOCK symbols).
" - Instead, highlight FIVER words followed by certain punctuation,
"   for now, either a forward slash or a colon.
"   - This assumes that this format (e.g., 'FIVER/', or 'FIVER:')
"     is generally only used in the context of something you want
"     to emphasize, e.g.,
"     - 'FIVER/2021-01-19 00:08: Some note'.
"     - 'FIVER: Some other note`.
"
" FEATR/2025-09-16: Now with limited punctuation, e.g., WTF?!: or
" WOW!!/ or AC/DC or A-OK!:
" - But exclude colon, or clock time is highlighted, e.g., 12:34:
"   so not using [:punct:] but being selective instead.

" REFER:
"   :h /character-classes
"   :h gui-colors
function! s:HighFive_FIVERs_Punctuated()
  " See FIVERsAlways_Hot comments: Avoid stealing highlight from rstSections
  " by using elaborate rstSections check, including for reSTfold delimiters:
  "   [=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]
  "
  " TRYME: [SAVVY: You might need to `NoiceDisable`, otherwise these don't always echo]:
  "   :echo matchstr("FIVER: You bet!\n####@",  '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   # This simulates a reSTfold header, so not highlighted:
  "   :echo matchstr("FIVER: You wish!\n@@@@@", '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "FIVER:",                 '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "FIVER/",                 '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("<FIVER:>",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("(FIVER/)",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("[FIVER:]",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("{FIVER/}",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr(" NOPE!  ",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr(" FIVE!:",                 '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr(" AC/DC:",                 '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr(" AB\\AC:",                '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   # I do not remember why I had this use case, so removed it:
  "   :echo matchstr("#FIVER: support removed", '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "
  syn match FIVERsPunctuated                    '\%(^\|[[:space:]\n<\[({]\)\zs[_[:upper:][:digit:]\\/!?-]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!' contains=@NoSpell
  "                                                                                          Followed by a slash ^
  "                                                                                                ... or a colon ^
  "                                                 Not followed by rstSections reSTfold header indicator (on following line) ^ \(..............................................................\)\@!

  " Not as bright a yellow, to be less noticeable than FIVERsAlways_Hot.
  hi def FIVERsPunctuated guifg=#caf751 gui=bold cterm=bold
endfunction

" Don't highlight number-only arbitrary FIVERs matched by FIVERsPunctuated
" (Or, rather, steal the match and mimic the Normal highlight).
" - E.g., avoid highlighting 12345: or 68041/.
" - PROFILING: I assume this is cheaper than a look-ahead in FIVERsPunctuated.
function! s:HighFive_FIVERs_No_Allnums()
  " TRYME:
  "   :echo matchstr("12345:",        '\%(^\|[[:space:]\n<\[({]\)\zs[[:digit:]]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("42069/",        '\%(^\|[[:space:]\n<\[({]\)\zs[[:digit:]]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')

  syn match FIVERsPunctuatedNoAllnums '\%(^\|[[:space:]\n<\[({]\)\zs[[:digit:]]\{5}\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!' contains=@NoSpell

  " COPYD: Default to Dubs After Dark 'Normal' highlight:
  "          highlight Normal ctermfg=15 guifg=White guibg=#060606
  " - CXREF: ~/.kit/nvim/landonb/dubs_after_dark/colors/after-dark.vim:106
  hi def FIVERsPunctuatedNoAllnums ctermfg=15 guifg=White cterm=NONE
endfunction

" +----------------------------------------------------------------------+

" Second match: Always highlight a few specific FIVER words.
" - Keep this list brief, as it's not the speediest regex.
" - 2024-10-20: I've also found after 5+ years using this plugin
"   that highlighted standalone FIVERs are not that useful....

function! s:HighFive_FIVERs_Always_Hot()

  " USAGE: Modify this list to your liking.
  "
  " - Though see the BWARE, below, re: performance.

  " MAYBE: Generate this list from g: variables that user can set/override.

  let l:fivers = []

  " This is MAYBE the only always-highlighed FIVER where it's sometimes
  " useful as a means to catch your eye in the middle of a block of text
  " (without explicitly needing to enable it, e.g., MAYBE/ or MAYBE:).
  let l:fivers = add(l:fivers, 'MAYBE')

  " Author uses this as a standalone reminder under a block of text
  " in their receipts and shipment tracking file to enumerate when
  " a bunch of packages are inbound, e.g.,
  "   - AWAIT / AWAIT / AWAIT
  " and then as they're received, they're marked complete, e.g.,
  "   - AWAIT / AWAIT / RECVD/AWAIT
  " which is about the only (super esoteric) reason for making this
  " to be always-on.
  let l:fivers = add(l:fivers, 'AWAIT')

  " The list of always-on, super-hot FIVERs used to be much longer.
  " - But 5+ years into using this plugin, I've audited my notes, and I
  "   hardly appreciate the always-on feature.
  " - I'll use MAYBE for emphasis. And I found a standalone use for AWAIT.
  " - But the other FIVERs that were always-on that I've removed I didn't
  "   find useful, like FIXME, LATER, SPIKE, LEARN, STUDY, WATCH, TRACK,
  "   ORDER, CHORE, AUDIT, CHECK, REPLY, TRYME, etc.
  "   - Because these are all actionable FIVERs, I'd only ever write them
  "     as such, e.g., "LEARN: Study Rust", or "CHORE: Clean your room".
  "   - There were also four non-actionables I had always on, but I never
  "     used them, either: HRMMM, MEHHH, BONUS, and OOOPS. (Though you could
  "     make an argument for OOOPS or OCRAP, perhaps, to draw your eye to
  "     something in a block of text. But you can always **embolden** text,
  "     because reST, though it won't be colorful. But still, I didn't
  "     find these useful.)
  "     MAYBE: You could add a new highlight feature, e.g., >COLOR-THIS<
  "
  " BWARE: Finally, this highlight has been known to be slow, at least in
  " MacVim. I've sometimes seen selecting text with <Shift-Ctrl-Right> or
  " <Shift-Ctrl-Left> then trying to <Ctrl-C> real quick fail comically,
  " because the <Ctrl-C> would run before the selection got made. So you'd
  " see Vim inject a literal '<D-c>' into the document and exit Insert mode
  " (tho I never saw this in gVim on Linux Mint, just in MacVim). [Oh, note
  " that I have a Hammerspoon script that translates <Ctrl-C> presses to
  " <Cmd-C>, hence the '<D-c>'.] (And then if I disable this highlight, I
  " wouldn't be able to reproduce the issue.) (It might have to do with the
  " look-ahead to check if the FIVER is in a reST header, or maybe because
  " the \| list of FIVERs was too long, who knows, doesn't seem worthwhile
  " trying to investigate the performance of an already complicated regex
  " match that has to run all the time for a few highlights that ultimately
  " are not important! Also, now that this list is just 2 words, I haven't
  " been able to reproduce the issue.
  " - SAVVY: If you have performance issues with this highlight in the
  "   future, just disable it — you're not losing much. It's probably the
  "   least snazzy feature in this whole file.

  " ***

  " Profiling: Vim docs suggest using \zs to start match, and not look-behind \@<=.
  " - I also tried similar with \ze to end match, replacing look-ahead \@=. But I do
  "   not see a change, FIVERsAlways_Hot still takes ~0.10 secs. on a ~10k line file.
  "   E.g.,
  "     let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\ze\([.,:/[:space:]\n]\)'
  " - This was the pattern until updated to avoid rstSections clash:
  "     let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\([.,:/[:space:]\n]\)\@='
  "   - TRYME:
  "       :echo matchstr(' A special FIVER ', '\(^\|[[:space:]\n\[(#]\)\zs\(FIVER\)\([.,:/[:space:]\n]\)\@=')
  " - The newest pattern (below) avoids inconsistent clashing with rstSections.
  "   - When a special FIVER *starts* (and only when it starts)
  "     the title of a reSTfold section;
  "     But only (that I saw before I fixed it) if it's got a
  "     single equal sign underscore, e.g.,
  "        FIVER: This does not highlight correctly
  "        ========================================
  "     Or if surrounded by @ symbols, e.g,
  "        @@@@@@@@@@@@@@@
  "        FIVER: Nor this
  "        @@@@@@@@@@@@@@@
  "     But not if surrounded or underscored by #'s;
  "     Then the reSTfold title line is not highlighted by rstSections,
  "     but the FIVER is highlighted instead, and the remaining text
  "     is highlighted normally (i.e., not highlighted; just white).
  "   - I tried moving this definition to a syntax/rst.vim, which
  "     made it load *before* rstSections, but that no effect. So
  "     I guess :highlight match order *just doesn't matter.*
  "   - The solution is a negative look-ahead (\@=) using this
  "     block:
  "      [=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]
  "    from rstSections in
  "      ~/.kit/nvim/landonb/vim-reSTfold/after/syntax/rst.vim:131
  "    and used here to avoid stealing rstSections highlight.
  "    - PROFILING: But at what cost?
  "
  " TRYME:
  "   :echo matchstr("A FIVER you bet",        '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIVER\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("FIVER nope nope\n@@@@@", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIVER\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "AWAIT",                 '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "AWAIT/",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "AWAIT:",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("<AWAIT>",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("(AWAIT:)",               '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("[AWAIT/]",               '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("{AWAIT}",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(AWAIT\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "
  let l:fiver_re = join(l:fivers, '\|')
  let l:fiver_pat =                            '\%(^\|[[:space:]\n<\[({]\)\zs\%(' . l:fiver_re . 
    \                                                                               '\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!'
  let l:syn_cmd = "syn match FIVERsAlways_Hot '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  " HRMMM/2021-01-19: Yellow without bold is almost more striking.
  "  MAYBE: FIVERsPunctuated is Yellow but not bold; maybe change its color.
  hi def FIVERsAlways_Hot guifg=Yellow gui=bold cterm=bold
endfunction

" -------

" MAYBE/2021-01-16 18:39: Consider available attrs:
"
"   bold, underline, undercurl, strikethrough, italic, reverse (inverse), standout
"
" The standout vs reverse (aka inverse) option is interesting.
" - The same style can be done different ways,
"   e.g., these three are similar:
"     hi def foo guifg=Black guibg=Purple
"     hi def foo guifg=Purple guibg=Black gui=reverse
"     hi def foo guifg=Purple guibg=Black gui=inverse
"     hi def foo guifg=Purple guibg=Black gui=standout
"   but I think the text in standout is more readable (a little fatter).
"
" Useful? Maybe for testing?:
"   nocombine   override attributes instead of combining them
"   NONE

" TRACK/2021-02-19: MacVim does not support strikethrough.
" - Issue opened April, 2020, but no traction since?
"   https://github.com/macvim-dev/macvim/issues/1034

" +----------------------------------------------------------------------+

function! s:HighFive_FIVERs_Actionable()

  let l:fivers = []

  let l:fivers = add(l:fivers, 'FIXME')
  let l:fivers = add(l:fivers, 'SPIKE')
  " let l:fivers = add(l:fivers, 'FTREQ')

  " TRYME: (SAVVY: Run `NoiceDisable` first, otherwise duplicate messages not necessarily displayed):
  "   :echo matchstr("A normal SPIKE",          '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("SPIKE nope nope\n@@@@@",  '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "SPIKE",                  '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "SPIKE/",                 '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr( "SPIKE:",                 '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("<SPIKE>",                 '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("(SPIKE:)",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("[SPIKE/]",                '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("{SPIKE}",                 '\%(^\|[[:space:]\n<\[({]\)\zs\%(SPIKE\|FTREQ\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')

  " USYNC: Similar regex as FIVERsPunctuated.
  let l:fiver_re = join(l:fivers, '\|')
  let l:fiver_pat =                             '\%(^\|[[:space:]\n<\[({]\)\zs\%(' . l:fiver_re . 
    \                                                                               '\)\%([/:]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!'
  "                                                                    Followed by a slash ^
  "                                                                          ... or a colon ^
  "                           Not followed by rstSections reSTfold header indicator (on following line) ^ \(..............................................................\)\@!
  let l:syn_cmd = "syn match FIVERsActionable '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  hi def FIVERsActionable guifg=Yellow gui=bold cterm=bold
endfunction

" +======================================================================+
" +======================================================================+

" Strikethrough FIVERs that represent the completed state of active FIVERs,
" using the common English language past tense conjugation.
" Some Examples: (Where FIXEM is a FIXME without the syntax highlight):
"   - FIXEM → FIXED  # For items you fixed, 'natch.
"   - FIXEM → ANNUL  # Any canceled task, e.g., a FIXME you WONTFIX.
"   - ***** → NOTED  # For any note you want to deprioritize.
"   - ***** → COPYD  # For any note you want to mark as duplicate.
"   - ORDER → ORDRD  # For products that you've purchased.
"   - SNIPD          # For text you moved from elsewhere, where you want a backref.
"   - SHIPD → RECVD  # For something that was shipped that's since been received.
"   - SPIKE → SPOKE  # Awkwardly-named finished state of SPIKE.
"   - AWAIT → WAITD  # For items that were delayed until later date or external trigger.
" History: This plugin used to ~~strikethrough~~ any FIXED ending in XXXXD,
" which is fast, but then you end up with a lot of stricken words that you
" really don't want highlighted as such.
" Pattern HINTS:
" - \%(...\)  - Like \(\), but without counting as sub-expression, and a little bit faster.
" - \@!       - Matches with zero width if preceding atom does NOT match.
" Highlight HINTS:
" - GTK gVim uses `gui=`,
"   terminal Vim uses `cterm=`,
"   I'm not sure what uses `term=`.

function! s:HighFive_XXXXDs_SimplePast()

  " USAGE: Modify this list to your liking.

  " MAYBE: Generate this list from g: variables that user can set/override.

  let l:fivers = []

  let l:fivers = add(l:fivers, 'FIXED')
  let l:fivers = add(l:fivers, 'ANNUL')
  let l:fivers = add(l:fivers, 'NOTED')
  let l:fivers = add(l:fivers, 'COPYD')
  let l:fivers = add(l:fivers, 'ORDRD')
  let l:fivers = add(l:fivers, 'SNIPD')
  let l:fivers = add(l:fivers, 'RECVD')
  let l:fivers = add(l:fivers, 'SPOKE')
  let l:fivers = add(l:fivers, 'WAITD')

  " Profiling: See comments near HighFive_FIVERs_Always_Hot's l:fiver_pat re: \zs vs. \@<=.
  "
  " TRYME:
  "   :echo matchstr( "FIXED",  '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr(" ANNUL ", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("<FIXED>", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("(ANNUL)", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("[FIXED]", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "   :echo matchstr("{ANNUL}", '\%(^\|[[:space:]\n<\[({]\)\zs\%(FIXED\|ANNUL\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!')
  "
  let l:fiver_re = join(l:fivers, '\|')
  let l:fiver_pat =             '\%(^\|[[:space:]\n<\[({]\)\zs\%(' . l:fiver_re . 
    \                                                                       '\)\%($\|[[:space:]\n.,/:>\])}]\)\@=\%(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\1\{4,\}\%($\|\n\)\)\@!'
  let l:syn_cmd = "syn match FIVERWordsXXXXDs '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  hi def FIVERWordsXXXXDs guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" +======================================================================+
" +======================================================================+

" SAVVY: If syntax highlighting appears disabled, even if the file has
" a Vim mode line saying otherwise, trying closing and reopening the
" file, or saving the file and running the `:e` command, or try this:
"
"     set rdt=9999
"     doautocmd Syntax
"     " Also works:
"     syn on

" 2021-01-16: This syntax plugin had been opt-in per file: you'd have
" to set redrawtimeout to something other than 2000 to enable these
" highlights. I think I was doing this because of performance issues
" with some of my reST files. But I'm no longer sure that's the case,
" or, if it was, it was probably on large files, and I've been in the
" habit recently of keeping files under 10,000 lines. Also, it's been
" annoying me that new rst files don't have these highlights enabled
" until I notice and remember to add a modeline.
"   So let's require users to opt-out instead!
"
" - tl;dr I'd rather this work on new files and without requiring modeline.
"
" USAGE: To opt-out, set redrawtimeout (rdt) to something less than 4999
"        but not 2000 (the default).
"
"      - E.g., to disable these highlights (and their associated
"        computational overhead), add a modeline like this atop
"        each reST file you want to opt-out:
"
"          .. vim:rdt=2001
"
"      - Otherwise, to have syntax highlighting enabled, use either
"        the default value:
"
"          .. vim:rdt=2000
"
"        or set it 5000 or larger:
"
"          .. vim:rdt=5000
"          .. vim:rdt=9999
"
" MAGIC: The 4999 below is arbitrary. (2021-01-16: And I
"        haven't had a reason to opt-out any files yet.)

" +======================================================================+
" +======================================================================+

function! s:reST_highfive_Wire_Highlights()
  let l:redrawtimeout = &rdt
  " MAGIC: Vim's rdt default is 2000 (2 secs.).
  let l:defaultRedrawTimeout = 2000
  " MAGIC: SYNC_ME: All the vim-reST* plugins use the same redrawtime
  "        logic: skip special highlights if rdt <= 4999 but not 2000.
  let l:syntaxEnableIfGreater = 4999

  " SAVVY/2024-12-17: In case another plugin turns off case matching,
  " ensure it's set appropriately.
  " - For instance, https://github.com/habamax/vim-rst calls
  "   `syn case ignore` but doesn't reset it, in which case the FIVERs
  "   defined above will match loosely (e.g., 'Fiver' would match).
  " - ALTLY: Add \C to start of every regexp pattern.
  let l:restore_case = execute('syntax case match')

  if (l:redrawtimeout == l:defaultRedrawTimeout)
     \ || (l:redrawtimeout > l:syntaxEnableIfGreater)
    call s:HighFive_FIVERs_No_Allnums()
    call s:HighFive_FIVERs_Always_Hot()
    call s:HighFive_FIVERs_Punctuated()
    call s:HighFive_FIVERs_Actionable()
    call s:HighFive_XXXXDs_SimplePast()
  else
    silent! syn clear rstCitationReference
    silent! syn clear rstFootnoteReference
    silent! syn clear rstInlineInternalTargets
    silent! syn clear rstSubstitutionReference
  endif

  execute l:restore_case
endfunction

" +----------------------------------------------------------------------+

call s:reST_highfive_Wire_Highlights()

