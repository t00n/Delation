#!/usr/bin/env python3

from argh import *
from git import *
import pandas as pd
import numpy as np

def walk_tree(f, tree):
	res = f(tree)
	for tree in tree.trees:
		walk_tree(f, tree)


def pretty_print(stats):
	print("\033[31mDISCLAIMER : \033[0mCes chiffres sont purement informatifs.")
	print("             Le nombre de lignes peut varier incroyablement en fonction de refactoring divers.")
	print("\033[32mCommits\033[0m : {}".format(stats.commits.sum()))
	print("\033[32mStats par personne : \033[0m")
	stats['ratio'] = (stats.comments / stats.lines).round(2)
	print(stats)


@dispatch_command
@arg('comment')
@arg('directory')
def main(comment, directory):
	repo = Repo(directory)
	stats_by_user = pd.DataFrame(columns=['commits', 'lines', 'comments']).astype(np.int64)
	for commit in repo.commit().iter_items(repo, 'HEAD'):
		if commit.committer.name not in stats_by_user.index:
			stats_by_user.loc[commit.committer.name] = 0
		stats_by_user.loc[commit.committer.name].commits += 1
	tree = repo.heads.master.commit.tree
	def update_stats(tree):
		for blob in tree.blobs:
			for commit, lines in repo.blame('HEAD', blob.path):
				stats_by_user.loc[commit.committer.name].lines += len(lines)
				stats_by_user.loc[commit.committer.name].comments += len([line for line in lines 
																		   if isinstance(line, str) 
																		   and comment in line])
	walk_tree(update_stats, tree)
	pretty_print(stats_by_user)
