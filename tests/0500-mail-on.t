happy path, explicit BASE and HEAD
==================================

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

  $ tit config pimp.editor :
  $ export GIT_PIMP_CHATTY='git%mailz%*|review-files%*|rm%*'
  $ export GIT_PIMP_DRYRUN='git%mailz%*|review-files%*'

test
****

::

  $ tit status --porcelain
  $ tit pimp up/master rn/feature
  review-files : ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  git mailz ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  rm -f ./.0000-cover-letter.patch.tmp ./.git-mantle ./.git-pimp
  $ tit status --porcelain
  ?? 0000-cover-letter.patch
  ?? 0001-README-fancier.patch
  ?? 0002-ignore-vim-swapfiles.patch

