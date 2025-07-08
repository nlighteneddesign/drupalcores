#!/bin/bash

# git pull

echo "Updating Drupal"

if [ ! -d "./drupal" ]; then
  git clone git@git.drupal.org:project/drupal.git
else
  cd ./drupal
  git checkout 11.x
  git fetch
  git rebase
  cd ../
fi

docker run --rm -it -v "$PWD":/data ruby bash -c 'cd /data && ./cores.rb ${drupalVersions[$i]} > ./contributors/main.html'

declare -a drupalVersions=(
  "11.2.2"
  "10.5.1"
  "9.5.11"
  "8.9.20"
  "7.103"
  "6.38"
  "5.23"
  "4.7.11"
  )

declare -a versionDates=(
  "2024-05-04"
  "2022-01-28"
  "2019-10-10"
  "2013-06-24"
  "2008-07-02"
  "2006-11-13"
  "2006-10-31"
  "2005-03-07"
  )

  arraylength=${#drupalVersions[@]}

  # use for loop to read all values and indexes
  for (( i=0; i<${arraylength}; i++ ));
  do
    echo "Version ${drupalVersions[$i]} released ${versionDates[$i]}"
    cd ./drupal
    git switch ${drupalVersions[$i]}-version 2>/dev/null || git switch -c ${drupalVersions[$i]}-version tags/${drupalVersions[$i]}
    cd ..
    docker run --rm -it -v "$PWD":/data ruby bash -c "cd /data && ./cores.rb ${drupalVersions[$i]} --since=${versionDates[$i]} > ./contributors/${drupalVersions[$i]}.html"
  done

git switch 4.3.2-version 2>/dev/null || git switch -c 4.3.2-version tags/4.3.2
docker run --rm -it -v "$PWD":/data ruby bash -c 'cd /data && ./cores.rb > ./contributors/4.3.2.html'
git checkout 11.x

echo "" > ./contributors/index.html
echo "<!DOCTYPE html><html lang="en"><body><ul>" >> ./contributors/index.html
echo "<li><a href='./main.html'>All</a></li>" >> ./contributors/index.html
for (( i=0; i<${arraylength}; i++ ));
  do
    echo "<li><a href='./${drupalVersions[$i]}.html'>${drupalVersions[$i]}</a></li>" >> ./contributors/index.html
  done

echo "<li><a href='./4.3.2.html'>4.3.2 and before</a></li>" >> ./contributors/index.html
echo "</ul></body></html>" >> ./contributors/index.html

sudo chmod -R 777 contributors
sudo chown -R nic:nic contributors
