#Author: Fabian Böhm

#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: setup_exercise.sh <git-url>"
    exit 1
fi

url="$1"
url_base=https://artemis.tum.de/git/
user_artemis=$(echo "$url" | grep -oP 'https://\K[^@]+')
url_base="https://${user_artemis}@artemis.tum.de/git/"

name_file_original=$(basename "$url")

#clean up filename
name_file_base="${name_file_original%-exercise.git}"
name_file_base="${name_file_base%-solution.git}"
name_file_base="${name_file_base%-tests.git}"
name_file_base="${name_file_base%old}"

# Extract Exercise name like h01e01 (case insensitive)
name_exercise_new=$(echo "$name_file_base" | grep -oiE '[a-zA-Z][0-9]{2}[e|E][0-9]{2}' || true)
name_exercise_old="${name_exercise_new}old"

if [ -z "$name_exercise_new" ]; then
    echo "Error: could not extract exercise number (expected hXXeYY)."
    exit 1
fi

name_course="${name_file_base%${name_exercise_new}}"

echo 
echo Importing exercise from Artemis:
echo Course: $name_course
echo Exercise: $name_exercise_new
echo Username: $user_artemis

# --- Create folders ---
echo 
echo "-----"
echo Creating Folders
mkdir -p "$name_exercise_new/old"
mkdir -p "$name_exercise_new"

# --- Cloning New Repositories ---
echo 
echo "-----"
echo "Cloning Repositories"
repo_exercise_new="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')/${name_file_base}-exercise.git"
repo_solution_new="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')/${name_file_base}-solution.git"
repo_test_new="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')/${name_file_base}-tests.git"

cd $name_exercise_new

git clone "$repo_exercise_new"
git clone "$repo_solution_new"
git clone "$repo_test_new"

# --- Cloning Old Repositories ---

repo_exercise_old="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')OLD/${name_file_base}old-exercise.git"
repo_solution_old="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')OLD/${name_file_base}old-solution.git"
repo_test_old="${url_base}$(echo "$name_file_base" | tr '[:lower:]' '[:upper:]')OLD/${name_file_base}old-tests.git"

cd old
git clone "$repo_exercise_old"
git clone "$repo_solution_old"
git clone "$repo_test_old"
cd ..

# --- Updating Gradle wrappers ---
echo 
echo "-----"
echo "Updating Gradle wrappers"

while IFS= read -r dir; do
    if [ -f "$dir/gradlew" ]; then
        (
            cd "$dir"
            chmod +x gradlew
            ./gradlew wrapper --gradle-version 9.0.0
            ./gradlew wrapper --gradle-version 9.0.0
        )
    fi
done < <(find "." -type d ! -path "*/old/*")

# --- Copy old exercise ---
echo 
echo "-----"
echo "Copy old exercise"

echo "1. Copy exercise"
rsync -a --delete "old/${name_file_base}old-exercise/src/de/tum/cit/ase"/ "${name_file_base}-exercise/src/de/tum/cit/aet"/
echo "2. Copy solution"
rsync -a --delete "old/${name_file_base}old-solution/src/de/tum/cit/ase"/ "${name_file_base}-solution/src/de/tum/cit/aet"/
echo "3. Copy tests"
rsync -a --delete "old/${name_file_base}old-tests/test/de/tum/cit/ase"/ "${name_file_base}-tests/test/de/tum/cit/aet"/

echo 
echo "-----"
echo "Done"
exit
