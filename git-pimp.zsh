#!/usr/bin/zsh -f
# vim: ts=2 sts=2 sw=2 et fdm=marker cms=\ #\ %s

setopt extended_glob
setopt errreturn
setopt no_unset
setopt warn_create_global

function usage # {{{
{
  local self="$_SELF" exit=${1?} fd=1
  shift
  test $exit -ne 0 && fd=2
  {
    if (( exit == 1 )); then
      print -f "%s: option -%c requires an argument\n" -- "$self" "$1"
    elif (( exit == 2 )); then
      print -f "%s: unknown option -%s\n" -- "$self" "$1"
    elif (( exit == 3 )); then
      print -f "%s: missing operand\n" -- "$self"
    fi
    print -f "%s: Usage: %s {-h|[options] BASE HEAD}\n" -- "$self" "$self"
    if (( exit != 0 )); then
      print -f "%s: Use \"%s -h\" to see the full option listing.\n" -- "$self" "$self"
    else
      print -f "  Options:\n"
      print -f "    %-20s  %s\n" -- \
        "-h"              "Display this message" \
        "--cc ADDR"       "Include ADDR in Cc: header" \
        "-n"              "Do not send emails, preserve files" \
        "-o,--output DIR" "Write files to DIR" \
        "--to ADDR"       "Include ADDR in To: header" \

    fi
  } >&$fd
  exit $(( exit != 0 ))
} # }}}

function o # {{{
{
  declare -i dryrun=0
  if [[ $1 == -n ]]; then
    shift
    dryrun=1
  fi
  if (( $+GIT_PIMP_CHATTY )); then
    if [[ "${(@j,%,)@}" == $~GIT_PIMP_CHATTY ]]; then
      print -u $logfd "${(qj: :)@}"
    fi
  fi
  if (( $+GIT_PIMP_DRYRUN )); then
    if [[ "${(@j,%,)@}" == $~GIT_PIMP_DRYRUN ]]; then
      dryrun=1
    fi
  fi
  if (( dryrun )); then
    return 0
  fi
  "$@"
} # }}}

function redir # {{{
{
  local -i o0=0 o1=1 o2=2
  local optname OPTARG OPTIND
  while getopts 0:1:2: optname; do
    case $optname in
    0) exec {o0}<$OPTARG ;;
    1) exec {o1}>$OPTARG ;;
    2) exec {o2}>$OPTARG ;;
    esac
  done; shift $((OPTIND - 1))
  o "$@" <&${o0} 1>&${o1} 2>&${o2}
} # }}}

function complain # {{{
{
  local -r ex=$1 fmt=$2; shift 2
  print -u 2 -f "%s: error: " ${_SELF##*/}
  print -u 2 -f "$fmt\n" "$@"
  [[ $ex != - ]] && exit $ex
} # }}}

function fixup-cover # {{{
{
  local mantle=${1:?}; shift

  sed -ne "
    # print headers unmolested
    0,/^$/ {
      bp
    }
    # replace stuff between 'BLURB HERE' and the signature
    # with git-mantle output
    /^... BLURB HERE ...$/,/^-- $/ {
      /^... BLURB HERE ...$/ {
        p
        a\

        r $mantle
        a\

        b
      }
      /^-- $/ {
        bp
      }
      d
    }
    :p
    p
  " "$@"
} # }}}

function review-files # {{{
# this exists to make $cfg_editor calls easier
# to debug with GIT_PIMP_CHATTY / GIT_PIMP_DRYRUN
{
  "$@"
} # }}}

function finalize-filenames # {{{
{
  local pfx=$1 tmp=$2 series=$3
  local p
  while read p; do
    declare d=${p:h}/$pfx${p:t:r}.patch
    mv $p $d
    print $d
  done <$tmp >$series
  rm $tmp
} # }}}

function main # {{{
{
  declare cfg_output="$(git config --get pimp.output || print .)"
  declare cfg_subtag="$(git config --get pimp.subjecttag || :)"
  declare cfg_to="$(git config --get pimp.to || :)"
  declare cfg_cc="$(git config --get pimp.cc || :)"
  declare cfg_editor="${$(git config --get pimp.editor):-${VISUAL:-"${EDITOR:-}"}}"
  declare cfg_nomail=0
  declare cfg_reroll

  # argv processing {{{
  declare optname OPTIND OPTARG
  while (( $# )); do
    case $1 in
    --cc=*) cfg_cc=${1#--cc=}; shift; ;;
    --cc)   cfg_cc=$2; shift 2; ;;

    --output=*) cfg_output=${1#--output=}; shift; ;;
    --output) cfg_output=$2; shift 2; ;;

    --to=*) cfg_to=${1#--to=}; shift; ;;
    --to)   cfg_to=$2; shift 2; ;;

    --?*)
      usage 2 ${1/#--/-}
    ;;

    -[^-]*)
      OPTIND=1
      while getopts :hno:r: optname; do
        case $optname in
        h) usage 0 ;;
        n) cfg_nomail=1 ;;
        o) cfg_output=${OPTARG:?} ;;
        r) cfg_reroll=${OPTARG:?} ;;
        :) usage 1 $OPTARG ;;
        \?)
          if [[ ${(P)OPTIND} == --* ]]; then
            break
          fi
          usage 2 $OPTARG
        ;;
        esac
      done; shift $((OPTIND - 1))
    ;;

    *)
      break
    ;;
    esac
  done

  if (( $# < 2 )); then
    usage 3
  fi
  # }}}

  declare -r base=$1
  declare head=$2
  [[ $head == */* ]] || head=$(git config --get mantle.public || print .)/$head

  declare -r vr=${cfg_reroll:+v$cfg_reroll}
  declare -r outdir=$cfg_output
  declare -r series=$outdir/.git-pimp
  declare -r mantle=$outdir/.git-mantle
  declare -r cover=$outdir/${vr:+$vr-}0000-cover-letter.patch
  declare -r covertmp=${cover:h}/.${cover:t}.tmp
  declare -i outdir_private=0

  # if $cfg_reroll was given, $cfg_subtag must be set as well
  # so that git-format-patch gets the --subject-prefix option
  [[ -n $cfg_subtag || -z $cfg_reroll ]] || cfg_subtag=PATCH

  [[ -n $cfg_to ]] || complain 1 "no primary recipients (pimp.to)"
  [[ -n $cfg_editor ]] || complain 1 "no text editor (pimp.editor)"
  redir -1 /dev/null o whence $cfg_editor || complain 1 "bad text editor (pimp.editor): ${(q)cfg_editor}"

  [[ -d $outdir ]] || outdir_private=1

  # actual work {{{
  {
    [[ -d $outdir ]] || o mkdir -p $outdir

    o redir -1 $series-git git format-patch \
        --output-directory=$outdir \
        --suffix=.tmp \
        --cover-letter \
        --thread \
        ${cfg_to:+--to=$cfg_to} \
        ${cfg_cc:+--cc=$cfg_cc} \
        ${cfg_subtag:+--subject-prefix="$cfg_subtag${vr:+ $vr}"} \
        ${base#./}..${head#./}

    o finalize-filenames "${vr:+$vr-}" $series-git $series

    o git mantle --output $mantle $base $head
    o redir -0 $cover -1 $covertmp fixup-cover $mantle
    o mv $covertmp $cover

    o review-files $cfg_editor $(<$series)

    (( cfg_nomail )) || o git mailz $(<$series)
    (( cfg_nomail )) || o rm -f $(<$series)
  } always {
    o rm -f $covertmp $mantle $series

    (( 0 == TRY_BLOCK_ERROR )) || return 1

    (( 0 == outdir_private || 1 == cfg_nomail )) || o rmdir $outdir
  }
  # }}}
} # }}}

declare -r _SELF=${0##*/}
declare -i logfd
exec {logfd}>&2

main "$@"
