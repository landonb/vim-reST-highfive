" Powerful (Cleverful!) reST section folder
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Project: https://github.com/landonb/vim-reSTfold#🙏
" License: GPLv3
"  vim:tw=0:ts=2:sw=2:et:norl:

" +----------------------------------------------------------------------+

" REFER: See the reST syntax file included with Vim.
" - E.g.:
"     /usr/share/vim/vim81/syntax/rst.vim
"   Or maybe:
"     ${HOME}/.local/share/vim/vim81/syntax/rst.vim
" See also the most current upstream source of the same:
"   https://github.com/marshallward/vim-restructuredtext

" REFER: See complementary reST highlights plugins from this author
"        (pairs well with this plugin to help you take notes in Vim):
"
"   https://github.com/landonb/vim-reST-highdefs#🎨
"   https://github.com/landonb/vim-reST-highfive#🖐
"   https://github.com/landonb/vim-reST-highline#➖

" +======================================================================+
" +======================================================================+

" *** DEV. UTIL. FCN.: Log message to file (b/c `echom` doesn't work from syntax).

" 2018-12-07: Log to file, inspired by lervag@github: b/c cannot echom from syntax file?
"   https://github.com/lervag/dotvim/blob/master/personal/plugin/log-autocmds.vim
function! s:log(message)
  silent execute '!echo "'
    \ . strftime('%T', localtime()) . ' - ' . a:message . '"'
    \ '>> /tmp/vim_log_dubs_after_syntax_rst'
endfunction

" NOTE: [lb]: I can `call s:log('...')` and `tail -F /tmp/vim_log_dubs_after_syntax_rst`
"       successfully. But I cannot `echom '...'` anything. Not sure why.

" +======================================================================+
" +======================================================================+

" *** SYNTAX GROUP: reST section highlighting.

function! s:DubsClr_rstSections()
  " reST header syntax can use any of the 32 punctation keys found on a US keyboard:
  "
  "   ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
  "
  " The documentation recommends using a subset of those, because "some characters
  " are more suitable than others":
  "
  "   = - ` : . ' " ~ ^ _ * + #
  "
  " Omitted from included rst syntax runtime:
  "
  "   ! $ % & ( ) , / ; < > ? @ [ \ ] { | }
  "
  " Although I'd respond that that's really user preference, and that the syntax
  " plugin should honor what reST itself honors. (I'd concede this might not be
  " the case if certain punctuation is used in a way that's not for headerizing,
  " but that might be interpreted as such, e.g., a merge conflict uses angle
  " brackets in such a way:
  "
  "   <<<<<<<<<<<<<<
  "   some code
  "   ==============
  "   other code
  "   >>>>>>>>>>>>>>
  "
  " and we wouldn't want any of this to be interpreted as headerization.
  " (But such code would most likely be in a block quote, anyway.)
  "
  " I'm adding in the missing punctuation and we'll see how it goes.
  "
  " (What I really want is a few more 'Big' symbols that'll look good
  " as the main, top-level section. I currently use '#', which is the
  " character that uses the most ink of all available characters. But
  " I think '$', '@', and '&' could also work to convey main-sectionness.)
  syn clear rstSections
endfunction

function! s:DubsSyn_rstSections()
  " Add the missing punctuation characters to reST header syntax matching:
  "
  "   !@$%&()[]{}<>/\|,;?
  "
  " [lb]: We use "very magic" regex to make non-counting groups.
  "
  "       See:
  "
  "         :h pattern-overview
  "
  "       Enable very magic regex:
  "
  "         /\v  \v  \v   the following chars in the pattern are "very magic"
  "
  "       Use a non-counting match group, %(...):
  "
  "         \%(\)         A pattern enclosed by escaped parentheses.
  "         Just like \(\), but without counting it as a sub-expression.
  "         This allows using more groups and it's a little bit faster.
  "
  "       See also:
  "
  "         :h literal-string
  "
  "       which explains why we use double quotes and not single quotes,
  "       because we want to use the escaped character, "\v", and
  "       not the two characters, slash and v, '\v' (or "\\v").
  "
  " NOTE: `-` must come last so it is not interpreted as range.
  "
  " NOTE: `+` does not highlight when used both below and above,
  "             because it's interpreted as rstTableLines.
  "
  " 2021-10-14: On second thought, disable spell checking.
  " - For one, some rules will be superceded:
  "   - AcronymNoSpell, e.g., 'ABCs' is under-squiggled as misspelled.
  "   - Code blocks, e.g., ``fooBar``.
  " - The under-squiggle makes the title more difficult to read.
  " - So don't use @Spell, e.g., not: syn match rstSections ... contains=@Spell
  "
  syn match rstSections "\v^%(([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#!@$%&()[\]{}<>/\\|,;?-])\2{2,}$" contains=@NoSpell
endfunction

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
  syn match FIVERsPunctuated '\(^\|[[:space:]\n\[(#]\)\zs[_[:upper:][:digit:]]\{5}\([/:]\)\@=' contains=@NoSpell
  "                                                              Followed by a slash ^
  "                                                                    ... or a colon ^

  " Not as bright a yellow, to be less noticeable than FIVERsAlwaysHot.
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
  "   not see a change, FIVERsAlwaysHot still takes ~0.10 secs. on a ~10k line file.
  "   E.g.,
  "     let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\ze\([.,:/[:space:]\n]\)'
  let l:fiver_pat = '\(^\|[[:space:]\n\[(#]\)\zs\(' . l:fiver_re . '\)\([.,:/[:space:]\n]\)\@='
  let l:syn_cmd = "syn match FIVERsAlwaysHot '" . l:fiver_pat . "' contains=@NoSpell"
  exec l:syn_cmd

  " HRMMM/2021-01-19: Yellow without bold is almost more striking.
  "  MAYBE: FIVERsPunctuated is Yellow but not bold; maybe change its color.
  hi def FIVERsAlwaysHot guifg=Yellow gui=bold cterm=bold
endfunction

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
function! s:HighFive_XXXXDs_Strikethru()
  syn match FiverWordsXXXXD '\%(\(^\|[[:space:]\n\[(#]\)\zs\(BUILD\|COVID\|FOUND\)\([.,:/[:space:]\n]\)\@=\)\@!\(\(^\|[[:space:]\n\[(#]\)\zs[[:upper:]][[:upper:]][[:upper:]][[:upper:]]D\([.,:/[:space:]\n]\)\@=\)' contains=@NoSpell
  hi def FiverWordsXXXXD guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" SPOKE is the finished state of SPIKE. (I'll admit it, I got nothing better! At least it's something.)
" FIXME/2021-08-12 19:27: Combine FIXED and SPOKE.
function! s:HighFive_XXXXDs_Strikethru_SPOKE()
  syn match FiverWordsSPOKE '\(^\|[[:space:]\n\[(#]\)\zsSPOKE\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  hi def FiverWordsSPOKE guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" ANNUL is a way to cancel FIXME so it appears in strikethrough, to avoid FIXED,
" and because WONTFIX too many characters. WNTFX it? Naw. ANNUL it.
function! s:HighFive_XXXXDs_Strikethru_ANNUL()
  syn match FiverWordsANNUL '\(^\|[[:space:]\n\[(#]\)\zsANNUL\([.,:/[:space:]\n]\)\@=' contains=@NoSpell
  hi def FiverWordsANNUL guifg=Purple gui=strikethrough cterm=strikethrough
endfunction

" +----------------------------------------------------------------------+

" *** (p)reST(o) reST extension: reSTrule: Pseudo-Horizontal Rule Highlights

function! s:Presto_HRrules()
  " 2018-01-30: BONKERS!
  "
  "   This is pretty cool. And it only serves one purpose:
  "     Making me color-happy when reSTing.
  "   That is, if I repeat the same character 8 or more times
  "     on its own line, it'll be highlighted!
  "   You can fiddle with the highlights for specific characters
  "     below.
  "   In this way, you can create more visually appealing reST
  "     documents, and you can more easily highlight section
  "     headers, as well as section delimiters!

  " - The HR match interferes with rstSections, whether it's defined before or
  "   after, and I'm not sure what's up, so only highlight when HR is followed
  "   by newlines, to avoid conflict.
  "   - (And note that `\n\n` sorta works, but the highlight only works if
  "      there are two trailing blank lines; whereas using just `\n` works,
  "      but then the top line of a real section header gets hijack-highlighted
  "      (the top line of the header should be rstSections like the header
  "      title and the bottom line of the header, but instead the top line
  "      gets a rstFakeHRAll match).
  "
  " - Note that the captured (.) character \1 matches case-insensitively.
  "   - E.g., `e` will match `E`, so
  "       EEeeeeEEEEEEeee
  "     will match.
  "   - There's probably a way to match case-sensitively but meh.
  "
  " Match lines with the same character repeating 8 or more times,
  " with optional preceding and trailing whitespace.
  " - Note that, even though this rule is first, it'll override the
  "   following rules, sorta. E.g., if we used this rule with a period
  "   to match any character:
  "     syn match rstFakeHRAll '^\n\s*\(.\)\1\{8,}\s*\n$'
  "   then typing 8 repeating asterisks as one line would match the
  "   rstFakeHRStars rule, but typing 9 or more repeating asterisk
  "   would match rstFakeHRAll instead. Not sure why. To avoid this,
  "   exclude the special characters from the 'all' match.
  syn match rstFakeHRAll   '^\n\s*\([^|*$()%]\)\1\{8,}\s*\n$'
  " Match lines of repeating `|`s.
  syn match rstFakeHRPipes '^\s*|\{8,}\s*\n$'
  " Match lines of repeating `$`s.
  syn match rstFakeHRBills '^\s*\$\{8,}\s*\n$'
  " Match lines of repeating `*`s.
  syn match rstFakeHRStars '^\s*\*\{8,}\s*\n$'
  " Match lines of repeating `(`s or `)`s.
  syn match rstFakeHRParns '^\s*[()]\{8,}\s*\n$'
  " Match lines of repeating `%`s.
  syn match rstFakeHRPercs '^\s*%\{8,}\s*\n$'

  " Orange-yellow: Statement, or Keyword
  hi! def link rstFakeHRAll   Statement
  " More orangy (darker than orange-yellow)
  hi! def link rstFakeHRStars Delimiter
  " Light pinkish-orangish-reddish
  hi! def link rstFakeHRPercs String
  " Green: Type, or Question
  hi! def link rstFakeHRPipes Question
  " White on baby blue
  hi! def link rstFakeHRParns MatchParen
  " Black on baby blue
  hi def rstHorizRuleUser01 term=reverse guibg=DarkCyan guifg=Black ctermfg=1 ctermbg=6
  hi! def link rstFakeHRBills rstHorizRuleUser01
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

function! s:DubsRestWireBasic()
  call s:DubsClr_rstSections()

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
    call s:HighFive_XXXXDs_Strikethru()
    call s:HighFive_XXXXDs_Strikethru_SPOKE()
    call s:HighFive_XXXXDs_Strikethru_ANNUL()
  else
    silent! syn clear rstCitationReference
    silent! syn clear rstFootnoteReference
    silent! syn clear rstInlineInternalTargets
    silent! syn clear rstSubstitutionReference
  endif

  call s:Presto_HRrules()

  " Do real reST Section highlighting so it overrides, e.g., rstFakeHRAll.
  call s:DubsSyn_rstSections()
endfunction

" +----------------------------------------------------------------------+

call s:DubsRestWireBasic()

