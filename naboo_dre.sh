#!/bin/bash

set -u

if [ -z ${SCOREBOARD_ROOT+defined} ]
then
  this_script="${BASH_SOURCE[0]}"
  export SCOREBOARD_ROOT=$( cd -- "$( dirname -- "$this_script" )" &> /dev/null && pwd )
  cd "$SCOREBOARD_ROOT"
  echo "Updating scoreboard at $SCOREBOARD_ROOT..."
  git pull || exit 1
  # Run this script in a new shell to make sure we're running the latest
  # script.
  exec "$this_script"
else
  echo "Updated scoreboard!"
fi

OUTPUT="${OUTPUT:-/export/web/www/scoreboard}"
echo "Output will be $OUTPUT"
if ! [ -d "$OUTPUT" ]
then
  echo "\$OUTPUT directory ($OUTPUT) does not exist"
  exit 1
fi

AUTOBUILD_ROOT="${AUTOBUILD_ROOT:-$HOME/autobuild}"
cd "$AUTOBUILD_ROOT"
echo "Updating autobuild at $AUTOBUILD_ROOT..."
git pull || exit 1

exit_status=0
groups=(
  ace
  ace6
  tao
  tao2
)

# Generate the index page!
/usr/bin/perl ./scoreboard.pl -v -d "$OUTPUT" -i "$SCOREBOARD_ROOT/index.xml"
if [ $? -gt 0 ]
then
  echo "STATUS ERROR: scoreboard.pl for index page returned $?" 1>&2
  exit_status=1
fi

xml_files=()
for group in ${groups[@]}
do
  echo "Generating pages for $group..."
  xml_file="$SCOREBOARD_ROOT/$group.xml"
  xml_files+=("$xml_file")

  # Generate the normal pages for this group
  /usr/bin/perl ./scoreboard.pl -b -d "$OUTPUT" -f "$xml_file" -o "$group.html" -v
  if [ $? -gt 0 ]
  then
    echo "STATUS ERROR: scoreboard.pl for $group pages returned $?" 1>&2
    exit_status=1
  fi

  # Generate the text matrix pages for this group
  ./matrix.py "${OUTPUT}"
  if [ $? -gt 0 ]
  then
    echo "STATUS ERROR: matrix.py for $group returned $?" 1>&2
    exit_status=1
  fi

  # Remove the builds.json for this group
  rm "$OUTPUT/builds.json"
done

# Generate integrated pages!
echo "Generating integrated pages..."
function join_by {
  local d=${1-} f=${2-}
  if shift 2
  then
    printf %s "$f" "${@/#/$d}"
  fi
}
/usr/bin/perl ./scoreboard.pl -b -d "$OUTPUT" -z -j "$(join_by , ${xml_files[@]})"
if [ $? -gt 0 ]
then
  echo "STATUS ERROR: scoreboard.pl for integrated pages returned $?" 1>&2
  exit_status=1
fi

exit $exit_status
