option: -o, --output
====================

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
  $ export GIT_PIMP_CHATTY='git%format-patch%*|git%mantle%*|git%mailz%*|mv%*|rm%*|rmdir%*'

  $ tit config --get pimp.output
  [1]

test
****

::

  $ tit status --porcelain

  $ tit pimp -n up/master rn/feature
  git format-patch --output-directory=. --cover-letter --to=git-pimp-tests-sink@example.org up/master..rn/feature
  git mantle --output ./.git-mantle up/master rn/feature
  mv ./.0000-cover-letter.patch.tmp ./0000-cover-letter.patch
  rm -f ./.0000-cover-letter.patch.tmp ./.git-mantle ./.git-pimp

  $ tit pimp -o out1 -n up/master rn/feature
  git format-patch --output-directory=out1 --cover-letter --to=git-pimp-tests-sink@example.org up/master..rn/feature
  git mantle --output out1/.git-mantle up/master rn/feature
  mv out1/.0000-cover-letter.patch.tmp out1/0000-cover-letter.patch
  rm -f out1/.0000-cover-letter.patch.tmp out1/.git-mantle out1/.git-pimp

  $ tit pimp --output out2 -n up/master rn/feature
  git format-patch --output-directory=out2 --cover-letter --to=git-pimp-tests-sink@example.org up/master..rn/feature
  git mantle --output out2/.git-mantle up/master rn/feature
  mv out2/.0000-cover-letter.patch.tmp out2/0000-cover-letter.patch
  rm -f out2/.0000-cover-letter.patch.tmp out2/.git-mantle out2/.git-pimp

