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
  $ tit branch epo
  $ tit push rn epo

  $ export GIT_PIMP_DRYRUN='git%mailz%*|review-files%*'
  $ export GIT_PIMP_CHATTY='git%format-patch%*|git%mantle%*'

  $ tit config mantle.public rn
  $ tit config --get pimp.output
  [1]

test
****

::

  $ tit status --porcelain

  $ tit pimp -n up/master rn/feature
  git format-patch * up/master..rn/feature (glob)
  git mantle * up/master rn/feature (glob)

  $ tit pimp -n up rn/feature
  git format-patch * up..rn/feature (glob)
  git mantle * up rn/feature (glob)

  $ tit pimp -n ./master rn/feature
  git format-patch * master..rn/feature (glob)
  git mantle * ./master rn/feature (glob)

  $ tit pimp -n ./master ./hack
  git format-patch * master..hack (glob)
  git mantle * ./master ./hack (glob)

  $ tit pimp -n ./master epo
  git format-patch * master..rn/epo (glob)
  git mantle * ./master rn/epo (glob)

