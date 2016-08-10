#!/bin/bash
echo v0.5 20160808 / lukbec
echo script to move and maving files to directory by date create

set -e

#TO SET
PUBLISHER="XY";
DIR_IN="/dbstorage/"$PUBLISHER"/LOGS_REPL/";
DIR_OUT="/dbstorage/"$PUBLISHER"/BACKUP_LOGS_REPL/";
FILE_EXT="*.dbr";
HOW_MANY_DAY="2";

echo
echo 'DIR_IN=' $DIR_IN;
echo 'DIR_OUT=' $DIR_OUT;
echo 'FILE_EXT=' $FILE_EXT;
echo 'HOW_MANY_DAY=' $HOW_MANY_DAY;
echo
read -p "If this correct? [y/n]" ANSWER
if [ "$ANSWER" != "y" ]
then
echo "Check variables and try again."
exit
fi

mkdir -p $DIR_OUT
cd $DIR_OUT;

if test $(find $DIR_IN -maxdepth 1 -iname $FILE_EXT -type f -mtime +$HOW_MANY_DAY | wc -l) -gt 0
then
find $DIR_IN -maxdepth 1 -iname $FILE_EXT -type f -mtime +$HOW_MANY_DAY -exec mv {} $DIR_OUT \; -exec echo 'Moving' {} 'to' $DIR_OUT \;

# transfer files to directories by date
for FILE in $(eval echo $FILE_EXT)
do
DIRFILE=`stat -c %y ${FILE} | cut -c 1-7 | sed "s/-//g"`
if test ! -d $DIRFILE; then
echo 'Create directory' $DIRFILE 'in' $DIR_OUT;
mkdir $DIRFILE;
fi
echo 'Moving' $FILE 'to' $DIRFILE 'in' $DIR_OUT;
mv $FILE $DIRFILE;
done

fi

#archiving directory
for DIR in *
do
# incremental archiving and deleting directories packed
if test -d $DIR; then
echo 'Archiving' $DIR 'in' $DIR_OUT;
( zip -r -q -u -9 $DIR.zip $DIR && rm -rf $DIR ) || { exit 1;};
fi
done
echo 'Done.'
