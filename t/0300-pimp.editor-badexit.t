cover-letter editor failure
===========================

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

  $ tit config pimp.editor false
  $ export GIT_PIMP_CHATTY='git%mailz%*|review-files%*|rm%*'
  $ export GIT_PIMP_DRYRUN='git%mailz%*'

test
****

::

  $ tit status --porcelain
  $ tit pimp -n up/master rn/feature
  review-files false ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  rm -f ./.0000-cover-letter.patch.tmp ./.git-mantle ./.git-pimp
  [1]
  $ tit status --porcelain
  ?? 0000-cover-letter.patch
  ?? 0001-README-fancier.patch
  ?? 0002-ignore-vim-swapfiles.patch

  $ tit pimp up/master rn/feature
  review-files false ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  rm -f ./.0000-cover-letter.patch.tmp ./.git-mantle ./.git-pimp
  [1]
  $ tit status --porcelain
  ?? 0000-cover-letter.patch
  ?? 0001-README-fancier.patch
  ?? 0002-ignore-vim-swapfiles.patch
