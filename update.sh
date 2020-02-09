#!/usr/bin/env bash

git submodule foreach git pull origin master
git pull --rebase
vim +PlugUpgrade +PlugUpdate +qall
