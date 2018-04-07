-*- mode: markdown; mode: visual-line; fill-column: 80 -*-

[![Licence](https://img.shields.io/badge/license-CC by--nc--sa-blue.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0)
![By Falkor](https://img.shields.io/badge/by-Falkor-blue.svg) [![github](https://img.shields.io/badge/git-github-lightgray.svg)](https://github.com/Falkor/cv) [![Issues](https://img.shields.io/badge/issues-github-green.svg)](https://github.com/Falkor/cv/issues)

       Time-stamp: <Sun 2018-04-08 00:27 svarrette>

         ______    _ _             _        _______      __
        |  ____|  | | |           ( )      / ____\ \    / /
        | |__ __ _| | | _____  _ __/ ___  | |     \ \  / /
        |  __/ _` | | |/ / _ \| '__|/ __| | |      \ \/ /
        | | | (_| | |   < (_) | |   \__ \ | |____   \  /
        |_|  \__,_|_|_|\_\___/|_|   |___/  \_____|   \/


       Copyright (c) 2011-2016 Sebastien Varrette <Sebastien.Varrette@uni.lu>


## Synopsis

This is the repository containing the [LaTeX](http://www.latex-project.org/) sources of
my personal CV.

This LaTeX document can (_should_) be compiled using the [GNU Make](http://www.gnu.org/software/make) utility.
Documentation on the Make utility may be found [here](http://www.gnu.org/software/make/manual/make.html)

## Installation / Repository Setup

This repository is hosted on [Github](https://github.com/Falkor/cv).

* To clone this repository, proceed as follows (adapt accordingly):

        $> mkdir -p ~/git/github.com/Falkor
        $> cd ~/git/github.com/Falkor
        $> git clone https://github.com/Falkor/cv.git

**`/!\ IMPORTANT`**: Once cloned, initiate your local copy of the repository by running:

    $> cd cv
    $> make setup

This will initiate the [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) layout for this repository.

### LaTeX and Perl modules

The compilation of the files contained in this directory requires the following binaries :

* `latex`, `pdflatex` and `make` 	(for compilation)
* `bibtex` 	             			(for bibliography/references)
* `perl`                   			(the script that split the bibliography is based on Perl)
* `seq` - this command is missing on Mac OS X. See below for a fix.
* (optional) `latex2html`  			(html generation from LaTeX)
* (optional) `latex2rtf`   			(rtf generation from LaTeX)
* a few [CPAN](http://search.cpan.org) modules used in the [perl](http://www.perl.org/) script mentioned above, namely `Data::Dumper`,  `Getopt::Long`,  `Pod::Usage`, `Term::ANSIColor`, `Text::BibTeX` and `Tie::IxHash`.

**`/!\ IMPORTANT:`** Please check that your system is correctly configured by running

> `make check`.

* If you run a Mac OS X, the `seq` command is absent from your system.
To install it, simply copy the provided script `scripts/seq` into a directory searched by your system (_i.e._ part of your PATH variable), for instance `/usr/local/bin` or `$HOME/bin`.
* If a perl module `Module::Name` is missing on your system, install it via [CPAN](http://search.cpan.org).
   - if you are under Mac OS, install [Homebrew](http://brew.sh) and the [`cpanminus`](https://libraries.io/homebrew/cpanminus) package. Then install the missing modules as follows:

         cpanm Text::BibTeX Tie::IxHash

   - otherwise, use [CPAN](http://search.cpan.org) as follows:

   		   $> sudo cpan
		     [...]
		     cpan shell -- CPAN exploration and modules installation (v1.9402)
		     Enter 'h' for help.

		     cpan[1]> install Module::Name
		     [...]
		     Module::Name installed successfully
		     cpan[2]> quit

## Compilation of the LaTeX sources

As mentioned above, the compilation of this document relies on [GNU Make](http://www.gnu.org/software/make/), and you should have a complete working LaTeX environment (including the `pdflatex` compiler).

Several versions of my CV can be compiled:

| Compilation Command | Output file                                                     | Size    | Description                                            |
|---------------------|-----------------------------------------------------------------|---------|--------------------------------------------------------|
| `make`              | [`cv-varrette-en.pdf`](releases/cv-varrette-en.pdf)             | 8 pages | Full complete version, holding **all** my publications |
| `make short`        | [`cv-varrette-en_short.pdf`](releases/cv-varrette-en_short.pdf) | 3 pages | Short version (3p), holding selected publications      |
| `make tiny`         | [`cv-varrette-en_tiny.pdf`](releases/cv-varrette-en_tiny.pdf)   | 1 page  | Tiny version                                           |
|                     |                                                                 |         |                                                        |

When you type `make [type]`, the following process is operated:

1. First pass of `pdflatex` and generation of additional files (*.aux *.bbl)
2. Treatment of the [BibTeX](http://www.bibtex.org/) bibliography which include
    * splitting the main bib file into several file `__sub_biblio_*.bib`
    * run `bibtex` on the auxiliary  files
3. Second and third pass of `pdflatex` to correct the references


## Issues / Feature request

You can submit bug / issues / feature request using the [`Falkor/cv` Project Tracker](https://github.com/Falkor/cv/issues)

## Advanced Topics

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
Also, you will have the generated PDF for the freshly released version as a file under `release/cv-varrette-en[_<type>].pdf`.


### Directory Layout

```bash
.
├── Images/         # pics / images folder
├── LICENCE
├── Makefile        # GNU make configutaration, coupled with .Makefile.{before,after}
├── README.md       # This file
├── VERSION
├── _*.tex               # Sub LaTeX files (conditionally included)
├── *.sty                # LaTeX style configuration
├── biblio-varrette.bib  # Main BibTeX file
├── cv.cls               # Personal adaptation of an old cv class
├── cv-varrette-en.tex   # Main LaTeX file
├── mini_bio.txt         # Mini bio, in text formal
├── releases/            # Hold LATEST PDF release of mu CVs
│   ├── README.md
│   ├── cv-varrette-en.pdf         # Full version
│   ├── cv-varrette-en_short.pdf   # short version (3p)
│   ├── cv-varrette-en_small.pdf   # small version (2p)
│   └── cv-varrette-en_tiny.pdf    # tiny version (1p)
├── scripts/        # Various scripts, including the one splitting the bibliography
└── selected_biblio-varrette.bib   # Selected bibliographic entries
```

### [New] Bibliography management

I maintain a single [BibTeX](http://www.bibtex.org/) file `biblio-varrette.bib` to collect the entries of my publications.
A script `script/manage_bibtex` help me to split that biblio in multiple part.

### [Old] Bibliography management

As many others, I maintain a single [BibTeX](http://www.bibtex.org/) file `biblio-varrette.bib` to collect the entries of my publications.
For a CV, it make more sense to me to present my bibliographic entries by type, and to automate the collection of statistics on them (number of entries per type etc.), I  made a perl script (`scripts/split_bibtex_per_type.pl`) for this purpose. For details about its usage, run

> `scripts/split_bibtex_per_type.pl --help`

The parsing in itself is made using the [`Text::BibTeX`](http://search.cpan.org/~ambs/Text-BibTeX-0.56/lib/Text/BibTeX.pm) module so it should be installed on your system.
Some additional modules are required (`Tie::IxHash` for instance). Once this script behave normally on your system, you should not take care of it as it will do the job transparently.

For those interested, here is an extract of the help message for this script:

	NAME
	    *split_bibtex_per_type.pl*, a nice script in perl that split a single
	    BibTeX file into several sub-file, each containing entries of the same
	    type.

	SYNOPSIS
	          ./split_bibtex_per_type.pl [options] file.bib

	DESCRIPTION
	    *split_bibtex_per_type.pl* takes a BibTeX file as input and filter it
	    per entry type (article, book, inproceedings etc.) to generate several
	    output files that contains the entries of a given type.

	    It has been designed to work in collaboration with the "bibtopic" LaTeX
	    package (see
	    <http://www.ctan.org/tex-archive/macros/latex/contrib/bibtopic/>) that
	    permits to use multiple bibliography file in a single document.

	    For instance, invoked on the BibTeX file "file.bib",
	    *split_bibtex_per_type.pl* will generate the following files:

	    "__sub_file_*.bib"
	                These files contains BibTeX entries of a given type (for
	                instance, "__sub_file_article.bib" contains all entries of
	                type @Article{...} in "file.bib").

	    "__sub_file_main.tex"
	                This is the main LaTeX you probably want to include in your
	                document as it contains the code (with the )to include the
	                relevant sub-files.

	    "__sub_file_summary.tex"
	                You may want to include this LaTeX file as it will generate
	                a table summarizing the number of publications per type.

	    The best way to integrate transparently the files generated by this
	    script in your LaTeX document is to add the following lines in your
	    LaTeX file:

	        \def\bibfile{file}  % basename of your BibTeX main file - here 'file.bib'

	        % Summary of the publications
	        \IfFileExists{__sub_\bibfile_summary.tex}{
	          \input{__sub_\bibfile_summary}
	        }{}

	        % Detailed list
	        \IfFileExists{__sub_\bibfile_main.tex}{
	          \input{__sub_\bibfile_main}
	        }{}
	[...]

	ADVANCED TIPS
	  SPECIAL TREATMENT OF INPROCEEDINGS ENTRIES
	    It appeared difficult to distinguish BibTeX entries related to
	    international conferences, national conferences with or without
	    reviews/proceedings: you probably refer to them using a BibTeX entry as
	    follows:

	        @InProceedings{xx,
	            author =    {xx},
	            title =     {xx},
	            booktitle = {xx},
	            pages =     {xx -- xx},
	            year =      {20xx},
	        }

	    To distinguish these "InProceedings" entries, *split_bibtex_per_type.pl*
	    detect the eventual presence of a specific directive "type = {xx}" where
	    "xx" can have one of the following values: "national", "noreview" and
	    "noproceedings". The absence of this directive (as in the above BibTeX
	    entry) is equivalent to specifying the value "default".

	    Then the splitting of the bibliography will lead to the creation of the
	    files "__sub_file_inproceedings_default.bib",
	    "__sub_file_inproceedings_national.bib",
	    "__sub_file_inproceedings_noreview.bib",
	    "__sub_file_inproceedings_noproceedings.bib",

	    Of course, if you don't use this technics, all your "InProceedings"
	    entries will be grouped in the file
	    "__sub_file_inproceedings_default.bib"

	  CHANGING PUBLICATION CATEGORY AND/OR ORDER
	    If you don't like the way each publication category is labelled, feel
	    free to adapt the values (not the keys!) of the %titles hash table in
	    *split_bibtex_per_type.pl*.

	    Changing the order of the pairs <"key", "value" > in this hash will
	    change the order of the corresponding sections in the summary table and
	    the detailed list.


## Licence

This project is released under the terms of the [CC by-nc-sa](LICENCE) licence.

[![Licence](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0)

Based on a [work hosted on GitHub](https://github.com/Falkor/cv).

## Contributing

That's quite simple:

1. [Fork](https://help.github.com/articles/fork-a-repo/) it
2. Create your own feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new [Pull Request](https://help.github.com/articles/using-pull-requests/)
