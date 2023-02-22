" Highlight FIVER words in your notes.
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project: https://github.com/landonb/vim-reST-highfive#🖐
" License: GPLv3
"  vim:tw=0:ts=2:sw=2:et:norl:

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

" HINT: You can `hi clear {group-name}` and `hi def...` in a reST file to live-test.
"       But for `syn clear ...` and `syn match ...` you need to `:e` reload the file
"       (or `do Syntax`/`doautocmd Syntax` (`syntax sync fromstart` did not work FM)).

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

" Ref:
"   :h /character-classes
"   :h gui-colors
function! s:HighFive_FIVERs_Punctuated()
  " See FIVERsAlways_Hot comments: Avoid stealing highlight from rstSections
  " by using elaborate rstSections check, including for reSTfold delimiters:
  "   [=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]
  "
  " TRYME:
  "   :echo matchstr("FIVER: You bet!\n####@",    '\(^\|[[:space:]\n\[(#]\)\zs[_[:upper:][:digit:]]\{5}\([/:]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\4\{4,\}\($\|\n\)\)\@!')
  "   :echo matchstr("FIVER: Move along!\n@@@@@", '\(^\|[[:space:]\n\[(#]\)\zs[_[:upper:][:digit:]]\{5}\([/:]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\4\{4,\}$\)\@!')
  "
  syn match FIVERsPunctuated '\(^\|[[:space:]\n\[(#]\)\zs[_[:upper:][:digit:]]\{5}\([/:]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\4\{4,\}$\)\@!' contains=@NoSpell
  "                                                              Followed by a slash ^
  "                                                                    ... or a colon ^
  "                Not followed by rstSections reSTfold header indicator (on following line) ^ \(...\)\@!

  " Not as bright a yellow, to be less noticeable than FIVERsAlways_Hot.
  hi def FIVERsPunctuated guifg=#caf751 gui=bold cterm=bold
endfunction

" +----------------------------------------------------------------------+

" Second match: Proactively (always) highlight specific FIVER words.
" - These are FIVER words that are always used in a FIVER context.
" - Well, these are FIVER words that the author always uses in a FIVER
"   context, i.e., these are conventional *actionable* words that I
"   capitalize to make them pop in my notes documents, but that work
"   without adding triggering punctuation (such as a slash or a colon).

function! s:HighFive_FIVERs_Always_Hot()

  " YOU: Modify this list to your liking.

  " NOTE: I include FIVERs in this list that I don't need unconditionally
  "       highlighted (without trailing / or : punctuation), but that I
  "       want to document nonetheless.

  let l:fivers = []

  " *** Most used action FIVERs ((lb): that the author uses)
  "     that'll always be highlighted.
  let l:fivers = add(l:fivers, 'FIXME')  " Want to do 'now'.
  let l:fivers = add(l:fivers, 'LATER')  " Want to do ... eventually.
  let l:fivers = add(l:fivers, 'MAYBE')  " Not sure if you want to do.

  let l:fivers = add(l:fivers, 'SPIKE')  " Agile meaning (requires 1-2h investigation).

  let l:fivers = add(l:fivers, 'LEARN')  " Articles, books, technology you want to study.
  let l:fivers = add(l:fivers, 'STUDY')  " Similar to LEARN (generally interchangeable).
  let l:fivers = add(l:fivers, 'WATCH')  " Video to WATCH (not to be confused with TRACK).

  let l:fivers = add(l:fivers, 'TRACK')  " Issue to keep an eye on (similar to SAVVY).
  let l:fivers = add(l:fivers, 'AWAIT')  " Issue on hold until something else happens.

  let l:fivers = add(l:fivers, 'ORDER')  " As in shopping (crap you want to buy).

  let l:fivers = add(l:fivers, 'CHORE')  " Physical chore around the house/city.
  "                            'ETASK'   " Digital chore you can do without thinking.
  let l:fivers = add(l:fivers, 'AUDIT')  " Something you want to review.
  let l:fivers = add(l:fivers, 'CHECK')  " Similar to AUDIT.
  let l:fivers = add(l:fivers, 'REPLY')  " As in email or persons.
  "                            'EMAIL'   " As in email.

  " *** Less used action FIVERs.
  "                            'TODAY'
  "                            'DAILY'
  "                            'RECUR'
  let l:fivers = add(l:fivers, 'TRYME')
  "                            'TWEAK'

  " *** Not really actions...
  let l:fivers = add(l:fivers, 'HRMMM')
  let l:fivers = add(l:fivers, 'MEHHH')
  let l:fivers = add(l:fivers, 'BONUS')
  let l:fivers = add(l:fivers, 'OOOPS')

  " *** EOL

  let l:fiver_re = join(l:fivers, '\|')
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
  "      ~/.vim/pack/landonb/start/vim-reSTfold/after/syntax/rst.vim:131
  "    and used here to avoid stealing rstSections highlight.
  "    - PROFILING: But at what cost?
  "
  " TRYME:
  "   :echo matchstr("A FIVER you bet",        '\(^\|[[:space:]\n\[(#]\)\zs\(FIVER\)\([.,:/[:space:]\n]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\5\{4,\}$\)\@!')
  "   :echo matchstr("FIVER nope nope\n@@@@@", '\(^\|[[:space:]\n\[(#]\)\zs\(FIVER\)\([.,:/[:space:]\n]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\5\{4,\}$\)\@!')
  "
  let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\([.,:/[:space:]\n]\)\@=\(.*\n\([=`:.'."'".'"~^_*+#!@$%&()[\]{}<>/\\|,;?-]\)\5\{4,\}$\)\@!'
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

" +======================================================================+
" +======================================================================+

" Strikethrough any FIVER ending in 'D'.
" - Except COVID, and whatever else you want to allowlist.
" - FIVERs that end in 'D' (aka XXXXD) are generally the completed state of
"   active FIVERs, using the common English language past tense conjugation.
"   - Some examples:
"     - FIXME → FIXED  # For items you fixed, 'natch.
"     - ORDER → ORDRD  # For products you wanted to purchase.
"     - AWAIT → WAITD  # For items that were delayed until later date or external trigger.
"     - PACKT → PACKD  # For items you wanted to pack for a trip, and then did.
" Pattern HINTS:
" - \%(...\)  - Like \(\), but without counting as sub-expression, and a little bit faster.
" - \@!       - Matches with zero width if preceding atom does NOT match.
" Highlight HINTS:
" - GTK gVim uses `gui=`,
"   terminal Vim uses `cterm=`,
"   I'm not sure what uses `term=`.
function! s:HighFive_XXXXDs_EndsWith_D()

  let l:fivers = []

  " BUILD: Tell yourself to build something, e.g., a 'gravel grinder'.
  " - I.e., software, or IRL.
  let l:fivers = add(l:fivers, 'BUILD')

  " COPYD: One of the author's latest conventions (2022-10-05):
  " - Remake _FIXME_ into _COPYD_ when you retire one _FIXME_
  "   that's duplicated elsewhere.
  "   - One use case: You have multiples of the same _FIXME_.
  "     - You want to retire one _FIXME_, but to tell yourself
  "       that it's not _FIXED_, but that it's _COPYD_ elsewhere,
  "       and still alive in your backlogs somewhere.
  "   - Another case: You have multiple actions under a _FIXME_,
  "     and you complete some of them. You then copy the unfinished
  "     tasks to a new _FIXME_, and you mark the old _FIXME_ as
  "     _COPYD_, telling yourself that you completed some of them,
  "     but not all, and that those you didn't complete are still
  "     accounted for.
  " - It follows that COPYD is a completion status, and
  "   not to be struck-through:
  "   - " NOTIT: a let l:fivers = add(l:fivers, 'COPYD')

  " COVID: More technically, COVID-19, the coronavirus, or SARS-CoV-2.
  " - "The shortened form COVID is acceptable if necessary for space in headlines,
  "    and in direct quotations and proper names."
  "    https://www.linkedin.com/pulse/ap-style-guide-covid-19-michael-grabowski/
  " - 👁ALSO: https://www.prnewsonline.com/ap-style-covid/
  let l:fivers = add(l:fivers, 'COVID')

  " FOUND: When you left a note to yourself to dig around for something
  " (in digitial docs, or in real life) and then found it, and now you're
  " retiring that note.
  let l:fivers = add(l:fivers, 'FOUND')

  " WEIRD: Like it sounds. Just a note that something is 'weird'.
  " - Not an action, just a label.
  let l:fivers = add(l:fivers, 'WEIRD')

  " Seems legit.
  let l:fivers = add(l:fivers, 'POOPD')

  " Aka, ONBOARDING, for SETUP notes.
  let l:fivers = add(l:fivers, 'ONBRD')

  " Aka, DEMOED. Except this is a ~completed~ task.
  "  let l:fivers = add(l:fivers, 'DEMOD')

  " Never let up.
  let l:fivers = add(l:fivers, 'SPEED')

  " oulda's
  let l:fivers = add(l:fivers, 'COULD')
  let l:fivers = add(l:fivers, 'WOULD')

  " *** EOList

  let l:fiver_re = join(l:fivers, '\|')
  let l:fiver_pat = '\%(\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\([.,:/[:space:]\n]\)\@=\)\@!\(\(^\|[[:space:]\n\[(#]\)\zs[[:upper:]][[:upper:]][[:upper:]][[:upper:]]D\([.,:/[:space:]\n]\)\@=\)'
  let l:syn_cmd = "syn match FiverWordsXXXXD '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  hi def FiverWordsXXXXD guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" -------

" Not all English words that indicate the Simple Past tense or otherwise
" signify a completed task end in 'D'. Those FIVER words are listed here.

function! s:HighFive_XXXXDs_SimplePast()

  " YOU: Modify this list to your liking.

  let l:fivers = []

  let l:fivers = add(l:fivers, 'SPOKE')  " Awkwardly-named finished state of SPIKE.
  let l:fivers = add(l:fivers, 'ANNUL')  " Any canceled task, e.g., a FIXME you WONTFIX.

  " *** EOL

  let l:fiver_re = join(l:fivers, '\|')
  " Profiling: See comments near HighFive_FIVERs_Always_Hot's l:fiver_pat re: \zs vs. \@<=.
  let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\([.,:/[:space:]\n]\)\@='
  let l:syn_cmd = "syn match FiverWordsXXXXDs '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  hi def FiverWordsXXXXDs guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" +======================================================================+
" +======================================================================+

" HINT: If syntax highlighting appears disabled, even if the file has
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
" YOU: To opt-out, set redrawtimeout (rdt) to something less than 4999
"      but not 2000 (the default).
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

  if (l:redrawtimeout == l:defaultRedrawTimeout)
     \ || (l:redrawtimeout > l:syntaxEnableIfGreater)
    call s:HighFive_FIVERs_Punctuated()
    call s:HighFive_FIVERs_Always_Hot()
    call s:HighFive_XXXXDs_EndsWith_D()
    call s:HighFive_XXXXDs_SimplePast()
  else
    silent! syn clear rstCitationReference
    silent! syn clear rstFootnoteReference
    silent! syn clear rstInlineInternalTargets
    silent! syn clear rstSubstitutionReference
  endif
endfunction

" +----------------------------------------------------------------------+

call s:reST_highfive_Wire_Highlights()

