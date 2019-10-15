#!/bin/bash

if ! command -v git > /dev/null; then echo "I require git but it's not installed.  Aborting."; exit; fi
if [ ! -d .git ]; then echo "Not a git repository (or any of the parent directories)"; exit; fi;

SHORT=f:h:
LONG=folder-name:,hash:

OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
if [ $? != 0 ]; then echo "Failed to parse options...exiting. !!!" >&2 ; exit 1 ; fi

eval set -- "$OPTS"

FOLDER_NAME=../$(date +'%Y-%m-%d_%H-%M-%S')_$(git rev-parse --short HEAD)

while true ; do
  case "$1" in
    -h | --hash )
      HASH=$(echo $2 | tr -d " ")
      if [ $(echo -n $HASH | wc -c) -lt 7 ]; then echo "Hash must greater than six."; exit; fi
      shift 2
      ;;
    -f | --folder-name )
      FOLDER_NAME="$2"
      shift 2
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

if [ ! -z $HASH ] && [ -z "$(git log | grep "$HASH")" ]; then echo "Unknown revision or path not in the working tree."; exit; fi
if [ -z $HASH ]; then HASH="HEAD"; fi

mkdir $FOLDER_NAME
touch $FOLDER_NAME/not-exist-files.txt

for FILE_PATH in $(echo $(git show $HASH --name-only --pretty=""))
do
    if [ -f $FILE_PATH ]; then
        mkdir -p $FOLDER_NAME/$(dirname $FILE_PATH) && cp $FILE_PATH $FOLDER_NAME/$FILE_PATH
        echo $FILE_PATH
    else
        NON_FILE=$(cat $FOLDER_NAME/not-exist-files.txt)
        echo $NON_FILE $'\n' $FILE_PATH > $FOLDER_NAME/not-exist-files.txt
        echo "$FILE_PATH file does not exist."
    fi
done