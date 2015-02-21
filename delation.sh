#!/bin/bash

EXTENSION=$1
COMMENT_SIGN=$2
REPERTORY=$3
TOTAL=0
TOTAL_COMMENT=0
# echo $#
# echo $@

function adjust_size()
{
	variable=$1
	size=$2
	# difference between actual size and wanted size
	diff=$(($size - ${#variable}))
	# expand size
	while [[ diff -ne 0 ]]; do
		variable=$variable" "
		diff=$((diff-1))
	done
	echo $variable
}

function display_stats()
{
	name=$1
	count=0
	count_comment=0
	# count lines for this person and lines of comments
	for file in `find . -name "*.$EXTENSION"`; do
		count=$((count + `git blame $file | grep -c "$name"`))
		count_comment=$((count_comment + `git blame $file | grep "$COMMENT_SIGN" | grep -c "$name"`))
	done
	# compute number of comments on number of lines ratio
	ratio=0
	if [ $count -ne 0 ]; then
		ratio=$(computeCommentRatio $count $count_comment)
	fi
	# align columns and display
	name=$(adjust_size $name 16)
	count=$(adjust_size $count 6)
	count_comment=$(adjust_size $count_comment 12)
	ratio=$(adjust_size $ratio 5)
	echo "$name | $count | $count_comment | $ratio"
	TOTAL=$((TOTAL + count))
	TOTAL_COMMENT=$((TOTAL_COMMENT + count_comment))
}

function computeCommentRatio()
{
	count=$1
	count_comment=$2
	echo $(bc <<< "scale=3;$count_comment/$count")
}

function main()
{
	cd $REPERTORY

	echo -e "\033[31mDISCLAIMER : \033[0mCes chiffres sont purement informatifs."
	echo "             Le nombre de lignes peut varier incroyablement en fonction de refactoring divers."
	echo -e "\033[32mCommits\033[0m : `git log | grep "Author:" | wc -l`"
	echo -e "\033[32mCommits par personne : \033[0m"
	git shortlog -sn | cat

	echo -e "\n"
	echo -e "\033[32mCalcul du nombre de lignes par personne...\033[0m"
	echo -e "\033[32mNom              | Lignes | Commentaires | Ratio\033[0m"
	IFS=$'\n'
	for name in `git shortlog -s | cut -f2`; do
		display_stats $name
	done 

	echo -e "\n"
	echo -e "\033[32mTotal : \033[0m"
	echo $TOTAL
	echo $TOTAL_COMMENT
	echo $(computeCommentRatio $TOTAL $TOTAL_COMMENT)
}

main

