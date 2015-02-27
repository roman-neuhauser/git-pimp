unknown options, wrong operand count
====================================

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
  $ tit push rn HEAD:master

  $ tit checkout -b hack

  $ echo more fancy > README
  $ tit commit -m 'README fancier'

  $ echo '.*.sw?' > .gitignore
  $ tit commit -m 'ignore vim swapfiles'

  $ tit push rn HEAD:feature

test
****

::

  $ tit pimp
  git-pimp: missing operand
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
  git-pimp: Use "git-pimp -h" to see the full option listing.
  [1]

  $ tit pimp -x
  git-pimp: unknown option -x
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
  git-pimp: Use "git-pimp -h" to see the full option listing.
  [1]

  $ tit pimp -x -y
  git-pimp: unknown option -x
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
  git-pimp: Use "git-pimp -h" to see the full option listing.
  [1]

  $ tit pimp --really --unlikely
  git-pimp: unknown option --really
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
  git-pimp: Use "git-pimp -h" to see the full option listing.
  [1]

  $ tit pimp up/master rn/master
  fatal: 'up/master..rn/master' is an empty range
  [1]

  $ tit pimp --unlikely up/master rn/master
  git-pimp: unknown option --unlikely
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
  git-pimp: Use "git-pimp -h" to see the full option listing.
  [1]

  $ tit pimp -h
  git-pimp: Usage: git-pimp {-h|[options] BASE HEAD}
    Options:
      -h                Display this message
