###########################################################################
``vim-reST-highfive`` |em_dash| reST five-letter uppercase word highlighter
###########################################################################

.. |em_dash| unicode:: 0x2014 .. em dash

About This Plugin
=================

This plugin adds FIVER (uppercase five-letter word) highlighting
to your reST documents.

Supercharge your notetaking and knowledge management practices!

Install this plugin to make it easier to manage notes in Vim
using reStructuredText markup.

Why You Might Want to Use This Plugin
=====================================

If you like to use Vim to organize your life (I do!),
see how this plugin makes it easier to manage your notes.

Consider the following document::

  @@@@@@@@@@@@@@
  My Vim Backlog
  @@@@@@@@@@@@@@

  FTREQ: Develop a Vim plugin to highlight five-letter uppercase words.

  FIXME: Opening symlinks using netrw plugin causes save-file warning.

  LEARN: Teach yourself the latest Vim 9 script language: `:h new-9`.

Normally, only the header is highlighted in Vim (by the ``syntax/rst.vim``
syntax file).

But this plugin will highlight each of the five-letter words that are
preceded by a colon.

This is especially useful (at least to the author) when you've got a
lot of notes in a file, and you want action items to stand out.

For instance, I might have a "FIXME" note followed by a few paragraphs
of text, followed by another "FIXME", etc., and I want to be able to
scroll down the document and quickly see each "FIXME".

What are FIVER action words?
============================

In lieu of bug tracking or issue management software, you can use
reStructuredText files in Vim to manage your notes and "backlog"
items.

The author of this plugin has been doing so for over a decade, and
over the course of those years, I started using five-letter action
words to highlight different *types* of notes. This includes work
to be done, work completed, an interesting note I want to highlight,
etc.

For example, you might think of something you want to do, and then
you could record it in your notes with the appropriate FIVER word,
such as using "FTREQ" to denote new work that you'd like to complete::

  FTREQ: Write the `reST-highfive` help doc.

Or if you found an issue that you wanted to fix, you could use "FIXME"::

  FIXME: Promote the 'reST-highfive` plugin.

Other uses include documenting interesting information, such as using
"SAVVY" to remind yourself of some trick you learned::

  SAVVY: Search Gmail by date: `after:YYYY/MM/DD before:YYYY/MM/DD`

Or you could use "REFER" to reference information outside your notes
(and maybe you've got the `dubs_web_hatch
<https://github.com/landonb/dubs_web_hatch>`__ plugin installed, so you
could type ``<gW>`` to open the URL under the cursor), e.g.,::

  REFER: Anduril 2 Manual:

  http://toykeeper.net/torches/fsm/anduril2/anduril-manual.txt

The uses are quite endless, and the vocabulary is essentially
yours to create.

How to highlight FIVERs
=======================

This plugin automatically highlights any FIVER word (a five-letter
uppercase word) that's followed by a colon or a forward slash.

E.g., just type "FIVER" followed by a colon, and it'll be highlighted::

  FIVER: The "FIVER" before the colon is highlighted.

Additionally, any FIVER followed by a forward slash is also highlighted
(because that's how the author dates their notes), e.g.::

  TRYME/2022-09-24 18:35: Try cooking Jackfruit Pulled "Pork".

Using FIVERs to mark tasks completed
====================================

When you've completed a task, you can change the FIVER to indicate that
the task is done, or you can prefix it with a completion FIVER.

For instance, after completing a "FIXME" task, rename it "FIXED", e.g.::

  FIXED: Update the README

This plugin will specially highlight these FIVERs using a strikethrough.

You can also prefix the previous FIVER with the completion FIVER, and
the old FIVER will no longer be highlighted, e.g.::

  FIXED/FIXME: Send it

will show "FIXED" in strikethrough and will show "FIXME" unadorned.

Which FIVER words signify completion
====================================

The following five-letter uppercase words will be highlighted with a
strikethrough.

For example, when a *FIXME* is *FIXED*, you can rename *FIXME* to *FIXED*.
Then, instead of yellow and bold, the FIVER is now highlighted purplish
and stricken-through.

Alternatively (and this is what the author prefers), you can prefix
the old FIVER, e.g.::

  FIXED/FIXME: Some task

Then the "FIXED" will be written in purple strikethrough, the "FIXME"
will no longer be highlighted, and you can easily scan the document for
active FIVERs (which are highlighted in yellow or yellowish-green bold
text), while preserving the original FIVER type.

This following FIVERs are highlighted in purple with strikethrough:

- ``FIXED``

  - For when you complete a "FIXME", or any other actionable FIVER.

- ``ANNUL``

  - For any canceled task, e.g., a *FIXME* that you *WONTFIX*.

- ``NOTED``

  - For non-actionable notes you want to archive, in a sense.
    (The author uses "NOTED" so that when I'm skimming notes,
    I can ignore any block of text marked "NOTED" (or marked
    with any other FIVER that's printed in strikethrough).)

- ``COPYD``

  - For any note you want to mark as duplicate, or if you copy
    a note somewhere else but want to leave a breadcrumb. (The
    author uses this in at least two use cases. First, I often
    find duplicate backlog items, so I'll mark one "COPYD".
    Second, if I have a long block of notes with multiple FIVERs
    and some are completed but some are not, I might extract the
    uncompleted tasks by copying them elsewhere, and then I'll
    mark the original notes "COPYD". This way I can leave the
    original note intact, as a point of reference, and for context.)

- ``ORDRD``

  - For something you've purchased. (When the author is thinking about
    buying something, I'll leave myself an "ORDER" note. If I
    purchase said thing later, I'll mark it "ORDRD", e.g.,
    ``ORDRD/ORDER/2024-10-20: Some thing``).

- ``SNIPD``

  - For text you moved from elsewhere, when you want to leave a back-ref.
    (E.g., ``SNIPD/2024-10-20: Moved from ~/some/file: ...``.)

- ``RECVD``

  - Used to complement "SHIPD" and used alongside "ORDER" and
    "ORDRD", for tracking shipments. E.g., you might have a completed
    note such as ``RECVD/SHIPD: UPS tracking number: XXXX``.

- ``SPOKE``

  - Awkwardly-named final state for a "SPIKE" backlog item (I know
    it's a silly name, but can you think of a better name for a
    finished "SPIKE" backlog item? (other than FIXED, of course!).)

- ``WAITD``

  - The final state for "AWAIT", which are actionables that are delayed
    until a later date or some external trigger. (E.g.,
    ``WAITD/AWAIT: Expect the president to call you back by Friday.``)

(Note the previous list is ordered by usage count in the author's notes.
For instance, I have 8,230 notes marked "FIXED", 2,744 notes marked
"ANNUL", but only 146 notes marked "WAITD".)

Always-highlighted FIVERs
=========================

Some FIVERs are always highlighted when used in a document, regardless
of being followed by a forward slash or a colon. The list is limited to
the following two FIVERs::

  MAYBE

  AWAIT

(This list used to include about 20 FIVERs, but this feature proved not
to be that useful, and it can be distracting when overused. So the list
has been pared to just those FIVERs that the author uses standalone. See
inline comments for a discussion (especially re: this feature is not
*that* useful).)

Suggesting FIVERs
=================

The author is more than willing to entertain new FIVER words, or changes
to the dictionary setup by this plugin. But note that how anyone chooses
to use this plugin is probably very specific to their own tastes. So you
might just want to fork the plugin and tweak the dictionary to your liking.
(Or we could move the predefined FIVERs to ``g:`` variables that you could
customize from your own Vim script; feel free to PR such a change if you
want.)

In any case, the author would love to hear about how you use and how you've
personalized this plugin! (Indeed, if anyone likes this plugin, please
give the project a star, I'd love to know that other devs enjoy it as
much as I do. =)

Tips: Related supercharged reST plugins
=======================================

Consider these complementary reST highlights plugins that pair
well with this plugin to help you take notes in Vim:

- Advanced reST document section folder.

  `https://github.com/landonb/vim-reSTfold#🙏
  <https://github.com/landonb/vim-reSTfold#🙏>`__

  Supercharge your notetaking and recordkeeping!

  Add section folding to your reST notes so you can,
  e.g., collapse a 10,000-line-long TODO file and get a
  nice high-level view of all the things you wanna do.

- Additional syntax highlight rules.

  `https://github.com/landonb/vim-reST-highdefs#🎨
  <https://github.com/landonb/vim-reST-highdefs#🎨>`__

  Colorize email addresses and host names, and disable spell checking
  on emails, hosts, and acronyms (all-capital words).

- Simple horizontal rule highlight.

  `https://github.com/landonb/vim-reST-highline#➖
  <https://github.com/landonb/vim-reST-highline#➖>`__

  Repeat the same punctuation character 8 or more times on
  a line, and it'll be highlighted.

  Useful for adding a visual separation to your notes without
  using a reST section heading.

Installation
============

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/start
    cd ~/.vim/pack/landonb/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/opt
    cd ~/.vim/pack/landonb/opt

Clone the project to the desired path:

.. code-block:: bash

    git clone https://github.com/landonb/vim-reST-highfive.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

   :packadd! vim-reST-highfive

Just once, tell Vim to build the online help:

.. code-block:: vim

   :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

   :help vim-reST-highfive

License
=======

Copyright (c) Landon Bouma. This work is distributed
wholly under CC0 and dedicated to the Public Domain.

https://creativecommons.org/publicdomain/zero/1.0/

