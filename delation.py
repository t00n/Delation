#!/usr/bin/env python3

from argh import *
from git import *
import pandas as pd
import numpy as np
from pygments.token import Comment
from pygments.lexers import guess_lexer
from pygments.util import ClassNotFound

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
@arg('directory')
@arg('--branch')
def main(directory, branch='master'):
	repo = Repo(directory)
	stats_by_user = pd.DataFrame(columns=['commits', 'lines', 'comments']).astype(np.int64)
	for commit in repo.commit().iter_items(repo, branch):
		if commit.committer.name not in stats_by_user.index:
			stats_by_user.loc[commit.committer.name] = 0
		stats_by_user.loc[commit.committer.name].commits += 1
	tree = repo.heads[branch].commit.tree
	def compute_lines(tree):
		for blob in tree.blobs:
			try:
				file_content = ""
				for commit, lines in repo.blame(branch, blob.path):
					stats_by_user.loc[commit.committer.name].lines += len(lines)
					file_content += "\n".join(lines) + "\n"
				try:
					lexer = guess_lexer(file_content)
					stats_by_user.loc[commit.committer.name].comments += sum([x[0] in Comment for x in lexer.get_tokens(file_content)])
				except ClassNotFound:
					print("File {} : language unknown".format(blob.path))
			except TypeError:
				print("File {} is binary : skipped".format(blob.path))
	walk_tree(compute_lines, tree)
	pretty_print(stats_by_user)
