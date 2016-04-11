-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

[![Licence](https://img.shields.io/badge/license-CC by--nc--sa-blue.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0)
![By Falkor](https://img.shields.io/badge/by-Falkor-blue.svg) [![github](https://img.shields.io/badge/git-github-lightgray.svg)](https://github.com/Falkor/cv) [![Issues](https://img.shields.io/badge/issues-github-green.svg)](https://github.com/Falkor/cv/issues)

       Time-stamp: <Mon 2016-02-22 22:04 svarrette>

         ______    _ _             _        _______      __
        |  ____|  | | |           ( )      / ____\ \    / /
        | |__ __ _| | | _____  _ __/ ___  | |     \ \  / / 
        |  __/ _` | | |/ / _ \| '__| / __| | |      \ \/ /  
        | | | (_| | |   < (_) | |   \__ \ | |____   \  /   
        |_|  \__,_|_|_|\_\___/|_|   |___/  \_____|   \/    
                                                           
                                                           
       Copyright (c) 2016 Sebastien Varrette <Sebastien.Varrette@uni.lu>


## Synopsis

LaTeX Sources of my personal CV

## Installation / Repository Setup

This repository is hosted on [Github](https://github.com/Falkor/cv). 

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone git@github.com:Falkor/cv.git


**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running: 

    $> cd cv
    $> make setup

This will initiate the [Git submodules of this repository](.gitmodules) and setup the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

Later on, you can upgrade the [Git submodules](.gitmodules) to the latest version by running:

    $> make upgrade

If upon pulling the repository, you end in a state where another collaborator have upgraded the Git submodules for this repository, you'll end in a dirty state (as reported by modifications within the `.submodules/` directory). In that case, just after the pull, you **have to run** the following to ensure consistency with regards the Git submodules:

    $> make update



## Compilation of the LaTeX sources

The compilation of this document relies on [GNU Make](http://www.gnu.org/software/make/), and you should have a complete working LaTeX environment (including the `pdflatex` compiler).

To compile this document, simply run:

	$> make

This shall generate the PDF version of the document


## Issues / Feature request

You can submit bug / issues / feature request using the [`Falkor/cv` Project Tracker](https://github.com/Falkor/cv/issues)



## Advanced Topics

### Git

This repository make use of [Git](http://git-scm.com/) such that you should have it installed on your working machine: 

       $> apt-get install git-core # On Debian-like systems
       $> yum install git          # On CentOS-like systems
       $> brew install git         # On Mac OS, using [Homebrew](http://mxcl.github.com/homebrew/)
       $> port install git         # On Mac OS, using MacPort

Consider these resources to become more familiar (if not yet) with Git:

* [Simple Git Guide](http://rogerdudler.github.io/git-guide/)
* [Git book](http://book.git-scm.com/index.html)
* [Github:help](http://help.github.com/mac-set-up-git/)
* [Git reference](http://gitref.org/)

At least, you shall configure the following variables

       $> git config --global user.name "Your Name Comes Here"
       $> git config --global user.email you@yourdomain.example.com
       # configure colors
       $> git config --global color.diff auto
       $> git config --global color.status auto
       $> git config --global color.branch auto

Note that you can create git command aliases in `~/.gitconfig` as follows: 

       [alias]
           up = pull origin
           pu = push origin
           st = status
           df = diff
           ci = commit -s
           br = branch
           w  = whatchanged --abbrev-commit
           ls = ls-files
           gr = log --graph --oneline --decorate
           amend = commit --amend

Consider my personal [`.gitconfig`](https://github.com/Falkor/dotfiles/blob/master/git/.gitconfig) as an example -- if you decide to use it, simply copy it in your home directory and adapt the `[user]` section. 

### [Git-flow](https://github.com/nvie/gitflow)

The Git branching model for this repository follows the guidelines of
[gitflow](http://nvie.com/posts/a-successful-git-branching-model/).
In particular, the central repository holds two main branches with an infinite lifetime:

* `production`: the *production-ready* branch
* `master`: the main branch where the latest developments interviene. This is the *default* branch you get when you clone the repository.

Thus you are more than encouraged to install the [git-flow](https://github.com/nvie/gitflow) extensions following the [installation procedures](https://github.com/nvie/gitflow/wiki/Installation) to take full advantage of the proposed operations. The associated [bash completion](https://github.com/bobthecow/git-flow-completion) might interest you also.

### Releasing mechanism

The operation consisting of releasing a new version of this repository is automated by a set of tasks within the root `Makefile`.

In this context, a version number have the following format:

      <major>.<minor>.<patch>[-b<build>]

where:

* `< major >` corresponds to the major version number
* `< minor >` corresponds to the minor version number
* `< patch >` corresponds to the patching version number
* (eventually) `< build >` states the build number _i.e._ the total number of commits within the `master` branch.

Example: \`1.0.0-b28\`

The current version number is stored in the root file `VERSION`. __/!\ NEVER MAKE ANY MANUAL CHANGES TO THIS FILE__

For more information on the version, run:

     $> make versioninfo

If a new version number such be bumped, you simply have to run:

      $> make start_bump_{major,minor,patch}

This will start the release process for you using `git-flow`.
Once you have finished to commit your last changes, make the release effective by running:

      $> make release

It will finish the release using `git-flow`, create the appropriate tag in the `production` branch and merge all things the way they should be.

## Licence

This project is released under the terms of the [CC by-nc-sa](LICENCE) licence. 

[![Licence](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0)

## Contributing

That's quite simple:

1. [Fork](https://help.github.com/articles/fork-a-repo/) it
2. Create your own feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new [Pull Request](https://help.github.com/articles/using-pull-requests/)