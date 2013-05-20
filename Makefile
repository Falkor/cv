####################################################################################
# Makefile (configuration file for GNU make - see http://www.gnu.org/software/make/)
#
# Copyright (c) 2011 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .              http://varrette.gforge.uni.lu
# .                      __  __       _         __ _ _
# .                     |  \/  | __ _| | _____ / _(_) | ___
# .                     | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# .                     | |  | | (_| |   <  __/  _| | |  __/
# .                     |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# .
# --------------------------------------------------------------------------------
# This is a generic makefile in the sense that it doesn't require to be 
# modified when adding/removing new source files.
# --------------------------------------------------------------------------------
# This program is free software: you can redistribute it and/or modify it under
# the terms of the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
# Unported License (CC-by-nc-sa 3.0)
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  For more details, please visit:
#              http://creativecommons.org/licenses/by-nc-sa/3.0/
# --------------------------------------------------------------------------------
# Compilation of files written in LaTeX, adapted to the generation of my CV (as
# it includes the invocation of a script to split my single BibTeX file to
# classify biblio entries by their type).
#
# This makefile search for LaTeX sources from the current directory, identifies 
# the main files (i.e the one containing the sequence '\begin{document}') and 
# launch the compilation for the generation of PDFs and optionnaly compressed 
# Postscript files. 
# Two compilation modes can be configured using the USE_PDFLATEX variable:
#    1/ Rely on pdflatex to generate directly a pdfs from the LaTeX sources. 
#       The compilation follow then the scheme: 
#
#                main.tex --[pdflatex/bibtex]--> main.pdf + main.[aux|log etc.]
#
#       Note that in that case, your figures should be in pdf format instead of eps.
#       To use this mode, just set the USE_PDFLATEX variable to 'yes'
# 
#    2/ Respect the classical scheme:                             +-[dvips]-> main.ps
#                                                                 |             |             
#                                                                 |        +-[gzip]
#       main.tex -[latex/bibtex]-> main.dvi + main.[aux|log etc.]-+        |     
#                                                                 |        +-> main.ps.gz     
#                                                                 +-[dvipdf]-> main.pdf
#       To use this mode, just set the USE_PDFLATEX variable to 'no'
# In all cases: 
#   - all the intermediate files (main.aux, main.log etc.) will be moved
#     to $(TRASH_DIR)/ (if it exists). 
#   - the target files (dvi, pdf, ps.gz etc.) will stay in the current directory.  
#
# Available Commands: run 'make help'
############################## Variables Declarations ##############################
SHELL=/bin/bash 

UNAME = $(shell uname)

# Some directories
SUPER_DIR   = $(shell basename `pwd`)

# Git stuff management
GITFLOW      = $(shell which git-flow)
LAST_TAG_COMMIT = $(shell git rev-list --tags --max-count=1)
LAST_TAG = $(shell git describe --tags $(LAST_TAG_COMMIT) )
TAG_PREFIX = "v"
GITFLOW_BR_MASTER=production
GITFLOW_BR_DEVELOP=master

VERSION  = $(shell [ -f VERSION ] && head VERSION || echo "0.0.1")
# OR try to guess directly from the last git tag
#VERSION    = $(shell  git describe --tags $(LAST_TAG_COMMIT) | sed "s/^$(TAG_PREFIX)//")
MAJOR      = $(shell echo $(VERSION) | sed "s/^\([0-9]*\).*/\1/")
MINOR      = $(shell echo $(VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
PATCH      = $(shell echo $(VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
# total number of commits 		
BUILD      = $(shell git log --oneline | wc -l | sed -e "s/[ \t]*//g")

#REVISION   = $(shell git rev-list $(LAST_TAG).. --count)
#ROOTDIR    = $(shell git rev-parse --show-toplevel)
NEXT_MAJOR_VERSION = $(shell expr $(MAJOR) + 1).0.0-b$(BUILD)
NEXT_MINOR_VERSION = $(MAJOR).$(shell expr $(MINOR) + 1).0-b$(BUILD)
NEXT_PATCH_VERSION = $(MAJOR).$(MINOR).$(shell expr $(PATCH) + 1)-b$(BUILD)

# set to 'yes' to use pdflatex for the direct generation of pdf from LaTeX sources
# set to 'no' to use the classical scheme tex -> dvi -> [ps|pdf] by dvips
USE_PDFLATEX = yes

# Directory where PDF, Postcript files and other generated files will be placed
# /!\ Please ensure there is no trailing space after the values
OUTPUT_DIR = .
TRASH_DIR  = .Trash
HTML_DIR   = $(OUTPUT_DIR)/HTML
# Check avalibility of source files
TEX_SRC    = $(wildcard *.tex)
ifeq ($(TEX_SRC),)
all:
	@echo "No source files available - I can't handle the compilation"
	@echo "Please check the presence of source files (with .tex extension)"
else
# Main tex file and figures it may depend on 
MAIN_TEX   = $(shell grep -l "[\]begin{document}" $(TEX_SRC) | xargs echo)
FIGURES    = $(shell find . -name "*.eps" -o -name "*.fig" | xargs echo)
MAIN_BIB   = biblio-varrette.bib
SELECTED_BIB = selected_biblio-varrette.bib
STYLE_FILES = $(wildcard *.sty)
CV_CONF     = _cv_config.sty
SRC= $(TEX_SRC) $(STYLE_FILES) $(FIGURES) $(MAIN_BIB) 

ifeq ($(MAIN_TEX),)
all:
	@echo "I can't find any .tex file with a '\begin{document}' directive "\
		"among $(TEX_SRC). Please define a main tex file!"
else
# Commands used during compilation
LATEX        = $(shell which latex)
PDFLATEX     = $(shell which pdflatex)
LATEX2HTML   = $(shell which latex2html)
BIBTEX       = $(shell which bibtex)
DVIPS        = $(shell which dvips)
DVIPDF       = $(shell which dvipdf)
GZIP         = $(shell which gzip)
LATEX2RTF    = $(shell which latex2rtf)
# Generated files
DVI    	     = $(MAIN_TEX:%.tex=%.dvi)
PS           = $(MAIN_TEX:%.tex=%.ps)
PS_GZ        = $(MAIN_TEX:%.tex=%.ps.gz)
PDF          = $(MAIN_TEX:%.tex=%.pdf)
RTF          = $(MAIN_TEX:%.tex=%.rtf)
TARGET_PDF   = $(PDF)   
TARGET_PS_GZ = $(PS_GZ) 
ifneq ($(OUTPUT_DIR),.)
TARGET_PDF   = $(PDF:%=$(OUTPUT_DIR)/%)
TARGET_PS_GZ = $(PS_GZ:%=$(OUTPUT_DIR)/%) 
endif
TARGETS      = $(DVI) $(TARGET_PDF) $(TARGET_PS_GZ)
BACKUP_FILES = $(shell find . -name "*~")
# Files to move to $(TRASH_DIR) after compilation
# Never add *.tex (or any reference to source files) for this variable.
TO_MOVE      = *.aux *.log *.toc *.lof *.lot *.bbl *.blg *.out

# Specific bibliographic processing
SPLIT_BIB_SCRIPT = ./scripts/split_bibtex_per_type.pl
PERLMODULES=$(shell grep "^use " $(SPLIT_BIB_SCRIPT) | cut -d ' ' -f 2 | grep -v "strict" | grep -v "warnings" | sed -e "s/;//" | sort | uniq)
MANDATORY_BINARIES = latex pdflatex bibtex perl seq


### Main variables
.PHONY: all archive clean conf_full conf_short conf_tiny full help release setup short start_bump_major start_bump_minor start_bump_patch test tiny versioninfo 


############################### Now starting rules ################################
# Required rule : what's to be done each time 
all: full 

############################### Archiving ################################
archive: clean
	tar -C ../ -cvzf ../$(SUPER_DIR)-$(VERSION).tar.gz --exclude ".svn" --exclude ".git"  --exclude "*~" --exclude ".DS_Store" $(SUPER_DIR)/

############################### Git Bootstrapping rules ################################
setup:
	git fetch origin
	git branch --set-upstream $(GITFLOW_BR_MASTER) origin/$(GITFLOW_BR_MASTER)
	git config gitflow.branch.master     $(GITFLOW_BR_MASTER)
	git config gitflow.branch.develop    $(GITFLOW_BR_DEVELOP)
	git config gitflow.prefix.feature    feature/
	git config gitflow.prefix.release    release/
	git config gitflow.prefix.hotfix     hotfix/
	git config gitflow.prefix.support    support/
	git config gitflow.prefix.versiontag $(TAG_PREFIX)
	git submodule init
	git submodule update

versioninfo:
	@echo "Current version: $(VERSION)"
	@echo "Last tag: $(LAST_TAG)"
	@echo "$(shell git rev-list $(LAST_TAG).. --count) commit(s) since last tag"
	@echo "Build: $(BUILD) (total number of commits)"
	@echo "next major version: $(NEXT_MAJOR_VERSION)"
	@echo "next minor version: $(NEXT_MINOR_VERSION)"
	@echo "next patch version: $(NEXT_PATCH_VERSION)"

# Git flow management - this should be factorized 
ifeq ($(GITFLOW),)
start_bump_patch start_bump_minor start_bump_major release: 
	@echo "Unable to find git-flow on your system. "
	@echo "See https://github.com/nvie/gitflow for installation details"
else
start_bump_patch: clean
	@echo "Start the patch release of the repository from $(VERSION) to $(NEXT_PATCH_VERSION)"
	git pull origin
	git flow release start $(NEXT_PATCH_VERSION)
	@echo $(NEXT_PATCH_VERSION) > VERSION
	git commit -s -m "Patch bump to version $(NEXT_PATCH_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"

start_bump_minor: clean
	@echo "Start the minor release of the repository from $(VERSION) to $(NEXT_MINOR_VERSION)"
	git pull origin
	git flow release start $(NEXT_MINOR_VERSION)
	@echo $(NEXT_MINOR_VERSION) > VERSION
	git commit -s -m "Minor bump to version $(NEXT_MINOR_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"

start_bump_major: clean
	@echo "Start the major release of the repository from $(VERSION) to $(NEXT_MAJOR_VERSION)"
	git pull origin
	git flow release start $(NEXT_MAJOR_VERSION)
	@echo $(NEXT_MAJOR_VERSION) > VERSION
	git commit -s -m "Major bump to version $(NEXT_MAJOR_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"


release: clean 
	git flow release finish -s $(VERSION)
	git checkout $(GITFLOW_BR_MASTER)
	git push origin
	git checkout $(GITFLOW_BR_DEVELOP)
	git push origin
	git push origin --tags
endif

############################### CV versions ################################

## Prepare the configuration for a given type of CV
conf_full:
	@echo "=> configure CV to generate 'FULL' version"
	@echo "\def\cvtype{\cvfull}" > $(CV_CONF)

conf_short:
	@echo "=> configure CV to generate 'SHORT' version (3 pages)"
	@echo "\def\cvtype{\cvshort}" > $(CV_CONF)

conf_tiny:
	@echo "=> configure CV to generate 'TINY' version"
	@echo "\def\cvtype{\cvtiny}" > $(CV_CONF)

full: conf_full split_bib $(TARGET_PDF)

short: conf_short split_bib $(TARGET_PDF)

tiny: conf_tiny split_bib $(TARGET_PDF)


########################## Dvi/PS files generation ############################
dvi $(DVI) : $(SRC)
	@echo "==> Now generating $(DVI)"
	@for f in $(MAIN_TEX); do          \
	   $(LATEX) $$f;                   \
	   $(MAKE) bib;                    \
	   $(LATEX) $$f;                   \
	   $(LATEX) $$f;                   \
	   $(MAKE) move_to_trash;          \
	done
	@echo "==> $(DVI) generated"

# Compressed Postscript generation 
ps $(PS) $(TARGET_PS_GZ) : $(DVI)
	@for dvi in $(DVI); do                            \
	   	ps=`basename $$dvi .dvi`.ps;                  \
	   	echo "==> Now generating $$ps.gz from $$dvi"; \
	  	$(DVIPS) -q -o $$ps $$dvi;                    \
	   	$(GZIP) -f $$ps;                              \
	done
	@if [ "$(OUTPUT_DIR)" != "." ]; then              \
		$(MAKE) create_output_dir;                    \
		for ps in $(PS); do                           \
			echo "==> Now moving $$ps.gz to $(OUTPUT_DIR)/"; \
			mv $$ps.gz $(OUTPUT_DIR);                 \
		done;                                         \
	fi

########################## PDF files generation ############################
# The following part is specific for the case where pdflatex is used (by default) 
ifeq ("$(USE_PDFLATEX)", "yes")

pdf pdflatex $(TARGET_PDF): $(SRC)
	@echo "==> Now generating $(PDF)"
	@for f in $(MAIN_TEX); do          \
	   $(PDFLATEX) $$f;                \
	   $(MAKE) bib;                    \
	   $(PDFLATEX) $$f;                \
	   $(PDFLATEX) $$f;                \
	   $(MAKE) move_to_trash;          \
	done
	@if [ "$(OUTPUT_DIR)" != "." ]; then \
		$(MAKE) create_output_dir;       \
		for pdf in $(PDF); do            \
			echo "==> Now moving $$pdf to $(OUTPUT_DIR)/"; \
			mv $$pdf $(OUTPUT_DIR);      \
		done;                            \
	fi
	@$(MAKE) help

else 

pdf $(TARGET_PDF): $(DVI)
	@for dvi in $(DVI); do                            \
	   	ps=`basename $$dvi .dvi`.pdf;                 \
	   	echo "==> Now generating $$pdf from $$dvi";   \
	  	$(DVIPDF) $$dvi;                              \
	done
	$(MAKE) create_output_dir           	     
	@if [ "$(OUTPUT_DIR)" != "." ]; then              \
		for pdf in $(PDF); do                         \
			echo "==> Now moving $$pdf to $(OUTPUT_DIR)/";   \
			mv $$pdf $(OUTPUT_DIR);                   \
		done;                                         \
	fi
	@$(MAKE) help
endif

########################## Complementary tasks  ############################
TO_TRASH=$(shell ls $(TO_MOVE) 2>/dev/null | xargs echo)
move_to_trash:
	@if [ ! -z "${TO_TRASH}" -a -d $(TRASH_DIR) -a "$(TRASH_DIR)" != "." ]; then  \
                echo "==> Now moving ${TO_TRASH} to $(TRASH_DIR)/";                   \
                mv -f ${TO_TRASH} $(TRASH_DIR)/;                                      \
        elif [ ! -d $(TRASH_DIR) ]; then                             \
                echo "*** /!\ The trah directory $(TRASH_DIR)/ does not exist!!!";       \
                echo "***     May be you should create it to hide the files ${TO_TRASH}";\
        fi;   

create_output_dir: 
	@if [ ! -d $(OUTPUT_DIR) ]; then                                                  \
		echo "    /!\ $(OUTPUT_DIR)/ does not exist ==> Now creating ./$(OUTPUT_DIR)/"; \
		mkdir -p ./$(OUTPUT_DIR);                                                 \
	fi;  


# Clean option
clean:
	rm -f *.dvi $(RTF) $(TO_MOVE) $(BACKUP_FILES)
	@if [ ! -z "$(OUTPUT_DIR)" -a -d $(OUTPUT_DIR) -a "$(OUTPUT_DIR)" != "." ]; then       \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $(OUTPUT_DIR)/$$base*";       \
		rm -rf $(OUTPUT_DIR)/$$base*;                        \
           done                                                      \
	fi
	@if [ "$(OUTPUT_DIR)" == "." ]; then                         \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $$base.ps.gz and $$base.pdf"; \
		rm -rf $$base.ps.gz $$base.pdf;                	     \
	   done							     \
	fi
	@if [ ! -z "$(TRASH_DIR)" -a -d $(TRASH_DIR)  -a "$(TRASH_DIR)" != "." ];   then       \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $(TRASH_DIR)/$$base*";        \
		rm -rf $(TRASH_DIR)/$$base*;                         \
	   done                                                      \
	fi
	@if [ ! -z "$(HTML_DIR)" -a -d $(HTML_DIR) -a "$(HTML_DIR)" != "." ]; then       \
	   echo "==> Now removing $(HTML_DIR)";                      \
	   rm  -rf $(HTML_DIR);                                      \
	fi
	@if [ -x $(SPLIT_BIB_SCRIPT) -a -n "$(MAIN_BIB)" ]; then \
	   $(SPLIT_BIB_SCRIPT) --force --clean $(MAIN_BIB); \
	fi 

# bibliography aspects
split_bib: 
	@for bb in $(MAIN_BIB) $(SELECTED_BIB); do \
		[ "$$bb" == "$(SELECTED_BIB)" ] && script_opt=" --notitle" || script_opt=""; \
		if [ -x $(SPLIT_BIB_SCRIPT) -a -n "$$bb" ]; then \
			echo "=> processing the BibTeX file $$b with $(SPLIT_BIB_SCRIPT) $$script_opt"; \
	   		$(SPLIT_BIB_SCRIPT) $$script_opt $$bb; \
		fi \
	done

bib: split_bib
	@for f in $(MAIN_TEX); do                                    \
	   bib=`grep "^[\]bibliography{" $$f|sed -e "s/^[\]bibliography{\(.*\)}/\1/"|tr "," " "`;\
	   btsectfile=`grep -c btSect *.tex | grep -v ":0" | cut -d ":" -f 1 | xargs echo`;\
	   if [ ! -z "$$bib" ]; then                                 \
	  	echo "==> Now running BibTeX ($$bib used in $$f)";   \
		$(BIBTEX) `basename $$f .tex`;                       \
	   fi; \
	   echo "=> processing the LaTeX files $$btsectfile containing splitted BibTeX entries"; \
	   btsect=`grep "[\]begin{btSect}"  $$btsectfile | sed -e "s/^[\]begin{btSect}{\(.*\)}/\1/" | wc -l`; \
	   echo "=> $$btsect entry btsect found"; \
	   for btnum in `seq 1 $$btsect`; do  \
		echo "=> running bibtex on `basename $$f .tex`$$btnum"; \
		$(BIBTEX) `basename $$f .tex`$$btnum;    \
	   done;\
	done

check:
	@echo "*** Check local installation ***"
	@echo " => check mandatory binaries"
	@for cmd in $(MANDATORY_BINARIES); do \
		echo -n "   check $$cmd... "; \
		if [ -z "`which $$cmd`" ]; then \
			echo " FAILED!"; \
			echo "*** /!\ ERROR ($$cmd not present within your PATH)***"; \
			echo "*** /!\ Install the missing package and re-run 'make check' to check your config"; \
			exit 1; \
		else \
			echo "OK"; \
		fi \
	done
	@echo " => Perl modules used in $(SPLIT_BIB_SCRIPT):"
	@for p in $(PERLMODULES); do \
	 	echo -n "     $$p..."; \
		perl -M$$p -e 1; \
		if [ $$? == 0 ]; then \
			echo "OK"; \
		else \
			echo "*** /!\ ERROR ($$p not installed)***"; \
			echo "*** /!\ Install the missing module via cpan typically ('sudo cpan' followed by 'install $$p')."; \
			echo "*** /!\ Once installed, re-run 'make check' to check your config"; \
			exit 1; \
		fi; \
	done
#		if [ $$? -eq 0 ]; then echo "OK"; else echo "FAILED!" fi; \
	done




# force recompilation
force :
	@touch $(MAIN_TEX)
	@$(MAKE)

# Test values of variables - for debug purpose  
test:
	@echo "USE_PDFLATEX: $(USE_PDFLATEX)"
	@echo "--- Directories --- "
	@echo "OUTPUT_DIR -> $(OUTPUT_DIR)"
	@echo "TRASH_DIR  -> $(TRASH_DIR)"
	@echo "HTML_DIR   -> $(HTML_DIR)"
	@echo "--- Compilation commands --- "
	@echo "PDFLATEX   -> $(PDFLATEX)"
	@echo "LATEX      -> $(LATEX)"
	@echo "LATEX2HTML -> $(LATEX2HTML)"
	@echo "LATEX2RTF  -> $(LATEX2RTF)"
	@echo "BIBTEX     -> $(BIBTEX)"
	@echo "DVIPS      -> $(DVIPS)"
	@echo "DVIPDF     -> $(DVIPDF)"
	@echo "GZIP       -> $(GZIP)"
	@echo "--- Files --- "
	@echo "TEX_SRC    -> $(TEX_SRC)"
	@echo "MAIN_TEX   -> $(MAIN_TEX)"
	@echo "FIGURES    -> $(FIGURES)"
	@echo "BIB_FILES  -> $(BIB_FILES)"
	@echo "DVI        -> $(DVI)"
	@echo "PS         -> $(PS)"
	@echo "PS_GZ      -> $(PS_GZ)"
	@echo "PDF        -> $(PDF)"
	@echo "TO_MOVE    -> $(TO_MOVE)"
	@echo "TARGET_PS_GZ -> $(TARGET_PS_GZ)"
	@echo "TARGET_PDF   -> $(TARGET_PDF)"
	@echo "TARGETS      -> $(TARGETS)"
	@echo "BACKUP_FILES -> $(BACKUP_FILES)"
	@echo "--- Bibliography management --- "
	@echo "SPLIT_BIB_SCRIPT   -> $(SPLIT_BIB_SCRIPT)"
	@echo "PERLMODULES        -> $(PERLMODULES)"
	@echo "MANDATORY_BINARIES -> $(MANDATORY_BINARIES)"	

# print help message
help :
	@echo '+---------------------------------------------------------------+'
	@echo '|                        Available Commands                     |'
	@echo '+------------+--------------------------------------------------+'
	@echo '| make       | Compile LaTeX files. Generated files (pdf etc.)  |'
	@echo '|            | are placed in the current directly               |'
	@echo '| make force | Force re-compilation, even if not needed         |'
	@echo '| make clean | Remove all generated files                       |'
	@echo '| make bib   | handle the BibTeX entries                        |'
	@echo '| make rtf   | Generate rtf file from LaTeX using latex2rtf     |'
	@echo '| make html  | Generate HTML files from TeX in $(HTML_DIR)/     '
	@echo '| make help  | Print help message                               |'
	@echo '+------------+--------------------------------------------------+'

# RTF generation using latex2rtf
rtf $(RTF): $(TARGET_PDF)
ifeq ($(LATEX2RTF),)
	@echo "Please install latex2rtf to use this option!"
else
	@echo "==> Now generating $(RTF)"
	-cp $(TRASH_DIR)/*.aux $(TRASH_DIR)/*.bbl .
	@for f in $(MAIN_TEX); do    \
	   $(LATEX2RTF) -i english $$f;  \
	done
	@$(MAKE) move_to_trash
	@echo "==> $(RTF) is now generated"
	@$(MAKE) help
endif


# HTML pages generation using latex2html
# First check that $(LATEX2HTML) and $(HTML_DIR)/ exist
html :
ifeq ($(LATEX2HTML),)
	@echo "Please install latex2html to use this option!"
	@echo "('apt-get install latex2html' under Debian)"
else
	@if [ ! -d ./$(HTML_DIR) ]; then                                    \
	   echo "$(HTML_DIR)/ does not exist => Now creating $(HTML_DIR)/"; \
	   mkdir -p ./$(HTML_DIR);                                          \
	fi
	-cp $(TRASH_DIR)/*.aux $(TRASH_DIR)/*.bbl .
	$(LATEX2HTML) -show_section_numbers -local_icons -split +1 \
		-dir $(HTML_DIR) $(MAIN_TEX)
	@rm -f *.aux *.bbl $(HTML_DIR)/*.tex $(HTML_DIR)/*.aux $(HTML_DIR)/*.bbl
	@echo "==> HTML files generated in $(HTML_DIR)/" 
	@echo "May be you can try to execute 'mozilla ./$(HTML_DIR)/index.html'"
endif
endif
endif
