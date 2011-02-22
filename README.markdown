-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-

    Time-stamp: <Tue 2011-02-22 20:43 svarrette> 

Copyright (c) 2011 [Sebastien Varrette](http://varrette.gforge.uni.lu) - [mail](mailto:Sebastien.Varrette@uni.lu)

-------------
# Description

This is the repository containing the [LaTeX](http://www.latex-project.org/) sources of 
my personal CV. 


# Prerequisite 

The compilation of the files contained in this directory requires the following binaries : 

* `latex`, `pdflatex` and `make` 	(for compilation)
* `bibtex` 	             			(for bibliography/references)
* `perl`                   			(the script that split the bibliography is based on Perl)
* (optional) `latex2html`  			(html generation from LaTeX)
* (optional) `latex2rtf`   			(rtf generation from LaTeX)

Please check that these commands are available on your system. 

This LaTeX document can be compiled using the [GNU Make](http://www.gnu.org/software/make) utility.
Documentation on the Make utility may be found [here](http://www.gnu.org/software/make/manual/make.html)


# Installation/Compilation

To generate the PDF file from the LaTeX source, you just have to run teh following command in a Terminal:

> `make` 

This should create the file `cv-varrette-en.pdf` in the current directory. 

Run `make help` for more details about the available commands.

# Advanced tips

## Repository organization 

TODO

## Detailed compilation process

When you type `make`, the following process is operated: 

1. First pass of `pdflatex` and generation of additional files (*.aux *.bbl)
2. Treatment of the [BibTeX](http://www.bibtex.org/) bibliography which include
 * splitting the main bib file into several file `__sub_biblio_*.bib`
 * run `bibtex` on the auxiliary  files
3. Second pass of `pdflatex` to correct the references

## Bibliography management

TODO

-----------
# Licence

[cc-by-nc-sa-3]: http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png 

![Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License][cc-by-nc-sa-3]

This CV is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/).
Based on a [work hosted on GitHub](https://github.com/Falkor/cv)
