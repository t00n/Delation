#!/usr/bin/env python3

from argh import *
from git import *
from collections import defaultdict

@dispatch_command
@arg('extension')
@arg('comment')
@arg('directory')
def main(extension, comment, directory):
	repo = Repo(directory)
	commits_by_user = defaultdict(lambda: 0)
	for commit in repo.commit().iter_items(repo, 'HEAD'):
		commits_by_user[commit.committer.name] += 1
	print(commits_by_user)
	# tree = repo.heads.master.commit.tree
	# for blob in tree.blobs:
	# 	print(blob.path)

