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

  FIXME: The 'reST-highfive` pattern should exclude "COVID".

Other uses include documenting interesting information, such as using
"SAVVY" to remind yourself of some trick you learned::

  SAVVY: Search Gmail by date: `after:YYYY/MM/DD before:YYYY/MM/DD`

Or you could use "REFER" to reference information outside your notes
(and maybe you've got the `dubs_web_hatch
<https://github.com/landonb/dubs_web_hatch>`__ plugin installed, so you
could type ``<gW>`` to open the URL under the cursor), e.g.,::

  REFER: Anduril 2 Manual:
    http://toykeeper.net/torches/fsm/anduril2/anduril-manual.txt

The uses are quite endlessly, and the vocabulary is essentially
yours to create.

How to highlight FIVERs
=======================

This plugin automatically highlights any FIVER word (a five-letter
uppercase word) that's followed by a colon or a forward slash.

E.g., just type "FIVER" followed by a colon, and it'll be highlighted::

  FIVER: The "FIVER" before the colon is highlighted.

Additionally, any FIVER followed by a forward slash is also highlighted
(because the author dates their notes), e.g.,::

  TRYME/2022-09-24 18:35: Try cooking Jackfruit Pulled "Pork".

Always-highlighted FIVERs
=========================

Some FIVERs are always highlighted when used in a document, regardless
of being punctuated. The list includes::

  FIVER
  LATER
  MAYBE
  SPIKE
  LEARN
  STUDY
  WATCH
  TRACK
  AWAIT
  ORDER
  CHORE
  AUDIT
  CHECK
  REPLY
  TRYME
  HRMMM
  MEHHH
  BONUS
  OOOPS

Using FIVERs to mark tasks completed
====================================

When you're down with a task, you can change the FIVER to indicate that
the task is completed.

For instance, after completing a "FIXME" task, rename it "FIXED".

This plugin will specially highlight such FIVERs using a strikethrough.

E.g., if you completed the example task listed above, you could rewrite
it::

  FIXED: The 'reST-highfive` pattern match should exclude "COVID".

and this plugin with highlight the "FIXED" word using a strikethrough.

Which FIVER words signify completion
====================================

Almost any five-letter uppercase word that ends in "D" will be highlighted
with a strikethrough.

This includes the following::

  FIXED (when a "FIXME" is complete)
  ORDRD (when you complete an "ORDER" item)
  WAITD (after an "AWAIT" task is complete)

and anything else you can dream up.

Note that some words that are not past tense words are specifically
excluded, including "BUILD", "FOUND", and, of course, "COVID".

This plugin also recognizes a few other special terms, including::

  SPOKE (the completed state for "SPIKE", I know, it's silly)
  ANNUL (how you might cancel any task you choose not to complete)

Suggesting FIVERs
=================

The author is more than willing to entertain new FIVER words, or changes
to the dictionary setup by this plugin. But note that how anyone chooses
to use this plugin is probably very specific to their own tastes. So you
might just want to fork the plugin and tweak the dictionary to your liking.

But the author would still love to hear about how you use and how you've
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

