#!/bin/bash

EXTENSION=$1
COMMENT_SIGN=$2
REPERTORY=$3
TOTAL=0
TOTAL_COMMENT=0
function display()
{
	name=$1
	count=0
	count_comment=0
	for file in `find . -name "*.$EXTENSION"`; do
		count=$((count + `git blame $file | grep -c "$name"`))
		count_comment=$((count_comment + `git blame $file | grep "$COMMENT_SIGN" | grep -c "$name"`))
	done
	echo "$name : $count " # : $count_comment"
	if [ $count -ne 0 ]; then
		echo "scale=3;$count_comment/$count" | bc
	else
		echo 0
	fi
	TOTAL=$((TOTAL + count))
	TOTAL_COMMENT=$((TOTAL_COMMENT + count_comment))
}

cd $REPERTORY

echo -e "\033[31mDISCLAIMER : \033[0mCes chiffres sont purement informatifs."
echo "             Le nombre de lignes peut varier incroyablement en fonction de refactoring divers."
echo -e "\033[32mCommits\033[0m : `git log | grep "Author:" | wc -l`"
echo -e "\033[32mCommits par personne : \033[0m"
git shortlog -sn | cat

echo "Calcul du nombre de lignes par personne..."

IFS=$'\n'
for name in `git shortlog -s | cut -f2`; do
	display $name
done 

echo $TOTAL
echo $TOTAL_COMMENT
echo "scale=3;$TOTAL_COMMENT/$TOTAL" | bc
