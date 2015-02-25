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
  $ export GIT_PIMP_CHATTY='git%mailz%*|mkdir%*|mv%*|rm%*|rmdir%*'
  $ export GIT_PIMP_DRYRUN='git%mailz%*'

test
****

::

  $ tit status --porcelain
  $ tit pimp up/master rn/feature
  mv ./.0000-cover-letter.patch.tmp ./0000-cover-letter.patch
  git mailz ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  rm -f ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  rm -f ./.0000-cover-letter.patch.tmp ./.git-mantle ./.git-pimp
  $ tit status --porcelain

  $ tit pimp -o out1 up/master rn/feature
  mkdir -p out1
  mv out1/.0000-cover-letter.patch.tmp out1/0000-cover-letter.patch
  git mailz out1/0000-cover-letter.patch out1/0001-README-fancier.patch out1/0002-ignore-vim-swapfiles.patch
  rm -f out1/0000-cover-letter.patch out1/0001-README-fancier.patch out1/0002-ignore-vim-swapfiles.patch
  rm -f out1/.0000-cover-letter.patch.tmp out1/.git-mantle out1/.git-pimp
  rmdir out1
  $ tit status --porcelain

  $ tit pimp --output out2 up/master rn/feature
  mkdir -p out2
  mv out2/.0000-cover-letter.patch.tmp out2/0000-cover-letter.patch
  git mailz out2/0000-cover-letter.patch out2/0001-README-fancier.patch out2/0002-ignore-vim-swapfiles.patch
  rm -f out2/0000-cover-letter.patch out2/0001-README-fancier.patch out2/0002-ignore-vim-swapfiles.patch
  rm -f out2/.0000-cover-letter.patch.tmp out2/.git-mantle out2/.git-pimp
  rmdir out2
  $ tit status --porcelain

