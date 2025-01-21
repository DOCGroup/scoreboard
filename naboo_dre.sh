#!/bin/bash

set -ue

OUTPUT="${OUTPUT:-/export/web/www/scoreboard}"
if ! [ -d "$OUTPUT" ]
then
    echo "\$OUTPUT directory ($OUTPUT) does not exist"
    exit 1
fi

SCOREBOARD_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCOREBOARD_ROOT"
git pull

AUTOBUILD_ROOT="${AUTOBUILD_ROOT:-$HOME/autobuild}"
cd "$AUTOBUILD_ROOT"
git pull

groups=(
  ace
  ace6
  tao
  tao2
)

# Generate the index page!
/usr/bin/perl ./scoreboard.pl -v -d "$OUTPUT" -i "$SCOREBOARD_ROOT/index.xml"

xml_files=()
for group in ${groups[@]}
do
  echo "Generating pages for $group..."
  xml_file="$SCOREBOARD_ROOT/$group.xml"
  xml_files+=("$xml_file")

  # Generate the normal pages for this group
  /usr/bin/perl ./scoreboard.pl -b -d "$OUTPUT" -f "$xml_file" -o "$group.html" -v

  # Generate the text matrix pages for this group
  ./matrix.py "${OUTPUT}"

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
