#!/usr/bin/env perl
#
#              INGLÊS/ENGLISH
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  http://www.gnu.org/copyleft/gpl.html
#
#
#             PORTUGUÊS/PORTUGUESE
#  Este programa é distribuído na expectativa de ser útil aos seus
#  usuários, porém NÃO TEM NENHUMA GARANTIA, EXPLÍCITAS OU IMPLÍCITAS,
#  COMERCIAIS OU DE ATENDIMENTO A UMA DETERMINADA FINALIDADE.  Consulte
#  a Licença Pública Geral GNU para maiores detalhes.
#  http://www.gnu.org/copyleft/gpl.html
#
#  Copyright (C) 2019  Universidade Estadual Paulista "Júlio de Mesquita Filho"
#
#  Universidade Estadual Paulista "Júlio de Mesquita Filho" (UNESP)
#  Faculdade de Ciências Agrárias e Veterinárias (FCAV)
#  Laboratório de Bioinformática (LB)
#
#  Daniel Guariz Pinheiro
#  dgpinheiro@gmail.com
#  http://www.fcav.unesp.br
#
# $Id$

=head1 NAME

=head1 SYNOPSIS

=head1 ABSTRACT

=head1 DESCRIPTION
    
    Arguments:

        -h/--help   Help
        -l/--level  Log level [Default: FATAL] 
            OFF
            FATAL
            ERROR
            WARN
            INFO
            DEBUG
            TRACE
            ALL

=head1 AUTHOR

Daniel Guariz Pinheiro E<lt>dgpinheiro@gmail.comE<gt>

Copyright (C) 2019 Universidade Estadual Paulista "Júlio de Mesquita Filho"

=head1 LICENSE

GNU General Public License

http://www.gnu.org/copyleft/gpl.html


=cut

use strict;
use warnings;
use Readonly;
use Getopt::Long;

use vars qw/$LOGGER/;

INIT {
    use Log::Log4perl qw/:easy/;
    Log::Log4perl->easy_init($FATAL);
    $LOGGER = Log::Log4perl->get_logger($0);
}

my ($level, $gene_trans_map, $taxonomy_table, $outfile);

Usage("Too few arguments") if $#ARGV < 0;
GetOptions( "h|?|help" => sub { &Usage(); },
            "l|level=s"=> \$level,
            "g|gene_trans_map=s"=>\$gene_trans_map,
            "t|taxonomy_table=s"=>\$taxonomy_table,
            "o|outfile=s"=>\$outfile
    ) or &Usage();


if ($level) {
    my %LEVEL = (   
    'OFF'   =>$OFF,
    'FATAL' =>$FATAL,
    'ERROR' =>$ERROR,
    'WARN'  =>$WARN,
    'INFO'  =>$INFO,
    'DEBUG' =>$DEBUG,
    'TRACE' =>$TRACE,
    'ALL'   =>$ALL);
    $LOGGER->logdie("Wrong log level ($level). Choose one of: ".join(', ', keys %LEVEL)) unless (exists $LEVEL{$level});
    Log::Log4perl->easy_init($LEVEL{$level});
}

$LOGGER->logdie("Missing gene_trans_map !") unless ($gene_trans_map);
$LOGGER->logdie("Wrong gene_trans_map ($gene_trans_map) !") unless (-e $gene_trans_map);

$LOGGER->logdie("Missing taxonomy table !") unless ($taxonomy_table);
$LOGGER->logdie("Wrong taxonomy table ($taxonomy_table) !") unless (-e $taxonomy_table);

$LOGGER->logdie("Missing output file!") unless ($outfile);

open(OUT, ">", $outfile) or $LOGGER->logdie($!);

our %gene; 

open(GTM,"<", $gene_trans_map) or $LOGGER->logdie($!);

while(<GTM>) { 
    chomp; 
    my ($g,$i) = split(/\t/, $_); 
    $gene{$i}=$g; 
} 
close(GTM); 

open(IN, "<", $taxonomy_table) or $LOGGER->logdie($!);
my $header_line=<IN>;
chomp($header_line);
my @header=split(/\t/, $header_line); 

my %taxtable;

while(<IN>) {
    chomp;
    my %data; 
    @data{@header}=split(/\t/, $_);

    $LOGGER->logdie("Not found gene for ".$data{"#TAXONOMY"}) unless (exists $gene{ $data{"#TAXONOMY"} }); 

    my $g = $gene{ $data{"#TAXONOMY"} };
    $data{"#TAXONOMY"} = $g;

    $taxtable{ $data{"#TAXONOMY"} } = [ @data{@header} ];
}


print OUT join("\t", @header),"\n";
foreach my $g (keys %taxtable) {
    print OUT join("\t", @{ $taxtable{$g} }),"\n";
}

close(OUT);

# Subroutines

sub Usage {
    my ($msg) = @_;
	Readonly my $USAGE => <<"END_USAGE";
Daniel Guariz Pinheiro (dgpinheiro\@gmail.com)
(c)2019 Universidade Estadual Paulista "Júlio de Mesquita Filho"

Usage

        $0	[-h/--help] [-l/--level <LEVEL>]

Argument(s)

        -h      --help              Help
        -l      --level             Log level [Default: FATAL]
        -o      --outfile           Output file (gene_trans_map file)
        -g      --gene_trans_map    The gene_trans_map file used as reference to generate new taxonomy table
                                    
                                    TRINITY_DN1105_c0_g1    TRINITY_DN1105_c0_g1_i1
                                    TRINITY_DN1105_c0_g1    TRINITY_DN1105_c0_g1_i2
                                    TRINITY_DN2794_c0_g2    TRINITY_DN2794_c0_g2_i1
                                    ...

        -t      --taxonomy_table    Taxonomy table of transcripts
                
                                    #TAXONOMY	kingdom	phylum	class	order	family	genus	specie
                                    TRINITY_DN1105_c0_g1_i1	Bacteria	Proteobacteria	Alphaproteobacteria	Caulobacterales	Caulobacteraceae	Brevundimonas	Brevundimonas sp. PAMC22021
                                    TRINITY_DN1105_c0_g1_i2	Bacteria	Proteobacteria	Alphaproteobacteria	Caulobacterales	Caulobacteraceae	Brevundimonas	Brevundimonas sp. PAMC22021
                                    TRINITY_DN2794_c0_g2_i1	Bacteria	Actinobacteria	Actinomycetia	Micrococcales	Micrococcaceae	Paeniglutamicibacter	Paeniglutamicibacter sp. Y32M11
                                    ...
        

END_USAGE
    print STDERR "\nERR: $msg\n\n" if $msg;
    print STDERR qq[$0  ] . q[$Revision$] . qq[\n];
	print STDERR $USAGE;
    exit(1);
}

