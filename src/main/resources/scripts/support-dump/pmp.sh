#!/usr/bin/env bash
# This program is part of Aspersa (http://code.google.com/p/aspersa/)
# To use with MarkLogic: sudo ./pmp -b MarkLogic
# ########################################################################
# This script aggregates GDB stack traces for a selected program.  By default it
# does mysqld.
#
# Author: Baron Schwartz, based on a script by Domas Mituzas at
# poormansprofiler.org
# ########################################################################

# Print a usage message and exit.
usage() {
   if [ "${OPT_ERR}" ]; then
      echo "${OPT_ERR}"
   fi
   echo "Usage: $0 -p <pid> -b <binary> -i <iterations> -s <sleeptime> -l <maxlen> -k <keepfile> [FILE]"
   echo "   $0 does two things: 1) get a GDB backtrace 2) aggregate it."
   echo "   If you specify -p, then -b is ignored.  Otherwise that binary is traced."
   echo "   If you specify -l, then only the topmost N functions are aggregated."
   echo "   If you specify -k, then the backtraces are saved in that file."
   echo "   If you specify a FILE, then step 1) above is not performed."
   exit 1
}

# Actually does the aggregation.  The arguments are the max number of functions
# to aggregate, and the files to read.  If maxlen=0, it means infinity.  We have
# to pass the maxlen argument into this function to make maxlen testable.
aggregate_stacktrace() {
   maxlen="$1";
   shift;
   cat > /tmp/aspersa.awk <<EOF
      BEGIN {
         s = "";
      }
      /^Thread/ {
         if ( s != "" ) {
            print s;
         }
         s = "";
         c = 0;
      }
      /^\#/ {
         if ( \$2 ~ /0x/ ) {
            if ( \$4 ~/void|const/ ) {
               targ = \$5;
            }
            else {
               targ = \$4;
            }
            if ( targ ~ /[<\\(]/ ) {
               targ = substr(\$0, index(\$0, " in ") + 4);
               if ( targ ~ / from / ) {
                  targ = substr(targ, 1, index(targ, " from ") - 1);
               }
               if ( targ ~ / at / ) {
                  targ = substr(targ, 1, index(targ, " at ") - 1);
               }
               # Shorten C++ templates, e.g. in t/samples/stacktrace-004.txt
               while ( targ ~ />::/ ) {
                  if ( 0 == gsub(/<[^<>]*>/, "", targ) ) {
                     break;
                  }
               }
               # Further shorten argument lists.
               while ( targ ~ /\\(/ ) {
                  if ( 0 == gsub(/\\([^()]*\\)/, "", targ) ) {
                     break;
                  }
               }
               # Remove void and const decorators.
               gsub(/ ?(void|const) ?/, "", targ);
               gsub(/ /, "", targ);
            }
            else if ( targ ~ /\\?\\?/ && \$2 ~ /[1-9]/ ) {
               # Substitute ?? by the name of the library.
               targ = \$NF;
               while ( targ ~ /\\// ) {
                  targ = substr(targ, index(targ, "/") + 1);
               }
               targ = substr(targ, 1, index(targ, ".") - 1);
               targ = targ "::??";
            }
         }
         else {
            targ = \$2;
         }
         # get rid of long symbol names such as 'pthread_cond_wait@@GLIBC_2.3.2'
         if ( targ ~ /@@/ ) {
            fname = substr(targ, 1, index(targ, "@@") - 1);
         }
         else {
            fname = targ;
         }
         if ( ${maxlen:-0} == 0 || c < ${maxlen:-0} ) {
            if (s != "" ) {
               s = s "," fname;
            }
            else {
               s = fname;
            }
         }
         c++;
      }
      END {
         print s
      }
EOF
   awk -f /tmp/aspersa.awk $* | sort | uniq -c | sort -r -n -k 1,1
   rm -f /tmp/aspersa
}

# The main program to run.
main() {
   rm -f /tmp/aspersa

   # Get command-line options.
   for o; do
      case "${o}" in
         --)
            break;
            ;;
         -p)
            shift; pid="${1}"; shift;
            ;;
         -b)
            shift; binary="${1}"; shift;
            ;;
         -i)
            shift; iterations="${1}"; shift;
            ;;
         -s)
            shift; sleeptime="${1}"; shift;
            ;;
         -l)
            shift; maxlen="${1}"; shift;
            ;;
         -k)
            shift; keepfile="${1}"; shift;
            ;;
         -*)
            OPT_ERR="Unknown option '${o}'."
               usage 1
            ;;
      esac
   done
   if [ "${OPT_ERR}" ]; then
      usage
   fi

   if [ -z "${1}" ]; then
      # There's no file to analyze, so we'll make one.
      iterations=${iterations:-1}
      sleeptime=${sleeptime:-0}
      binary=${binary:-mysqld}
      if [ -z "${pid}" ]; then
         pid=$(pidof -s "${binary}" 2>/dev/null);
         if [ -z "${pid}" ]; then
            pid=$(ps -eaf | grep "${binary}" | grep -v grep | awk '{print $2}' | head -n1);
         fi
      fi
      date;
      for x in $(seq 1 $iterations); do
         gdb -ex "set pagination 0" -ex "thread apply all bt" -batch -p $pid >> "${keepfile:-/tmp/aspersa}"
         sleep $sleeptime
      done
   fi

   if [ $# -eq 0 ]; then
      aggregate_stacktrace "${maxlen:-0}" "${keepfile:-/tmp/aspersa}"
      rm -f /tmp/aspersa
   else
      aggregate_stacktrace "${maxlen:-0}" $*
   fi
}

# Execute the program if it was not included from another file.  This makes it
# possible to include without executing, and thus test.
if [ $(basename "$0") = "pmp" ] || [ $(basename "$0") = "bash" -a "$_" = "$0" ]; then
    main $*
fi
