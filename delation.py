#!/usr/bin/env python3

from argh import *
from git import *
from collections import defaultdict

class dict(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self

@dispatch_command
@arg('extension')
@arg('comment')
@arg('directory')
def main(extension, comment, directory):
	repo = Repo(directory)
	stats_by_user = defaultdict(lambda: dict(commits=0, lines=0, comments=0))
	for commit in repo.commit().iter_items(repo, 'HEAD'):
		stats_by_user[commit.committer.name].commits += 1
	print(stats_by_user)
	# tree = repo.heads.master.commit.tree
	# for blob in tree.blobs:
	# 	print(blob.path)

