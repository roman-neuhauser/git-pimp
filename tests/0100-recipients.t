recipient handling
==================

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

  $ rm $HOME/.gitconfig
  $ git config user.email git-pimp-tests@example.org
  $ git config user.name "git-pimp test suite"

  $ tit config --get pimp.editor
  [1]
  $ tit config --get pimp.to
  [1]
  $ tit config --get pimp.cc
  [1]

test
****

::

  $ tit status --porcelain

  $ tit pimp up/master rn/feature
  git-pimp: error: no primary recipients (pimp.to)
  [1]
  $ tit status --porcelain

  $ tit pimp -n --cc git-pimp-tests-sink@example.org up/master rn/feature
  git-pimp: error: no primary recipients (pimp.to)
  [1]
  $ tit status --porcelain

  $ tit config pimp.cc git-pimp-tests-cc@example.org
  $ tit pimp up/master rn/feature
  git-pimp: error: no primary recipients (pimp.to)
  [1]
  $ tit status --porcelain

  $ tit pimp -n --to git-pimp-tests-to@example.org up/master rn/feature
  $ for p in *.patch; do print "==== $p ===="; grep -E '^(Cc|To):' $p; done
  ==== 0000-cover-letter.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org
  ==== 0001-README-fancier.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org
  ==== 0002-ignore-vim-swapfiles.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org

  $ rm .git/config
  $ tit config --get pimp.to
  [1]
  $ tit config --get pimp.cc
  [1]

  $ tit config pimp.to git-pimp-tests-to@example.org
  $ tit pimp -n --cc git-pimp-tests-cc@example.org up/master rn/feature
  $ for p in *.patch; do print "==== $p ===="; grep -E '^(Cc|To):' $p; done
  ==== 0000-cover-letter.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org
  ==== 0001-README-fancier.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org
  ==== 0002-ignore-vim-swapfiles.patch ====
  To: git-pimp-tests-to@example.org
  Cc: git-pimp-tests-cc@example.org

