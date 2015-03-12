option: -r
==========

setup
*****

::

  $ . $TESTDIR/setup

  $ init-repos
  $ cd checkout

  $ touch .gitignore
  $ tit commit -m 'init'

  $ print -f '%s\n' fancy whatever > README
  $ tit commit -m 'README'
  $ tit push up HEAD:master

  $ tit checkout -b hack

  $ echo more fancy > README
  $ tit commit -m 'README fancier'

  $ echo '.*.sw?' > .gitignore
  $ tit commit -m 'ignore vim swapfiles'

  $ tit push rn HEAD:feature

  $ export GIT_PIMP_DRYRUN='git%mailz%*|review-files%*'

  $ tit config --global pimp.editor :

  $ tit config --get pimp.to
  git-pimp-tests-sink@example.org
  $ tit config --get pimp.cc
  [1]

test
****

::

  $ tit status --porcelain

  $ tit pimp -r 2 -n up/master rn/feature
  $ for p in *.patch; do print "==== $p ===="; grep -E '^(Subject):' $p; done
  ==== v2-0000-cover-letter.patch ====
  Subject: [PATCH v2 0/2] *** SUBJECT HERE ***
  ==== v2-0001-README-fancier.patch ====
  Subject: [PATCH v2 1/2] README fancier
  ==== v2-0002-ignore-vim-swapfiles.patch ====
  Subject: [PATCH v2 2/2] ignore vim swapfiles

