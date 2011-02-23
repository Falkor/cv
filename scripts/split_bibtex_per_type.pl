#!/usr/bin/perl -w

##############################################################################
# File      : split_bibtex_per_type.pl
# Author    : Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Creation  : 26 Oct 2009
# Time-stamp: <Wed 2011-02-23 02:20 svarrette>
# $Id$
#
# Description : split a single BibTeX file into several sub-file, each
#               containing entries of the same type.
#       See the man page for more information.
#
# Copyright (c) 2009 Sebastien Varrette (http://www-id.imag.fr/~svarrett/)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##############################################################################
use strict;
use warnings;

# Used packages
use Getopt::Long;               # For command line management (long version)
use Term::ANSIColor; # To send the ANSI color-change sequences to the user's terminal
use Pod::Usage;
use Data::Dumper;               # Print utility
use Text::BibTeX;               # BibTeX Parser
use Tie::IxHash;                # To Preserve hash entries order

sub getOutputNameFrom($$@);

# Generic variables
my $VERSION = '0.2';            # Script version
my $VERBOSE = 0;   # option variable for verbose mode with default value (false)
my $DEBUG   = 0;   # option variable for debug mode with default value (false)
my $QUIET   = 0;   # By default, display all informations
my $FORCE   = 0;   # don't ask
my $numargs = scalar(@ARGV);    # Number of arguments
my $command = `basename $0`;    # base command
chomp($command);

# Specific variables
my $SIMULATION_MODE = 0;        # By default, don't simulate
my $CLEAN_MODE = 0;             # delete output files

# Parse command line
my $getoptRes = GetOptions('dry-run|n' => \$SIMULATION_MODE, # Simulation mode
                           'clean'     => \$CLEAN_MODE,
                           'force|f'   => \$FORCE,
                           'verbose|v' => \$VERBOSE, # Verbose mode
                           'quiet|q'   => sub { $QUIET=1, $FORCE=1; }, # Quiet mode
                           'debug'     => sub { $DEBUG = 1; $VERBOSE = 1; }, # Debug mode
                           'help|h'    => sub { pod2usage(-exitval => 1,
                                                          -verbose => 2); }, # Show help
                           'version'   => sub { VERSION_MESSAGE(); exit(0); } # Show version
                          );
my $bibinputfile = shift;

PRINT_ERROR_THEN_EXIT("Please check the format of your command-line (use '$0 --help') $!") unless ($bibinputfile);
# Basic Error processing
PRINT_ERROR_THEN_EXIT() unless ($numargs); # At least a file or an option should be mentioned

debug("=> processing BibTeX file: $bibinputfile\n");
my $bibfile = new Text::BibTeX::File "$bibinputfile";
my $bibout  = new Text::BibTeX::File;
my $num_entries = 0;
tie (my %type_met, 'Tie::IxHash');
%type_met = ();
tie (my %titles, 'Tie::IxHash');
%titles =
  (
   "book"          => "Books",
   "incollection"  => "Magazine",
   "inbook"        => "Book Chapters",
   "article"       => "International journals",
   "inproceedings" => "Conferences Articles",
   "inproceedings_default"       => "International conferences with proceedings and reviews",
   "inproceedings_national"      => "(French) national conferences with proceedings and reviews",
   "inproceedings_noreview"      => "International conferences with proceedings",
   "inproceedings_noproceedings" => "International conferences with reviews",
   "phdthesis"     => "PhD Thesis",
   "mastersthesis" => "Masters Thesis",
   "techreport"    => "Technical Reports",
   "misc"          => "Miscellaneous",
   "conference"    => "Conferences",
   "proceedings"   => "Proceedings",
  );

# Differentiate eventually among the InProceedings types
# tie (my %inproceeding_types, 'Tie::IxHash');
# %inproceeding_types =
#   (
#    "default"       => "International conferences with proceedings and reviews",
#    "national"      => "(French) national conferences with proceedings and reviews",
#    "noreview"      => "International conferences with proceedings",
#    "noproceedings" => "International conferences with reviews",
#   );

if ($CLEAN_MODE) {
    my $generated_files = getOutputNameFrom($bibinputfile,"*");
    my $latex = getOutputNameFrom($bibinputfile,"main");
    $latex .= " " . getOutputNameFrom($bibinputfile,"summary");
    $latex =~ s/\.bib/\.tex/g;
    $generated_files .= " $latex";
    info("removing generated files $generated_files\n");
    really_continue();
    execute("rm -f $generated_files");
    exit $?;
}

while (my $entry = new Text::BibTeX::Entry $bibfile) {
    next unless $entry->parse_ok;
    my $type = $entry->type();
    my $subtype = undef;
    if ($type eq 'inproceedings') {
        $subtype = $entry->exists( 'type' ) ? $entry->get( 'type' ) : 'default';
        $type .= "_$subtype";
    }
    my $outputfile = getOutputNameFrom($bibinputfile, $type);
    my $mode = ( defined($type_met{$type})) ? ">>" : ">";
    debug("=> adding this entry to $outputfile \n");
    $bibout->open("$outputfile", "$mode") || die "Unable to open $outputfile: $!\n";
    $entry->write($bibout);
    $bibout->close();
    if (!defined($type_met{$type})) {
        $mode = ">";
        $type_met{$type} = 1;
    } else {
        $type_met{$type}++;
    }
    $num_entries++;
}

info("$num_entries entries processed, partitionned as follows:\n");
print Dumper \%type_met;

#*OUT = *STDOUT;

my $latexsummary = getOutputNameFrom($bibinputfile,"summary");
$latexsummary =~ s/\.bib/\.tex/;
debug("create LaTeX table that summarize publication records (in $latexsummary)\n");

open(OUT, ">" . $latexsummary);
print OUT <<EndText;
\\begin{table}[ht]
    \\centering
%    \\begin{tabular}{|c|c|c|}
    \\begin{tabular}{|c|c|}
        \\hline
        \\rowcolor{lightgray}
        \\textbf{Publication category} & \\textbf{Quantity} 
%  & \\textbf{Section}
%        \\multicolumn{1}{|l}{}
        \\\\
        \\hline
EndText

foreach my $type (keys %titles) {
    if (defined($type_met{$type})) {
        print OUT <<EndText;
        $titles{$type} & $type_met{$type} 
%        & \\multicolumn{1}{l|}{\\S\\ref{sec:publis:details:$bibinputfile:$type}}
        \\\\
EndText
    }
}

print OUT <<EndText;
    \\hline
    \\multicolumn{1}{r}{\\textbf{Total:}} &
     \\multicolumn{1}{c}{\\textbf{$num_entries}} \\\\
    \\end{tabular}
%    \\caption{Overview of my publications records}
%    \\label{tab:csc:publis:summary}
\\end{table}
EndText
close(OUT);


my $latexmain = getOutputNameFrom($bibinputfile,"main");
$latexmain =~ s/\.bib/\.tex/;
debug("create LaTeX code for the publis sections (in $latexmain)\n");

open(OUT, ">" . $latexmain);

foreach my $type (keys %titles) {
    my $bib = getOutputNameFrom($bibinputfile,$type);
    if (-e "$bib") {
        $bib =~ s/\.bib//;
        print OUT <<EndText;
%        \\section{$titles{$type}  ($type_met{$type})}
        \\noindent \\textbf{$titles{$type} ($type_met{$type}})
        \\label{sec:publis:details:$bibinputfile:$type}
        \\begin{btSect}{$bib}
           \\btPrintAll
        \\end{btSect}

EndText
    }
}
close(OUT);



#################################################################################
############## ------------------ Sub routines  ------------------ ##############
#################################################################################

######
# Print information in the following form: '[$2] $1' ($2='=>' if not submitted)
# usage: info(text [,title])
##
sub info {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    my $prefix = $_[1] ? $_[1] : '=>';
    print "$prefix $_[0]" unless $QUIET;
}

######
# Print verbose information (i.e print only if $VERBOSE is set)
# usage: verbose(text)
##
sub verbose {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    print @_ if ${VERBOSE};
}

######
# Print debug information (i.e print only if $DEBUG is set)
# usage: debug(text)
##
sub debug {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    info(@_, '['. color("yellow") . 'DEBUG' . color("reset") . ']') if ${DEBUG};
}

######
# Print error message
# usage: error(text)
##
sub error {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    info(@_, '['. color("red") . 'ERROR' . color("reset") . ']');
}

######
# Print warning message
# usage: warning(text)
##
sub warning {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    info(@_, '['. color("magenta") . 'WARNING' . color("reset") . ']');
}

####
# Print error message then exit with error status
# Optionnal parameter $_[0] : error message ('Bad format' by defaut)
##
sub PRINT_ERROR_THEN_EXIT {
    my $msg = $_[0] ? $_[0] : 'Bad format';
    error "$msg\n";
    exit(1);
}

######
# Ask the user wish to continue.
##
sub really_continue {
    unless ($FORCE) {
        print "Are you sure you want to continue? [yN] ";
        chomp(my $ans = <STDIN>);
        exit(0) unless ($ans && ($ans =~ /y|yes|1/i));
    }
}

#####
# execute a local command
# usage: execute(command)
###
sub execute {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing command argument') unless (@_);
    debug('[' . (caller(0))[3] . "] @_\n");
    $SIMULATION_MODE ?
      print '(', color('bold'), 'simulation', color('reset'), ") @_\n" : system("@_");
    my $exit_status = $?;
    debug('[' . (caller(0))[3] . "] exit status : $exit_status\n");
    return $exit_status;
}

####
# check the presence of the binaries @_ on the local system using 'which'
# usage:  check_binary(bin1 [, bin2 ...]);
##getoptRes
sub check_binary {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing argument') unless (@_);
    my $which = "$ENV{'PATH'} which";
    foreach my $app (@_) {
        verbose("=> check availability of the command '$app' on the local system...");
        verbose("\n") if (($DEBUG) || ($SIMULATION_MODE));
        my $exit_status = execute("which $app 1>/dev/null");
        PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . "] unable to find the application $app on your system") if ($exit_status);
        verbose("\tOK\n");
    }
}

####
# Print script version
##
sub VERSION_MESSAGE {
    print <<EOF;
This is $command v$VERSION.
Copyright (c) 2009 Sebastien Varrette  (http://varrette.gforge.uni.lu/)
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
EOF
}

####
# generate the name of the output BibTeX file fro the input filename and the
# type of entry.
# Usage:  getOutputNameFrom(infilename, type [, subtype] )
##
sub getOutputNameFrom($$@) {
    my $in      = shift;
    my $type    = shift;
    my $subtype = shift;
    my $out  = "__sub_" . `basename $in .bib`;
    chomp($out);
    $out .= "_" . $type . (defined($subtype) ? "_$subtype" : "") . ".bib";
    return $out;
}


######################## POD documentation ########################
=pod

=head1 NAME

I<split_bibtex_per_type.pl>, a nice script in perl that split a single
BibTeX file into several sub-file, each containing entries of the same type.

=head1 SYNOPSIS

      ./split_bibtex_per_type.pl [options] file.bib

=head1 DESCRIPTION

I<split_bibtex_per_type.pl> takes a BibTeX file as input and filter it per entry
type (article, book, inproceedings etc.) to generate several output files that
contains the entries of a given type.

This particularly useful for the multibib package of LaTeX that permit to manage
several separate bibtex files. After the run, you'll typically add the following
line in your LaTeX file:

  \IfFileExists{__sub_xxxxxxxxx_main.tex}{\input{__sub_xxxxxxxxxx_main}}{}

where xxxxxxxxx is the name of teh main bibtex file (file.bib in the synopsis)

=head1 OPTIONS

The following options are available:

=over 12

=item B<--debug>

Debug mode. Display debugging information probably only relevant to me ;)

=item B<--dry-run   -n>

Simulate the operations to show what would have been done and/or transferred but do
not perform any backend actions.

=item B<--help  -h>

Display a help screen and quit.

=item B<--quiet>

Quiet mode. Minimize the number of printed messages and don't ask questions.
Very useful for invoking this script in a crontab yet use with caution has all
operations will be performed without your interaction.

=item B<--verbose  -v>

Verbose mode. Display more information

=item B<--version>

Display the version number then quit.

=back

=head1 BUGS

Please report bugs to Sebastien Varrette <Sebastien.Varrette@uni.lu>

=head1 AUTHOR

Sebastien Varrette -- L<http://varrette.gforge.uni.lu/>

=head1 COPYRIGHT

This  is a free software. There is NO warranty; not even for
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut













