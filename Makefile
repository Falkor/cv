####################################################################################
# Makefile (configuration file for GNU make - see http://www.gnu.org/software/make/)
# Time-stamp: <Sun 2018-04-08 00:24 svarrette>
#     __  __       _         __ _ _            __   _         _____   __  __
#    |  \/  | __ _| | _____ / _(_) | ___      / /  | |    __ |_   _|__\ \/ /
#    | |\/| |/ _` | |/ / _ \ |_| | |/ _ \    / /   | |   / _` || |/ _ \\  /
#    | |  | | (_| |   <  __/  _| | |  __/   / /    | |__| (_| || |  __//  \
#    |_|  |_|\__,_|_|\_\___|_| |_|_|\___|  /_/     |_____\__,_||_|\___/_/\_\
#
# Copyright (c) 2004-2015 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
#
####################################################################################
# Compilation of files written in LaTeX.
# If you can, consider [Latexmk](http://www.ctan.org/pkg/latexmk/) as a far more
# complete solution for the compilation of your LaTeX documents.
# This Makefile appeared sufficient for all my workflows.
#
# Grab the lastest version of this Makefile from:
#            https://github.com/Falkor/Makefiles/tree/devel/latex
#
# --------------------------------------------------------------------------------
# This is a generic makefile in the sense that it doesn't require to be
# modified when adding/removing new source files.
# --------------------------------------------------------------------------------
#
# This makefile search for LaTeX sources from the current directory, identifies
# the main files (i.e the one containing the sequence '\begin{document}') and
# launch the compilation for the generation of PDFs using the pdflatex compiler
# (or others such as lualatex for instance) specified by the LATEX variable.
#
# Upon compilation:
# * all the intermediate files (main.aux, main.log etc.) will be moved
#   to $(TRASH_DIR)/ (if it exists).
# * the gererated files (pdf etc.) will stay in the current directory.
#
# Available Commands : see `make help`

############################## Variables Declarations ##############################
SHELL = /bin/bash

# set to 'yes' to use pdflatex for the direct generation of pdf from LaTeX sources
# set to 'no' to use the classical scheme tex -> dvi -> [ps|pdf] by dvips
#USE_PDFLATEX = yes

# Directory where PDF, Postcript files and other generated files will be placed
# /!\ Please ensure there is no trailing space after the values
OUTPUT_DIR  = .
TRASH_DIR   = .Trash
HTML_DIR    = $(OUTPUT_DIR)/HTML
SUPER_DIR   = $(shell basename `pwd`)
RELEASE_DIR = releases

# Check availibility of source files
TEX_SRC      = $(wildcard *.tex)
MARKDOWN_SRC = $(filter-out README.md, $(wildcard *.md))
MARKDOWN_DST = $(MARKDOWN_SRC:%.md=%.md.tex)
STYLE_SRC    = $(wildcard *.sty)
BIB_SRC      = $(wildcard *.bib)
ifeq ($(TEX_SRC),)
$(error "No source files available - compilation is not possible -- Kindly check LaTeX source files")
endif

# Main tex file and figures it may depend on
MAIN_TEX    = $(shell grep -l "[\]begin{document}" $(TEX_SRC) | xargs echo)
USE_BEAMER  = $(shell grep -l "{beamer}" $(MAIN_TEX) | xargs echo)
#FIGURES    = $(shell find . -name "*.eps" -o -name "*.fig" | xargs echo)
#IMAGES_DIR = images

# Various commands used during compilation
LATEX        = $(shell which pdflatex)
CMDLINE_OPTS = -synctex=1 -halt-on-error -interaction=batchmode
LATEX2HTML   = $(shell which latex2html)
LATEX2RTF    = $(shell which latex2rtf)
PANDOC       = $(shell which pandoc)
BIBTEX       = $(shell which bibtex)

# Generated files
PDF          = $(MAIN_TEX:%.tex=%.pdf)
RTF          = $(MAIN_TEX:%.tex=%.rtf)
TARGET_PDF   = $(PDF)
ifneq ($(OUTPUT_DIR),.)
TARGET_PDF   = $(PDF:%=$(OUTPUT_DIR)/%)
endif
BACKUP_FILES = $(shell find . -name "*~")
# Files to move to $(TRASH_DIR) after compilation
# Never add *.tex (or any reference to source files) for this variable.
TO_MOVE      = *.aux *.log *.toc *.lof *.lot *.bbl *.blg  *.maf *.mtc* *.out *.nav *snm *.vrb *.rel *.thm

# Git stuff
LAST_TAG_COMMIT = $(shell git rev-list --tags --max-count=1)
LAST_TAG        = $(shell git describe --tags $(LAST_TAG_COMMIT) )
ROOTDIR         = $(shell git rev-parse --show-toplevel)
CURDIR          = $(shell git rev-parse --show-prefix)

# Versioning
VERSIONFILE   = VERSION
VERSION       = $(shell [ -f $(VERSIONFILE) ] && head $(VERSIONFILE) || echo "0.0.1")
PREVIOUS_VERSIONFILE_COMMIT = $(shell git log -1 --pretty=%h $(VERSIONFILE) 2>/dev/null )
PREVIOUS_VERSION = $(shell [ -n "$(PREVIOUS_VERSIONFILE_COMMIT)" ] && git show $(PREVIOUS_VERSIONFILE_COMMIT)^:$(CURDIR)$(VERSIONFILE) )
# OR try to guess directly from the last git tag
#VERSION    = $(shell  git describe --tags $(LAST_TAG_COMMIT) | sed "s/^$(TAG_PREFIX)//")
MAJOR         = $(shell echo $(VERSION) | sed "s/^\([0-9]*\).*/\1/")
MINOR         = $(shell echo $(VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
PRE_PATCH     = $(shell echo $(VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
PATCH = $(PRE_PATCH:$(VERSION)=0)
# total number of commits
BUILD       = $(shell git log --oneline | wc -l | sed -e "s/[ \t]*//g")
#REVISION   = $(shell git rev-list $(LAST_TAG).. --count)
NEXT_MAJOR_VERSION = $(shell expr $(MAJOR) + 1).0.0-b$(BUILD)
NEXT_MINOR_VERSION = $(MAJOR).$(shell expr $(MINOR) + 1).0-b$(BUILD)
NEXT_PATCH_VERSION = $(MAJOR).$(MINOR).$(shell expr $(PATCH) + 1)-b$(BUILD)

LIST_RELEASE_TO_DELETE = $(shell [ -d "$(RELEASE_DIR)" ] && ls $(RELEASE_DIR)/*.pdf | grep -v $(VERSION) | xargs echo)

# Ghostscript for the help of producing optimized PDF
GS      = $(shell which gs)
GS_OPT  = -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress
### Main variables
BEFORE_TARGETS = split_bib
TARGETS        = $(BEFORE_TARGETS) $(TARGET_PDF)
TARGETS_DEPS = $(TEX_SRC) $(MARKDOWN_SRC) $(STYLE_SRC) $(BIB_SRC) $(FIGURES)

### Automatic split of bibliography
SPLIT_BIB_SCRIPT = ./scripts/manage_bibtex
MAIN_BIB     = biblio-varrette.bib
SELECTED_BIB = selected_biblio-varrette.bib

### CV configuration
CV_CONF = _cv_config.sty

# Local configuration - Kept for compatibity reason
LOCAL_MAKEFILE = .Makefile.local
# Makefile custom hooks
MAKEFILE_BEFORE = .Makefile.before
MAKEFILE_AFTER  = .Makefile.after

.PHONY: all archive test versioninfo

#clean create_output_dir dvi force help html move_to_trash pdflatex ps release rtf setup singlerun start_bump_major start_bump_minor start_bump_patch test versioninfo

############################### Now starting rules ################################
# Load local settings, if existing (to override variable eventually)
ifneq (,$(wildcard $(LOCAL_MAKEFILE)))
include $(LOCAL_MAKEFILE)
endif
ifneq (,$(wildcard $(MAKEFILE_BEFORE)))
include $(MAKEFILE_BEFORE)
endif

ifeq ($(MAIN_TEX),)
$(error "Cannot find any .tex file with a '\begin{document}' directive among '$(TEX_SRC)'. Please define a main tex file!")
endif

# Markdown files processing
ifneq ($(MARKDOWN_SRC),)
ifeq ($(PANDOC),)
$(error "pandoc cannot be found on your system. Kindly install it to convert markdown to latex")
endif
BEFORE_TARGETS += $(MARKDOWN_DST)
endif


# Required rule : what's to be done each time
all: $(TARGETS)

# Test values of variables - for debug purposes
test:
	@echo "--- Directories --- "
	@echo "OUTPUT_DIR   -> '$(OUTPUT_DIR)'"
	@echo "TRASH_DIR    -> '$(TRASH_DIR)'"
	@echo "HTML_DIR     -> '$(HTML_DIR)'"
	@echo "SUPER_DIR    -> '$(SUPER_DIR)'"
	@echo "RELEASE_DIR  -> '$(RELEASE_DIR)'"
	@echo "LIST_RELEASE_TO_DELETE -> $(LIST_RELEASE_TO_DELETE)"
	@echo
	@echo "--- Compilation commands --- "
	@echo "LATEX        -> '$(LATEX)'"
	@echo "CMDLINE_OPTS -> '$(CMDLINE_OPTS)'"
	@echo "LATEX2HTML   -> '$(LATEX2HTML)'"
	@echo "LATEX2RTF    -> '$(LATEX2RTF)'"
	@echo "PANDOC       -> '$(PANDOC)'"
	@echo "BIBTEX       -> '$(BIBTEX)'"
	@echo "GS           -> '$(GS)'"
	@echo "GS_OPT       -> '$(GS_OPT)'"
	@echo
	@echo "--- Files --- "
	@echo "TEX_SRC      -> '$(TEX_SRC)'"
	@echo "MARKDOWN_SRC -> '$(MARKDOWN_SRC)'"
	@echo "STYLE_SRC    -> '$(STYLE_SRC)'"
	@echo "BIB_SRC      -> '$(BIB_SRC)'"
	@echo "MAIN_TEX     -> '$(MAIN_TEX)'"
	@echo "USE_BEAMER   -> '$(USE_BEAMER)'"
	@echo "FIGURES      -> '$(FIGURES)'"
	@echo "PDF          -> '$(PDF)'"
	@echo "RTF          -> '$(RTF)'"
	@echo "BACKUP_FILES -> '$(BACKUP_FILES)'"
	@echo "TO_MOVE      -> '$(TO_MOVE)'"
	@echo
	@echo "--- Main targets --- "
	@echo "MARKDOWN_DST -> '$(MARKDOWN_DST)'"
	@echo "TARGET_PDF   -> '$(TARGET_PDF)'"
	@echo "BEFORE_TARGETS -> '$(BEFORE_TARGETS)'"
	@echo "TARGETS      -> '$(TARGETS)'"
	@echo "TARGETS_DEPS -> '$(TARGETS_DEPS)'"
	@echo "Consider running 'make versioninfo' to get info on git versionning variables"

############################### Archiving ################################
archive: clean
	tar -C ../ -cvzf ../$(SUPER_DIR)-$(VERSION).tar.gz --exclude ".svn" --exclude ".git"  --exclude "*~" --exclude ".DS_Store" --exclude "'$(RELEASE_DIR)/*.pdf'" $(SUPER_DIR)/

# force recompilation
force :
	@touch $(MAIN_TEX)
	@$(MAKE)

############################### before releasing ################################
generate:
	for f in $(TARGET_PDF); do   \
		$(MAKE) clean; \
		$(MAKE); \
		if [ -n "$(GS)" ]; then \
			optimf="`basename $$f .pdf`-optimized.pdf"; \
			$(GS) $(GS_OPT) -sOutputFile=$$optimf $$f; \
			mv $$optimf $$f; \
		fi; \
		mv $$f $(RELEASE_DIR)/; \
		for type in tiny short; do \
			$(MAKE) clean; \
			$(MAKE) $$type; \
			if [ -n "$(GS)" ]; then \
				optimf="`basename $$f .pdf`-optimized.pdf"; \
				$(GS) $(GS_OPT) -sOutputFile=$$optimf $$f; \
				mv $$optimf $$f; \
			fi; \
			mv $$f $(RELEASE_DIR)/`basename $$f .pdf`_$$type.pdf;  \
		done; \
	done


####################### LaTeX Compilation rules ########################
# Markdown files processing
ifneq ($(MARKDOWN_SRC),)
md markdown: $(MARKDOWN_DST)

ifeq ($(USE_BEAMER),)
%.md.tex: %.md
	@echo "==> generating LaTeX content from markdown file $<"
	$(PANDOC) --from markdown --to latex -o $@ $<
else
%.md.tex: %.md
	@echo "==> generating Beamer LaTeX content from markdown file $<"
	$(PANDOC) --from markdown --to beamer --slide-level 3 -o $@ $<
endif
endif

# Single LaTeX compilation
singlerun:
	@for f in $(MAIN_TEX); do \
		echo -e "==> Now running '$(LATEX) $(OPTIONAL_OPT) $(CMDLINE_OPTS) $$f'"; \
		$(LATEX) $(OPTIONAL_OPT) $(CMDLINE_OPTS) $$f; \
		exit_status=$$?; \
		if [ $$exit_status -ne 0 ]; then \
			tail -n 50 `basename $$f .tex`.log; \
			echo -e "\n\n"; \
			exit $$exit_status; \
		fi; \
	done

### Fast processing for a quick compilation
fast: $(TARGETS_DEPS)
	@$(MAKE) singlerun OPTIONAL_OPT=-draftmode

### Bibliography aspects
split_bib:
	@for bb in $(MAIN_BIB) $(SELECTED_BIB); do \
		[ "$$bb" == "$(SELECTED_BIB)" ] && script_opt=" --no-title" || script_opt=""; \
		if [ -x $(SPLIT_BIB_SCRIPT) -a -n "$$bb" ]; then \
			echo "=> processing the BibTeX file $$b with $(SPLIT_BIB_SCRIPT) $$script_opt"; \
	   		$(SPLIT_BIB_SCRIPT) split $$script_opt $$bb; \
		fi \
	done

bib:
	@for f in $(MAIN_TEX); do                                    \
		bib=`grep "^[\]bibliography{" $$f|sed -e "s/^[\]bibliography{\(.*\)}/\1/"|tr "," " "`;\
		btsectfile=`grep -c btSect *.tex | grep -v ":0" | cut -d ":" -f 1 | xargs echo`;\
		echo "btsectfile=$$btsectfile"; \
		smallcv=`grep 'small\|short' $(CV_CONF) 2>/dev/null`; \
		if [ -n "$$smallcv"  ]; then                                \
			echo "==> Now running BibTeX ($$bib used in $$f)";   \
			$(BIBTEX) `basename $$f .tex`;                       \
	  fi; \
	 	echo "=> processing the LaTeX files $$btsectfile containing splitted BibTeX entries"; \
	 	btsect=`grep "[\]begin{btSect}"  $$btsectfile | sed -e "s/^[\]begin{btSect}{\(.*\)}/\1/" | wc -l`; \
	 	for btnum in `seq 1 $$btsect`; do  \
			btf="`basename $$f .tex`$$btnum"; \
			if [ -f "$$btf.bbl" ]; then \
				echo "=> running bibtex on `basename $$f .tex`$$btnum"; \
				$(BIBTEX) `basename $$f .tex`$$btnum;    \
			fi; \
	   	done;\
	done

# PDF generation
pdf: $(TARGET_PDF)

create_output_dir:
	@if [ ! -d $(OUTPUT_DIR) ]; then                                                  \
		echo "    /!\ $(OUTPUT_DIR)/ does not exist ==> Now creating ./$(OUTPUT_DIR)/"; \
		mkdir -p ./$(OUTPUT_DIR);                                                 \
	fi;

$(TARGET_PDF): $(TARGETS_DEPS)
	@$(MAKE) singlerun OPTIONAL_OPT=-draftmode
	@$(MAKE) bib
	@$(MAKE) singlerun
	@$(MAKE) singlerun
	@$(MAKE) move_to_trash
	@if [ "$(OUTPUT_DIR)" != "." ]; then              \
		$(MAKE) create_output_dir;                    \
		for pdf in $(PDF); do                         \
			echo "==> Now moving $$pdf to $(OUTPUT_DIR)/"; \
			mv $$pdf $(OUTPUT_DIR);                   \
		done;                                         \
	fi
	@echo "==> $@ successfully generated"


# Useful hask for generating Exercise Correction CORRECTION_<main>.tex
ifneq (, $(shell grep '\\usepackage.*{exercise}' *.tex *.sty))
TMP_FILE4CORRECTION = .putSolutions.tex
correction: clean
	@if [ ! -f "$(TMP_FILE4CORRECTION)" ]; then  \
	   	echo "\clearpage{\footnotesize \shipoutAnswer}" > $(TMP_FILE4CORRECTION); \
	else \
		echo "/!\ The file $(TMP_FILE4CORRECTION) already exists!"; \
	fi
	@for f in $(MAIN_TEX); do                             \
		correction_file=CORRECTION_$$f;                    \
		echo "===> generating '$$f' and correction file '$$correction_file"; \
	   	if [ -f "$$correction_file" ]; then                \
			echo "/!\ correction file already present";       \
	  	else                                               \
			echo " * generating symlink $$correction_file and compile it"; \
			ln -s $$f $$correction_file;               \
			$(MAKE) `basename $$correction_file .tex`.pdf;  \
			rm -f $$correction_file $(TMP_FILE4CORRECTION) `basename $$correction_file .tex`.synctex.gz $(OUTPUT_DIR)/`basename $$f .tex`.pdf; \
			$(MAKE);  \
	   	fi;           \
	done
	@[ -f $(TMP_FILE4CORRECTION) ] && rm $(TMP_FILE4CORRECTION) || true
else

correction:

endif

############################### clean ################################
TO_TRASH=$(shell ls $(TO_MOVE) 2>/dev/null | xargs echo)
move_to_trash:
	@if [ ! -z "${TO_TRASH}" -a -d $(TRASH_DIR) -a "$(TRASH_DIR)" != "." ]; then  \
		echo "==> Now moving $(TO_TRASH) to $(TRASH_DIR)/";                   \
        mv -f ${TO_TRASH} $(TRASH_DIR)/;                                      \
    elif [ ! -d $(TRASH_DIR) ]; then                             \
		echo "*****************************************************"; \
        echo "*** /!\ The trash directory $(TRASH_DIR)/ does not exist!!!";       \
        echo "***     May be you should create it to hide the files ${TO_TRASH}";\
        echo "***     Consider running 'mkdir -p $(TRASH_DIR)'"; \
		echo "*****************************************************"; \
    fi;

# Clean option
clean:
	rm -f $(TARGETS) $(RTF) $(CV_CONF) $(TO_MOVE) $(BACKUP_FILES) *.synctex.gz* CORRECTION_*
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
		echo "==> Now cleaning $$base.pdf"; \
		rm -rf $$base.pdf;                	     \
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
	rm -f __sub_*

#@if [ -x $(SPLIT_BIB_SCRIPT) -a -n "$(MAIN_BIB)" ]; then \
		$(SPLIT_BIB_SCRIPT) --force --clean $(MAIN_BIB); \
		$(SPLIT_BIB_SCRIPT) --force --clean $(SELECTED_BIB); \
	fi


# print help message
help :
	@echo '+----------------------------------------------------------------------+'
	@echo '|                        Available Commands                            |'
	@echo '+----------------------------------------------------------------------+'
	@echo '| make:         Compile LaTeX files.                                   |'
	@echo '|               Generated files (pdf etc.) are placed in $(OUTPUT_DIR)/            |'
	@echo '| make force:   Force re-compilation, even if not needed               |'
	@echo '| make clean:   Remove all generated files                             |'
	@echo '| make html:    Generate HTML files from TeX in $(HTML_DIR)/           '
	@echo '| make help:    Print help message                                     |'
	@echo '| make version_bump_{major,minor,patch}: bump version at a given level |'
	@echo '|               (major, minor or patch bump) in $(VERSIONFILE)'
	@echo '| make rtf:     Generate an RTF file from LaTeX sources (useful for    |'
	@echo '|               further copy/paste in a Word document)                 |'
	@echo '+----------------------------------------------------------------------+'


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
html:
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

ifneq (,$(wildcard $(MAKEFILE_AFTER)))
include $(MAKEFILE_AFTER)
endif

FORCE:
