#!/usr/bin/env python3

from argh import *
from git import *
from collections import defaultdict

class dict(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self

def walk_tree(f, tree):
	res = f(tree)
	for tree in tree.trees:
		walk_tree(f, tree)


@dispatch_command
@arg('extension')
@arg('comment')
@arg('directory')
def main(extension, comment, directory):
	repo = Repo(directory)
	stats_by_user = defaultdict(lambda: dict(commits=0, lines=0, comments=0))
	for commit in repo.commit().iter_items(repo, 'HEAD'):
		stats_by_user[commit.committer.name].commits += 1
	tree = repo.heads.master.commit.tree
	def update_stats(tree):
		for blob in tree.blobs:
			for commit, lines in repo.blame('HEAD', blob.path):
				stats_by_user[commit.committer.name].lines += len(lines)
				stats_by_user[commit.committer.name].comments += len([line for line in lines 
																		   if isinstance(line, str) 
																		   and comment in line])
	walk_tree(update_stats, tree)
	print(stats_by_user)

