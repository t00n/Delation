#!/bin/bash

EXTENSION=$1
COMMENT_SIGN=$2
REPERTORY=$3
# echo $#
# echo $@

declare -x names=()
declare -x -A count_lines
declare -x -A count_comments

function format()
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

function computeCommentRatio()
{
	count=$1
	count_comment=$2
	echo $(bc <<< "scale=3;$count_comment/$count")
}

function compute_all()
{
	# count lines for this person and lines of comments
	for file in `find . -name "*.$EXTENSION"`; do
		for name in "${names[@]}"; do
			real_name=$(sed s/_/\ /g <<< $name)
			count_lines[$name]=$((${count_lines[$name]} + `git blame $file | grep -c "$real_name"`))
			count_comments[$name]=$((${count_comments[$name]} + `git blame $file | grep "$COMMENT_SIGN" | grep -c "$real_name"`))
		done
	done
}

function display_all()
{
	total_lines=0
	total_comments=0
	for name in "${names[@]}"; do
		# compute number of comments on number of lines ratio
		ratio=0
		if [ ${count_lines[$name]} -ne 0 ]; then
			ratio=$(computeCommentRatio ${count_lines[$name]} ${count_comments[$name]})
		fi
		# align columns and display
		count=$(format ${count_lines[$name]} 6)
		count_comment=$(format ${count_comments[$name]} 12)
		name=$(format $name 25)
		ratio=$(format $ratio 5)
		echo "$name | $count | $count_comment | $ratio"
		total_lines=$((total_lines + count))
		total_comments=$((total_comments + count_comment))
	done
	echo -e $(format "Total" 25) "|" $(format $total_lines 6) "|" $(format $total_comments 12) "|" $(format $(computeCommentRatio $total_lines $total_comments) 5) 
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
		name=($(sed s/\ /_/g <<< $name))
		names+=($name)
		count_lines[$name]=0
		count_comments[$name]=0
	done
	compute_all
	display_all
}

main

