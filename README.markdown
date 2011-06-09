-*- mode: markdown; mode: auto-fill; fill-column: 80 -*-

    Time-stamp: <Mon 2011-06-06 17:51 svarrette> 

Copyright (c) 2011 [Sebastien Varrette](http://varrette.gforge.uni.lu) - [mail](mailto:Sebastien.Varrette@uni.lu)

-------------
# Description

This is the repository containing the [LaTeX](http://www.latex-project.org/) sources of 
my personal CV. 

This LaTeX document can (_should_) be compiled using the [GNU Make](http://www.gnu.org/software/make) utility.
Documentation on the Make utility may be found [here](http://www.gnu.org/software/make/manual/make.html)

# Prerequisite 

The compilation of the files contained in this directory requires the following binaries : 

* `latex`, `pdflatex` and `make` 	(for compilation)
* `bibtex` 	             			(for bibliography/references)
* `perl`                   			(the script that split the bibliography is based on Perl)
* `seq` - this command is missing on Mac OS X. See below for a fix. 
* (optional) `latex2html`  			(html generation from LaTeX)
* (optional) `latex2rtf`   			(rtf generation from LaTeX)
* a few [CPAN](http://search.cpan.org) modules used in the [perl](http://www.perl.org/) script mentioned above, namely `Data::Dumper`,  `Getopt::Long`,  `Pod::Usage`, `Term::ANSIColor`, `Text::BibTeX` and `Tie::IxHash`.

Please check that your system is correctly configured by running `make check`.

* If you run a Mac OS X, the `seq` command is absent from your system. 
To install it, simply copy the provided script `scripts/seq` into a directory searched by your system (_i.e._ part of your PATH variable), for instance `/usr/local/bin` or `$HOME/bin`. 
* If a perl module `Module::Name` is missing on your system, install it via [CPAN](http://search.cpan.org) as follows:

   		$> sudo cpan
		[...]
		cpan shell -- CPAN exploration and modules installation (v1.9402)
		Enter 'h' for help.
		
		cpan[1]> install Module::Name
		[...]
		Module::Name installed successfully
		cpan[2]> quit


# CV Compilation

To generate the PDF file from the LaTeX source, you just have to run the following command in a Terminal:

> `make` 

This should create the file `cv-varrette-en.pdf` in the current directory. 

Run `make help` for more details about the available commands.

# Advanced tips

## Configuration 

If you want to reuse these files, you should update the following elements:

* the `\name` variable in `_style.sty`
* the `\bibfile` variable in `_publis.tex` (to match the basename of your
  bibliographic file) 
* the `MAIN_BIB` variable in the `Makefile`

## Repository organization 

This directory is organized a follows: 

* `cv-varrette-en.tex`: main LaTeX document
* `_*.tex`: sub-files included the main LaTeX document
* `_style.sty`: main LaTeX style configuration
* `bibtopic.sty`: LaTeX style used to split the bibliography
* `cv.cls`: personal adaptation of an old cv class
* `script/` directory: contains scripts (mainly the one used to split the bibliography)
* `Images/` directory: contains... Images (i.e. my photo ;) )
* `Makefile`: GNU make configuration file
* `biblio-varrette.bib`: BibTeX file containing my biblio entries. A separate script will be responsible to split the biblio entries of this files and gather some statistics to be used later in `_publis.tex`    


## Detailed compilation process

When you type `make`, the following process is operated: 

1. First pass of `pdflatex` and generation of additional files (*.aux *.bbl)
2. Treatment of the [BibTeX](http://www.bibtex.org/) bibliography which include
 * splitting the main bib file into several file `__sub_biblio_*.bib`
 * run `bibtex` on the auxiliary  files
3. Second pass of `pdflatex` to correct the references

## Bibliography management

As many others, I maintain a single [BibTeX](http://www.bibtex.org/) file to collect the entries of my publications. 
For a CV, it make more sense to me to present my bibliographic entries by type, and to automate the collection of statistics on them (number of entries per type etc.)

I  made a perl script (`scripts/split_bibtex_per_type.pl`) for this purpose. For details about its usage, run 

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




-----------
# Licence

[cc-by-nc-sa-3]: http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png 

![Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License][cc-by-nc-sa-3]

This CV is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/).
Based on a [work hosted on GitHub](https://github.com/Falkor/cv)
