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
  $ export GIT_PIMP_CHATTY='review-files%*|git%mailz%*'
  $ export GIT_PIMP_DRYRUN='review-files%*|git%mailz%*'

test
****

::

  $ tit status --porcelain
  $ tit pimp -n up/master rn/feature
  review-files : ./0000-cover-letter.patch ./0001-README-fancier.patch ./0002-ignore-vim-swapfiles.patch
  $ tit status --porcelain
  ?? 0000-cover-letter.patch
  ?? 0001-README-fancier.patch
  ?? 0002-ignore-vim-swapfiles.patch

  $ for f in 000?-*.patch; do
  >   print -f '==> %s <==\n' $f
  >   sed '/^$/q' $f
  > done
  ==> 0000-cover-letter.patch <==
  From 9536f59c85fb42b7fa26e3169f5000ba4a30d61b Mon Sep 17 00:00:00 2001
  Message-Id: <cover.*.git.git-pimp-tests@example.org> (glob)
  From: git-pimp test suite <git-pimp-tests@example.org>
  Date: * (glob)
  Subject: [PATCH 0/2] *** SUBJECT HERE ***
  To: git-pimp-tests-sink@example.org
  
  ==> 0001-README-fancier.patch <==
  From 093ac4b5e67bde2ccaf8a48201c460b77f9d6a8b Mon Sep 17 00:00:00 2001
  Message-Id: <093ac4b5e67bde2ccaf8a48201c460b77f9d6a8b.*.git.git-pimp-tests@example.org> (glob)
  In-Reply-To: <cover.*.git.git-pimp-tests@example.org> (glob)
  References: <cover.*.git.git-pimp-tests@example.org> (glob)
  From: git-pimp test suite <git-pimp-tests@example.org>
  Date: Wed, 20 Aug 2014 20:57:57 +0000
  Subject: [PATCH 1/2] README fancier
  To: git-pimp-tests-sink@example.org
  
  ==> 0002-ignore-vim-swapfiles.patch <==
  From 9536f59c85fb42b7fa26e3169f5000ba4a30d61b Mon Sep 17 00:00:00 2001
  Message-Id: <9536f59c85fb42b7fa26e3169f5000ba4a30d61b.*.git.git-pimp-tests@example.org> (glob)
  In-Reply-To: <cover.*.git.git-pimp-tests@example.org> (glob)
  References: <cover.*.git.git-pimp-tests@example.org> (glob)
  From: git-pimp test suite <git-pimp-tests@example.org>
  Date: Wed, 20 Aug 2014 20:57:57 +0000
  Subject: [PATCH 2/2] ignore vim swapfiles
  To: git-pimp-tests-sink@example.org
  

  $ sed '/^-- $/q' 0000-cover-letter.patch
  From 9536f59c85fb42b7fa26e3169f5000ba4a30d61b Mon Sep 17 00:00:00 2001
  Message-Id: <cover.*.git.git-pimp-tests@example.org> (glob)
  From: git-pimp test suite <git-pimp-tests@example.org>
  Date: * (glob)
  Subject: [PATCH 0/2] *** SUBJECT HERE ***
  To: git-pimp-tests-sink@example.org
  
  *** BLURB HERE ***
  
  repo = git@pub.example.org
  head = 9536f59c85fb42b7fa26e3169f5000ba4a30d61b rn/feature
  base = a36dfca583a1ea1b70afebf294fe3e0cd48dfa7e up/master
  
   .gitignore | 1 +
   README     | 3 +--
   2 files changed, 2 insertions(+), 2 deletions(-)
  
  1/2 76a23b86 093ac4b5 README fancier
      162441d0 README
  2/2 87990615 9536f59c ignore vim swapfiles
      32682119 .gitignore
  
  -- 
