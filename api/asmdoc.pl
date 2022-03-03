#!/usr/bin/perl --
#
# asmdoc.pl - Skrypt generujący dokumentację podobną do Javadoc dla assemblera.
# asmdoc.pl - A script which generates Javadoc-like documentation for assembler.
#
#	Copyright (C) 2007-2009,2012 Bogdan 'bogdro' Drozdowski
#		(bogdandr AT op.pl, bogdro AT rudy.mif.pg.gda.pl)
#
#	Licencja / License:
#	Powszechna Licencja Publiczna GNU v3+ / GNU General Public Licence v3+
#
#	Ostatnia modyfikacja / Last modified : 2012-02-05
#
#	Sposób użycia / Syntax:
#		./asmdoc.pl aaa.asm bbb.asm ccc/ddd.asm
#		./asmdoc.pl --help|-help|-h
#
#	Wszystkie elementy linii poleceń powinny być kodowane w UTF-8, jeśli
#		mają znaki diakrytyczne, np. w ten sposób:
#	All command-line elements should be encoded in UTF-8, if they contain
#		national (non-ASCII) characters, e.g. like this:
#
#	echo "Your-text-here" | iconv -f iso-8859-X -t utf-8 > tmp-file
#	perl asmdoc.pl -author ... -windowtitle "`cat tmp-file`" files.asm
#	rm -f tmp-file
#	(| =Shift+BackSlash; ` = lewy apostrof/left apostrophe - backtick)
#
#	Można takie parametry oczywiście zapisać w kodzie skryptu poniżej.
#	Such parameters can of course be put in the code below.
#
#	Komentarze dokumentujące powinny się zaczynać od ';;' lub '/**', a
#	 kończyć na ';;' lub '*/'.
#
#	Documentation comments should start with ';;' or '/**' and
#	 end with ';;' or '*/'.
#
#	Przyklady/Examples:
#
#	;;
#	; Ta procedura czyta dane / This procedure reads data.
#	; @param CX - liczba bajtow / number of bytes
#	; @return DI - adres danych / address of data
#	;;
#	procedure01:
#		...
#		ret
#
#    Niniejszy program jest wolnym oprogramowaniem; możesz go
#    rozprowadzać dalej i/lub modyfikować na warunkach Powszechnej
#    Licencji Publicznej GNU, wydanej przez Fundację Wolnego
#    Oprogramowania - według wersji 3-ciej tej Licencji lub ktorejś
#    z późniejszych wersji.
#
#    Niniejszy program rozpowszechniany jest z nadzieją, iż będzie on
#    użyteczny - jednak BEZ JAKIEJKOLWIEK GWARANCJI, nawet domyślnej
#    gwarancji PRZYDATNOŚCI HANDLOWEJ albo PRZYDATNOŚCI DO OKREŚLONYCH
#    ZASTOSOWAŃ. W celu uzyskania bliższych informacji - Powszechna
#    Licencja Publiczna GNU.
#
#    Z pewnością wraz z niniejszym programem otrzymałeś też egzemplarz
#    Powszechnej Licencji Publicznej GNU (GNU General Public License);
#    jeśli nie - napisz do Free Software Foundation:
#		Free Software Foundation
#		51 Franklin Street, Fifth Floor
#		Boston, MA 02110-1301
#		USA
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation:
#		Free Software Foundation
#		51 Franklin Street, Fifth Floor
#		Boston, MA 02110-1301
#		USA

require 5.8.0;	# use encoding.

use strict;
use warnings;
use Cwd;
use Encode;
use Fcntl ':mode';
use File::Copy;
use File::Spec::Functions ':ALL';
use I18N::Langinfo;
use I18N::LangTags::Detect;
use Getopt::Long;
use PerlIO::encoding;

my @languages = I18N::LangTags::implicate_supers(I18N::LangTags::Detect::detect());
my $language = "";	# language
my $enc;	# output character encoding

my $html_ext = "html";	# rozszerzenie nazwy pliku (filename extension)

#########################################################################
# Ten kod można zmieniać w celach tłumaczenia.
# This code can be changed if you want to translate the program.
#########################################################################

foreach (@languages) {
	if ( $language eq "" && /^pl/io ) { $language = "PL"; }
	if ( $language eq "" && /^en/io ) { $language = "EN"; }
# 	if ( $language eq "" && /^de/io ) { $language = "DE"; }
# 	if ( $language eq "" && /^fr/io ) { $language = "FR"; }
}
if ( $language eq "" ) { $language = "EN"; }

# kodowanie znaków na terminalu (terminal character encoding)
my %win_enc = (
		"EN"	=>	'ascii',
		"PL"	=>	'cp1250',
# 		"DE"	=>	'cp125N',
# 		"FR"	=>	'cp125N',
		);

my %dos_enc = (
		"EN"	=>	'ascii',
		"PL"	=>	'cp852',
		);

my %unix_enc = (
		"CR"	=>	'iso-8859-2',
		"CZ"	=>	'iso-8859-2',
		"DA"	=>	'iso-8859-1',
		"DE"	=>	'iso-8859-1',
		"EN"	=>	'iso-8859-1',
		"ES"	=>	'iso-8859-1',
		"ET"	=>	'iso-8859-13',
		"FI"	=>	'iso-8859-1',
		"FR"	=>	'iso-8859-1',
		"GR"	=>	'iso-8859-7',
		"HU"	=>	'iso-8859-2',
		"IR"	=>	'iso-8859-1',
		"IT"	=>	'iso-8859-1',
		"LT"	=>	'iso-8859-13',
		"LV"	=>	'iso-8859-13',
		"NL"	=>	'iso-8859-1',
		"NO"	=>	'iso-8859-1',
		"PL"	=>	'iso-8859-2',
		"PT"	=>	'iso-8859-1',
		"RO"	=>	'iso-8859-2',
		"RU"	=>	'iso-8859-5',
		"SE"	=>	'iso-8859-1',
		"SK"	=>	'iso-8859-2',
		);

# ----------------
# Imagine that e.g. OpenBSD's Perl does NOT declare I18N::Langinfo::CODESET() (langinfo.h problem)
my $t;
eval {
	$t = I18N::Langinfo::CODESET();
};
#if ($@ || !defined $t) {die($@);};
if ( defined $t ) {	# Linux

#if ( $^O =~ /linux/i ) {
##	I18N::Langinfo->import(qw(langinfo CODESET));
	$enc = I18N::Langinfo::langinfo(I18N::Langinfo::CODESET());
	$enc =~ tr/A-Z/a-z/;
} else {	# OpenBSD & maybe others

	if ( $^O =~ /win/io ) {

		$enc = $win_enc{$language} if defined($win_enc{$language});

	} elsif ( $^O =~ /dos/io ) {

		$enc = $dos_enc{$language} if defined($dos_enc{$language});
		$html_ext = "htm";

	} else {

		$enc = $unix_enc{$language} if defined($unix_enc{$language});
	}
}

$enc = "utf8" if $enc eq "";
# ----------------

my %msg_file_noread = (
		"EN"	=>	"Unable to read file.",
		"PL"	=>	encode($enc, "Nie można odczytać pliku."),
		);

my %msg_dir_nowrite = (
		"EN"	=>	"Unable to write files to directory",
		"PL"	=>	encode($enc, "Nie można zapisać plików do katalogu"),
		);

my %msg_help = (
		"PL"	=> encode($enc,
			"AsmDoc - program generujący dokumentację HTML z podanych plików źródłowych\n".
			"\tjęzyka assembler. Wejdź na http://rudy.mif.pg.gda.pl/~bogdro/\n".
			"Autor: Bogdan 'bogdro' Drozdowski, bogdandr AT op.pl.\n".
			"Składnia: $0 [opcje] pliki\n\n".
			"Opcje:\n".
			"-author\t\t\t\tDołącz autorów (\@author)\n".
			"-bottom <kodHTML>\t\tDołącz podany tekst na dole każdej strony\n".
			"-charset|-docencoding <nazwa>\tNazwa zestawu znaków umieszczona w kodzie HTML\n\t\t\t\t\t(ostatnia wartość jest brana)\n".
			"-d <katalog>\t\t\tUmieszcza pliki wynikowe w podanym katalogu\n".
			"-doctitle <kodHTML>\t\tDołącz podany tytuł do strony głównej\n".
			"-encoding <nazwa>\t\tKodowanie znaków w plikach źródłowych\n".
			"-footer <kodHTML>\t\tDołącz podaną stopkę na każdej stronie\n".
			"-h|--help|-help|-?\t\tWyświetla pomoc\n".
			"-header <kodHTML>\t\tDołącz podany nagłówek na każdej stronie\n".
			"-helpfile <file>\t\tDołącz ten plik pomocy zamiast domyślnego\n".
			"-ida|-idapro\t\t\tWłącz tryb IDA Pro\n".
			"-L|--license\t\t\tWyświetla licencję tego programu\n".
			"-lang <2-literowy kod>\t\tGeneruje dokumentację w języku o podanym kodzie\n\t\t\t\t\tnp. PL, EN (jeśli obsługiwany)\n".
			"-nocomment\t\t\tOpuść znaczniki i opisy, wygeneruj deklaracje\n".
			"-nodeprecated\t\t\tNie dołączaj informacji o elementach\n\t\t\t\t\tprzestarzałych (\@deprecated)\n".
			"-nodeprecatedlist\t\tNie twórz listy przestarzałych elementów\n".
			"-nohelp\t\t\t\tNie twórz pliku pomocy\n".
			"-noindex\t\t\tNie twórz indeksu\n".
			"-nonvabar\t\t\tNie dołączaj paska nawigacyjnego do plików\n".
			"-nosince\t\t\tNie dołączaj informacji, od której wersji dany\n\t\t\t\t\telement jest dostępny\n".
			"-ns|-nosort|-no-sort\t\tNie sortuj alfabetycznie procedur, struktur i danych\n".
			"-overview <plik>\t\tStronę główną czyta z podanego pliku\n".
			"-stylesheetfile <plik>\t\tPlik z akruszem stylów\n".
			"-top <kodHTML>\t\t\tDołącz podany tekst na górze każdej strony\n".
			"-ud|-undoc|-undocumented\tPrzetwarzaj nieudokumentowane procedury\n".
			"-version\t\t\tDołącz numery wersji (\@version)\n".
			"-windowtitle <napis>\t\tUstaw tytuł okna w przeglądarce\n".
			"\n\nPamiętaj, by wielowyrazowe wartości opcji umieścić w cudzysłowiach!\n\n".
			"Komentarze dokumentujące powinny się zaczynać od ';;' lub '/**', a\n".
			" kończyć na ';;' lub '*/'.\n\n".
			"Przykład:\n\n".
			";;\n".
			"; Ta procedura czyta dane.\n".
			"; \@param CX - liczba bajtów.\n".
			"; \@return DI - adres danych.\n".
			";;\n".
			"procedura01:\n".
			"\t...\n".
			"\tret\n"
			),

		"EN"	=>	"AsmDoc - a program for generating HTML documentation from the given\n".
			" assembly language source files. See http://rudy.mif.pg.gda.pl/~bogdro/inne\n".
			"Author: Bogdan 'bogdro' Drozdowski, bogdandr AT op.pl.\n".
			"Syntax: $0 [options] files\n\n".
			"Options:\n".
			"-author\t\t\t\tAdd \@author information\n".
			"-bottom <HTML-code>\t\tAdd the given text at the bottom of every page\n".
			"-charset|-docencoding <name>\tCharset which will be put in the HTML files\n\t\t\t\t\t(last one is taken)\n".
			"-d <directory>\t\t\tPut resulting files in the given directory\n".
			"-doctitle <kodHTML>\t\tAdd the given title to the overview page\n".
			"-encoding <name>\t\tSource files' character encoding\n".
			"-footer <HTML-code>\t\tAdd the given footer on every page\n".
			"-h|--help|-help|-?\t\tShows the help screen\n".
			"-header <HTML-code>\t\tAdd the given header on every page\n".
			"-helpfile <file>\t\tInculde this help file instead of a default one\n".
			"-ida|-idapro\t\t\tEnable IDA Pro mode\n".
			"-L|--license\t\t\tShows the license for this program\n".
			"-lang <2-letter code>\t\tGenerates the docs in the language specified\n\t\t\t\t\tby the code, eg. PL, EN (if supported)\n".
			"-nocomment\t\t\tSkip tags and description, generate declarations\n".
			"-nodeprecated\t\t\tDo not add \@deprecated elements\n".
			"-nodeprecatedlist\t\tDo not create a list of deprecated elements\n".
			"-nohelp\t\t\t\tDo not generate a help file\n".
			"-noindex\t\t\tDo not generate an index\n".
			"-nonvabar\t\t\tDo not include a navigation bar in the files\n".
			"-nosince\t\t\tDo not add \@since <version> information\n".
			"-ns|-nosort|-no-sort\t\tDo not alphabetically sort procedures, structures and data\n".
			"-overview <file>\t\tRead overview documentation from the given file\n".
			"-stylesheetfile <file>\t\tStylesheet file\n".
			"-top <HTML-code>\t\tAdd the given text at the top of every page\n".
			"-ud|-undoc|-undocumented\tProcess undocumented procedures\n".
			"-version\t\t\tAdd \@version information\n".
			"-windowtitle <text>\t\tSet web browser window title\n".
			"\n\nRemember to put multi-word option values in quotation marks!\n\n".
			"Documentation comments should start with ';;' or '/**' and\n".
			" end with ';;' or '*/'.\n\n".
			"Example:\n\n".
			";;\n".
			"; This procedure reads data.\n".
			"; \@param CX - number of bytes\n".
			"; \@return DI - address of data\n".
			";;\n".
			"procedure01:\n".
			"\t...\n\tret\n"
			,
		);

my %msg_lic = (
		"PL"	=> encode($enc,
			"AsmDoc - program generujący dokumentację HTML z podanych plików źródłowych\n".
			"\tjęzyka assembler. Wejdź na http://rudy.mif.pg.gda.pl/~bogdro/\n".
			"Autor: Bogdan 'bogdro' Drozdowski, bogdandr AT op.pl.\n\n".
			"    Niniejszy program jest wolnym oprogramowaniem; możesz go\n".
			"    rozprowadzać dalej i/lub modyfikować na warunkach Powszechnej\n".
			"    Licencji Publicznej GNU, wydanej przez Fundację Wolnego\n".
			"    Oprogramowania - według wersji 3-ciej tej Licencji lub ktorejś\n".
			"    z późniejszych wersji.\n\n".
			"    Niniejszy program rozpowszechniany jest z nadzieją, iż będzie on\n".
			"    użyteczny - jednak BEZ JAKIEJKOLWIEK GWARANCJI, nawet domyślnej\n".
			"    gwarancji PRZYDATNOŚCI HANDLOWEJ albo PRZYDATNOŚCI DO OKREŚLONYCH\n".
			"    ZASTOSOWAŃ. W celu uzyskania bliższych informacji - Powszechna\n".
			"    Licencja Publiczna GNU.\n\n".
			"    Z pewnością wraz z niniejszym programem otrzymałeś też egzemplarz\n".
			"    Powszechnej Licencji Publicznej GNU (GNU General Public License);\n".
			"    jeśli nie - napisz do Free Software Foundation:\n".
			"		Free Software Foundation\n".
			"		51 Franklin Street, Fifth Floor\n".
			"		Boston, MA 02110-1301\n".
			"		USA\n"
			),

		"EN"	=>	"AsmDoc - a program for generating HTML documentation from the given\n".
			" assembly language source files. See http://rudy.mif.pg.gda.pl/~bogdro/inne\n".
			"Author: Bogdan 'bogdro' Drozdowski, bogdandr AT op.pl.\n\n".
			"    This program is free software; you can redistribute it and/or\n".
			"    modify it under the terms of the GNU General Public License\n".
			"    as published by the Free Software Foundation; either version 3\n".
			"    of the License, or (at your option) any later version.\n\n".
			"    This program is distributed in the hope that it will be useful,\n".
			"    but WITHOUT ANY WARRANTY; without even the implied warranty of\n".
			"    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n".
			"    GNU General Public License for more details.\n\n".
			"    You should have received a copy of the GNU General Public License\n".
			"    along with this program; if not, write to the Free Software Foundation:\n".
			"		Free Software Foundation\n".
			"		51 Franklin Street, Fifth Floor\n".
			"		Boston, MA 02110-1301\n".
			"		USA\n",

		);

my %tag_author = (
		"PL"	=>	"Autor: ",
		"EN"	=>	"Author: ",
		);

my %tag_depr = (
		"PL"	=>	"Przestarzałe: ",
		"EN"	=>	"Deprecated: ",
		);

my %tag_exc = (
		"PL"	=>	"Wywołuje wyjątek: ",
		"EN"	=>	"Throws: ",
		);

my %tag_param = (
		"PL"	=>	"Parametr: ",
		"EN"	=>	"Parameter: ",
		);

my %tag_ret = (
		"PL"	=>	"Zwraca: ",
		"EN"	=>	"Returns: ",
		);

my %tag_see = (
		"PL"	=>	"Zobacz też: ",
		"EN"	=>	"See Also: ",
		);

my %tag_since = (
		"PL"	=>	"Od wersji: ",
		"EN"	=>	"Since: ",
		);

my %tag_ver = (
		"PL"	=>	"Wersja: ",
		"EN"	=>	"Version: ",
		);

my %title_depr = (
		"PL"	=>	"Lista elementów przestarzałych",
		"EN"	=>	"Deprecated List",
		);

my %contents_list = (
		"PL"	=>	"Spis treści",
		"EN"	=>	"Contents",
		);

my %depr_files = (
		"PL"	=>	"Przestarzałe pliki",
		"EN"	=>	"Deprecated Files",
		);

my %depr_fcns = (
		"PL"	=>	"Przestarzałe funkcje",
		"EN"	=>	"Deprecated Functions",
		);

my %depr_var = (
		"PL"	=>	"Przestarzałe zmienne",
		"EN"	=>	"Deprecated Variables",
		);

my %depr_str = (
		"PL"	=>	"Przestarzałe struktury",
		"EN"	=>	"Deprecated Structures",
		);

my %depr_mac = (
		"PL"	=>	"Przestarzałe makra",
		"EN"	=>	"Deprecated Macros",
		);

my %title_constants = (
		"PL"	=>	"Wartości stałe",
		"EN"	=>	"Constant values",
		);

my %title_over = (
		"PL"	=>	"Podsumowanie",
		"EN"	=>	"Overview",
		);

my %fr_alert = (
		"PL"	=>	"Uwaga",
		"EN"	=>	"Frame Alert",
		);

my %nofr = (
		"PL"	=>	"Ten dokument jest przeznaczony do oglądania z wykorzystaniem ramek. ".
				"Jeśil widzisz ten napis, używasz przeglądarki bez obsługi ramek.",
		"EN"	=>	"This document is designed to be viewed using the frames feature. ".
				"If you see this message, you are using a non-frame-capable web client.",
		);

my %linkto = (
		"PL"	=>	"Odnośnik do",
		"EN"	=>	"Link to",
		);

my %nonframe = (
		"PL"	=>	"wersji bez ramek",
		"EN"	=>	"non-frame version",
		);

my %title_index = (
		"PL"	=>	"Indeks",
		"EN"	=>	"Index",
		);

my %var_in_file = (
		"PL"	=>	"zmienna w pliku",
		"EN"	=>	"variable in file",
		);

my %fcn_in_file = (
		"PL"	=>	"funkcja w pliku",
		"EN"	=>	"function in file",
		);

my %str_in_file = (
		"PL"	=>	"struktura w pliku",
		"EN"	=>	"structure in file",
		);

my %mac_in_file = (
		"PL"	=>	"makro w pliku",
		"EN"	=>	"macro in file",
		);

my %title_help = (
		"PL"	=>	"Pomoc",
		"EN"	=>	"Help",
		);

my %file = (
		"PL"	=>	"Plik",
		"EN"	=>	"File",
		);

my %var_sum = (
		"PL"	=>	"Podsumowanie zmiennych",
		"EN"	=>	"Variable summary"
		);

my %fcn_sum = (
		"PL"	=>	"Podsumowanie funkcji",
		"EN"	=>	"Function summary"
		);

my %str_sum = (
		"PL"	=>	"Podsumowanie struktur",
		"EN"	=>	"Structure summary"
		);

my %mac_sum = (
		"PL"	=>	"Podsumowanie makr",
		"EN"	=>	"Macro summary"
		);

my %var_det = (
		"PL"	=>	"Szczegóły zmiennych",
		"EN"	=>	"Variable detail",
		);

my %fcn_det = (
		"PL"	=>	"Szczegóły funkcji",
		"EN"	=>	"Function detail",
		);

my %str_det = (
		"PL"	=>	"Szczegóły struktur",
		"EN"	=>	"Structure detail",
		);

my %mac_det = (
		"PL"	=>	"Szczegóły makr",
		"EN"	=>	"Macro detail",
		);

my %allfiles = (
		"PL"	=>	"Wszystkie pliki",
		"EN"	=>	"All files",
		);

my %skipbar = (
		"PL"	=>	"Przeskocz pasek nawigacyjny",
		"EN"	=>	"Skip navbar",
		);

my %deprec = (
		"PL"	=>	"Przestarzałe",
		"EN"	=>	"Deprecated",
		);

my %constants = (
		"PL"	=>	"Stałe",
		"EN"	=>	"Constants",
		);

my %prev_file = (
		"PL"	=>	"POPRZEDNI PLIK",
		"EN"	=>	"PREVIOUS FILE",
		);

my %next_file = (
		"PL"	=>	"NASTĘPNY PLIK",
		"EN"	=>	"NEXT FILE",
		);

my %summary = (
		"PL"	=>	"PODSUMOWANIE",
		"EN"	=>	"SUMMARY",
		);

my %details = (
		"PL"	=>	"SZCZEGÓŁY",
		"EN"	=>	"DETAILS",
		);

my %name_vars = (
		"PL"	=>	"ZMIENNE",
		"EN"	=>	"VARIABLE",
		);

my %name_fcns = (
		"PL"	=>	"FUNKCJE",
		"EN"	=>	"FUNCTION",
		);

my %name_st = (
		"PL"	=>	"STRUKTURY",
		"EN"	=>	"STRUCTURE",
		);

my %name_mc = (
		"PL"	=>	"MAKRA",
		"EN"	=>	"MACRO",
		);

my %name_frames = (
		"PL"	=>	"RAMKI",
		"EN"	=>	"FRAMES",
		);

my %no_frames = (
		"PL"	=>	"BEZ RAMEK",
		"EN"	=>	"NO FRAMES",
		);

my %helpdoc_msg = (
		"PL"	=>	"<CENTER><H1>Jak zorganizowana jest ta dokumentacja API</H1></CENTER>\n".
				"Ten dokument API (Application Programming Interface) zawiera strony odpowiadające ".
				"elementom paska nawigacyjnego, opisanych poniżej.\n".
				"<H3>Plik</H3><BLOCKQUOTE>\n".
				"<P>Każdy plik ma swoją osobną stronę. Każda z tych stron ma trzy sekcje ".
				"składające się z opisu pliku, tablic z podsumowaniami oraz szczegółowych ".
				"opisów elementów:\n<UL>\n".
				"<LI>Nazwa pliku</LI>\n<LI>Opis pliku<BR><BR><BR></LI>\n".
				"<LI>Podsumowanie zmiennych</LI>\n<LI>Podsumowanie struktur</LI>\n".
				"<LI>Podsumowanie makr</LI>\n<LI>Podsumowanie funkcji<BR><BR><BR></LI>\n".
				"<LI>Szczegóły zmiennych</LI>\n<LI>Szczegóły struktur</LI>\n".
				"<LI>Szczegóły makr</LI>\n<LI>Szczegóły funkcji</LI>\n</UL>\n".
				"Każdy wpis podsumowania zawiera pierwsze zdanie z opisu szczegółowego ".
				"danego elementu. Wpisy w podsumowaniu są alfabetyczne, podobnie jak w opisach ".
				"szczegółowych.</BLOCKQUOTE>\n".
				"<H3>Lista elementów przestarzałych</H3><BLOCKQUOTE>\n".
				"Strona <A HREF=\"deprecated-list.$html_ext\">Lista elementów przestarzałych</A> zawiera wszystkie ".
				"elementy przestarzałe. Nie są one zalecane do użycia, ".
				"zazwyczaj w wyniku ulepszeń. Zwykle podawany jest element zastępczy. ".
				"Elementy przestarzałe mogą zostać usunięte w przyszłych implementacjach.</BLOCKQUOTE>\n".
				"<H3>Indeks</H3><BLOCKQUOTE>\n".
				"<A HREF=\"index-all.$html_ext\">Indeks</A> zawiera alfabetyczną listę wszystkich ".
				"plików, funkcji i zmiennych.</BLOCKQUOTE>\n".
				"<H3>POPRZEDNI PLIK / NASTĘPNY PLIK</H3>\n".
				"Te odnośniki przenoszą do poprzedniego lub następnego pliku.\n".
				"<H3>RAMKI / BEZ RAMEK</H3>\n".
				"Te odnośniki pokazują i chowają ramki HTML. Wszystkie strony są dostępne z ramkami lub bez.\n".
				"<H3>Wartości stałe</H3>\n".
				"Strona <a href=\"constant-values.$html_ext\">Wartości stałe</a> zawiera stałe ".
				"oraz ich wartości.\n",

		"EN"	=>	"<H1>How this API document is organized</H1>\n".
				"This API (Application Programming Interface) document has pages corresponding ".
				"to the items in the navigation bar, described as follows.\n".
				"<H3>File</H3><BLOCKQUOTE>\n".
				"<P>Each file has its own separate page. Each of these pages has three ".
				"sections consisting of a file description, summary tables, and detailed ".
				"member descriptions:\n<UL>\n".
				"<LI>File name</LI>\n<LI>File description</LI>\n".
				"<LI>Variable summary</LI>\n<LI>Structure summary</LI>\n".
				"<LI>Macro summary</LI>\n<LI>Function summary</LI>\n".
				"<LI>Variable details</LI>\n<LI>Structure details</LI>\n".
				"<LI>Macro details</LI>\n<LI>Function details</LI>\n</UL>\n".
				"Each summary entry contains the first sentence from the detailed description ".
				"for that item. The summary entries are alphabetical, as in the detailed ".
				"descriptions.</BLOCKQUOTE>\n".
				"<H3>Deprecated</H3><BLOCKQUOTE>\n".
				"The <A HREF=\"deprecated-list.$html_ext\">deprecated list</A> page lists all of the ".
				"API that have been deprecated. A deprecated API is not recommended for use, ".
				"generally due to improvements, and a replacement API is usually given. ".
				"Deprecated APIs may be removed in future implementations.</BLOCKQUOTE>\n".
				"<H3>Index</H3><BLOCKQUOTE>\n".
				"The <A HREF=\"index-all.$html_ext\">index</A> contains an alphabetic list of all ".
				"files, functions, and variables.</BLOCKQUOTE>\n".
				"<H3>Constants</H3>\n".
				"The <a href=\"constant-values.$html_ext\">constant values</a> page lists the ".
				"constants and their values.\n",
		);

##########################################################################
# Koniec rzeczy do tłumaczenia (end of translation stuff)
##########################################################################

use utf8;

if ( @ARGV == 0 ) {
	print_help();
	exit 1;
}

Getopt::Long::Configure("ignore_case", "ignore_case_always");

my $help='';
my $overview='';
my $encoding='iso-8859-1';
my $d=curdir();
my $version='';
my $author='';
my $windowtitle='SE Basic IV API documentation (generated by AsmDoc)';
my $doctitle='';
my $header='';
my $footer='';
my $top='';
my $bottom='';
my $nocomment='';
my $nodeprecated='';
my $nosince='';
my $nodeprecatedlist='';
my $noindex='';
my $charset='utf-8';
my $stylesheetfile='';
my $lic='';
my $nohelp='';
my $helpfile='';
my $nonavbar='';
my $undoc='';
my $nosort='';
my $idapro='';

if ( !GetOptions (
	'author'		=> \$author,
	'bottom=s'		=> \$bottom,
	'charset|docencoding=s'	=> \$charset,
	'd=s'			=> \$d,
	'doctitle=s'		=> \$doctitle,
	'encoding=s'		=> \$encoding,
	'footer=s'		=> \$footer,
	'h|help|?'		=> \$help,
	'header=s'		=> \$header,
	'helpfile=s'		=> \$helpfile,
	'ida|idapro'		=> \$idapro,
	'license|licence|l'	=> \$lic,
	'lang=s'		=> \$language,
	'nocomment'		=> \$nocomment,
	'nodeprecated'		=> \$nodeprecated,
	'nodeprecatedlist'	=> \$nodeprecatedlist,
	'nohelp'		=> \$nohelp,
	'noindex'		=> \$noindex,
	'nonavbar'		=> \$nonavbar,
	'nosince'		=> \$nosince,
	'no-sort|nosort|ns'	=> \$nosort,
	'overview=s'		=> \$overview,
	'stylesheetfile=s'	=> \$stylesheetfile,
	'top=s'			=> \$top,
	'undocumented|undoc|ud'	=> \$undoc,
	'version'		=> \$version,
	'windowtitle=s'		=> \$windowtitle,
	)
   ) {
	print_help();
	exit 2;
}

$language =~ tr/a-z/A-Z/;

if ( $lic ) {
	print $msg_lic{$language};
	exit 1;
}

# jesli podano "HELP" na linii polecen lub nie podano plikow, wyswietlic skladnie wywolania
# (if "HELP" is on the command line or no files are given, print syntax)
if ( $help || @ARGV == 0 ) {
	print_help();
	exit 1;
}

# sprawdzic, czy wszystkie podane pliki sa odczytywalne, a katalogi zapisywalne.
# (check if all the given files are readable and directories writeable)

if ( $stylesheetfile ne "" && (-d $stylesheetfile || ! -r $stylesheetfile) ) {

	print "$0: $stylesheetfile: $msg_file_noread{$language}\n";
	exit 3;
}

if ( $overview ne "" && (-d $overview || ! -r $overview) ) {

	print "$0: $overview: $msg_file_noread{$language}\n";
	exit 3;
}

if ( $helpfile ne "" && (-d $helpfile || ! -r $helpfile) ) {

	print "$0: $helpfile: $msg_file_noread{$language}\n";
	exit 3;
}

# tworzenie katalogu, jesli potrzeba (creating the directory if necessary)
if ( ! -e $d ) {
	my @dirs = splitdir $d;
	my $i = 0;
	foreach (@dirs) {
		if ( ! -e $_ ) {
			mkdir $_ or die "$0: mkdir $d ('$_'): $!";
			chmod S_IRWXU, $_;
		}
		chdir $_ or die "$0: chdir $d ('$_'): $!";
		$i++;
	}
	for ( ; $i>0; $i-- ) { chdir updir(); }
}

if ( ! -w $d ) {
	print "$0: $msg_dir_nowrite{$language} '$d'.\n";
	exit 3;
}

# kopiowanie arkusza stylów (copy the style sheet)
if ( $stylesheetfile ne "" && $d ne curdir() ) {

	my ($vol, $dir, $f);
	($vol, $dir, $f) = splitpath $stylesheetfile;
	copy($stylesheetfile, catpath($vol, rel2abs($d, rootdir()), $f));
	$stylesheetfile = $f;
}

# kopiowanie pliku podsumowania (copy the overview file)
if ( $overview ne "" && $d ne curdir() ) {

	my ($vol, $dir, $f);
	($vol, $dir, $f) = splitpath $overview;
	copy($overview, catpath($vol, rel2abs($d, rootdir()), $f));
	$overview = $f;
}

# kopiowanie pliku pomocy (copy the help file)
if ( $helpfile ne "" && $d ne curdir() ) {

	my ($vol, $dir, $f);
	($vol, $dir, $f) = splitpath $helpfile;
	copy($helpfile, catpath($vol, rel2abs($d, rootdir()), $f));
	$helpfile = $f;
}

my ($disc, $directory, undef) = splitpath(cwd(), 1);
chdir $d;
my $docroot = cwd();

my @files = sort @ARGV;
my %files_orig;
foreach my $p (@files) {
	my $newf;
	($newf = $p) =~ s/\./-/go;
	$newf = (splitpath $newf)[2];
	$newf = encode($charset, $newf);
	$files_orig{$newf} = (splitpath $p)[2];	# =$p;
}

$charset     =~ tr/A-Z/a-z/;

# Tagi mogą się zaczynać od '@' (Java) lub '\' (C/C++).
# Tags can start with '@' (Java) or '\' (C/C++).

# http://java.sun.com/j2se/1.5.0/docs/tooldocs/windows/javadoc.html#javadoctags
my %tags_subst = (
	"author"	=> $tag_author{$language},
	"deprecated"	=> $tag_depr{$language},
	"exception"	=> $tag_exc{$language},
	"param"		=> $tag_param{$language},
	"return"	=> $tag_ret{$language},
	"see"		=> $tag_see{$language},
	"since"		=> $tag_since{$language},
	"throws"	=> $tag_exc{$language},
	"version" 	=> $tag_ver{$language},
	);

# The first hashes go like this:
# file_description, file_variables, file_functions, file_variables_description,
# file_function_description, file_variable_values, file_structures, file_structrues_description,
# file_structure_variables, file_structure_variables_description, file_structure_variables_values
# file_macros, file_macros_description
my (%files_descr, %files_vars, %files_funcs, %files_vars_descr, %files_funcs_descr,
	%files_vars_values, %files_struct, %files_struct_descr, %files_struct_vars,
	%files_struct_vars_descr, %files_struct_vars_values,
	%files_macros, %files_macros_descr,
	%files_funcs_vars, %files_funcs_vars_descr, %files_funcs_vars_values,
	%files_funcs_vars_types);

# =================== Czytanie plikow wejsciowych (reading input files) =================
FILES: foreach my $p (@files) {

	# Klucz w tablicy haszowanej to nazwa pliku z myślnikami zamiast kropek.
	# Hash array key is the filename with dashes instead of dots.
	my $key;
	$key = (splitpath $p)[2];
	$key =~ s/\./-/go;

	# Aktualna zmienna (lub funkcja) i jej opis.
	# Current variable (or function) and its description.
	# (current_variable, current_variable_description, current_variable_value, function,
	#	type, structure, inside_struc, structure name, macro)
	my ($current_variable, $current_variable_descr, $current_variable_value, $function, $type,
		$structure, $inside_struc, $struc_name, $macro, $inside_func, $func_name,
		$have_descr, $current_type);
	$type = 0;
	$function = 0;
	$structure = 0;
	$inside_struc = 0;
	$macro = 0;
	$struc_name = "";
	$inside_func = 0;
	$func_name = "";

	$files_vars{$key} = ();
	$files_funcs{$key} = ();
	$files_struct{$key} = ();
	$files_macros{$key} = ();

	open(my $asm, "<:encoding($encoding)", catpath($disc, $directory, $p)) or
		die "$0: ".catpath($disc, $directory, $p).": $!\n";

	$have_descr = 0;
	# znaleźć opis pliku, jeśli jest. (find file description, if it exists)
	MAIN_DESCR: while ( <$asm> ) {

		next if (/^\s*$/o && ! $idapro); # to leave when an empty line is encountered (IDA Pro)
		if (($undoc) && ($have_descr == 0))
		{
			$type = 1 if ( /^\s*;;/o && $type == 0 );
			$type = 2 if ( /^\s*\/\*\*/o && $type == 0 );
			$files_descr{$key} .= "" if ($type == 0);
			$type = 1 if ($type == 0);
		}
		$type = 1 if ( /^\s*;;/o && $type == 0 );
		$type = 2 if ( /^\s*\/\*\*/o && $type == 0 );

		if ( $type == 1 ) {
			last MAIN_DESCR if ( $undoc && (! /^\s*;/o) && $have_descr );
			last MAIN_DESCR if ( ((! /^\s*;/o) || /^\s*;;\s*$/o) && $have_descr );
		} elsif ( $type == 2 ) {
			last MAIN_DESCR if /^\s*\*\/\s*$/o;
		}

		# odrzucamy wiodące znaki komentarza na początku linii
		# (removing leading comment characters from the beginning of the line)
		s/^\s*;+//o  if $type == 1;
		s/^\s*\/?\*+//o if $type == 2;

		$files_descr{$key} .= $_ if $type != 0;
		$have_descr = 1;
	}

	if ( ! defined $_ ) { close $asm; next FILES; }

	if ( /^\s*;;\s*$/o || /^\s*\*\/\s*$/o ) {
		$_ = <$asm>;
		if ( ! defined $_ )
		{
			close $asm;
			next FILES;
		}
	}

	$files_descr{$key} = tags($files_descr{$key});

	# Jesli pierwszy komentarz nie dotyczył pliku (if the first comment wasn't about the file)
	if ( ! /^\s*$/o ) {
		# zmienna lub stała typu 1 (variable/type 1 constant) (xxx equ yyy)
		if ( /^\s*([\.\w]+)(:|\s+)\s*(times\s|(d|r|res)[bwudpfqt]\s|equ\s|=)+\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/io )
		{
			$files_vars{$key}[++$#{$files_vars{$key}}] = $1;
			$files_vars_descr{$key}{$1} = $files_descr{$key};

			$function = 0;
			my $value = $5;
			if ( $3 =~ /equ/io || $3 =~ /=/o )
			{
				$files_vars_values{$key}{$1} = $value;
			}
			else
			{
				$files_vars_values{$key}{$1} = "";
			}
			undef($files_descr{$key});
		}
		# stala typu 2 (type 2 constant) (.equ xxx yyy)
		elsif ( /^\s*\.equ?\s*(\w+)\s*,\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/io )
		{
			$files_vars{$key}[++$#{$files_vars{$key}}] = $1;
			$files_vars_descr{$key}{$1} = $files_descr{$key};
			$files_vars_values{$key}{$1} = $2;
			undef($files_descr{$key});
		}
		# początek tradycyjnej procedury (traditional procedure beginning)
		elsif ( /^\s*(\w+)(\s*:|\s+(proc|near|far){1,2})\s*($|;.*$)/io )
		{
			$files_funcs{$key}[++$#{$files_funcs{$key}}] = $1;
			$files_funcs_descr{$key}{$1} = $files_descr{$key};
			$func_name = $1;
			# enabling this makes the script fail on procedures that don't have
			# an explicit end, because once such a procedure is encountered,
			# everything from that point is taken as a part of the procedure, because
			# $inside_func is reset to zero only when /endp/ was found
			#$inside_func = 1;
			undef($files_descr{$key});
		}
		# procedura w składni HLA (HLA syntax procedure)
		elsif ( /^\s*proc(edure)?\s*(\w+)/io )
		{
			$files_funcs{$key}[++$#{$files_funcs{$key}}] = $2;
			$files_funcs_descr{$key}{$2} = $files_descr{$key};
			$func_name = $2;
			$inside_func = 1;
			undef($files_descr{$key});
		}
		# struktury (structures)
		elsif ( /^\s*struc\s+(\w+)/io )
		{
			$files_struct{$key}[++$#{$files_struct{$key}}] = $1;
			$files_struct_descr{$key}{$1} = $files_descr{$key};
			$structure = 1;
			$inside_struc = 1;
			$struc_name = $1;
			undef($files_descr{$key});
		}
		# makra (macros)
		elsif ( /^\s*((\%i?)?|\.)macro\s+(\w+)/io )
		{
			$files_macros{$key}[++$#{$files_macros{$key}}] = $3;
			$files_macros_descr{$key}{$3} = $files_descr{$key};
			undef($files_descr{$key});
		}
		elsif ( /^\s*(\w+)\s+macro/io )
		{
			$files_macros{$key}[++$#{$files_macros{$key}}] = $1;
			$files_macros_descr{$key}{$1} = $files_descr{$key};
			undef($files_descr{$key});
		}
		# structure instances in NASM
		elsif ( /^\s*(\w+):?\s+istruc\s+(\w+)/io )
		{
			$files_vars{$key}[++$#{$files_vars{$key}}] = $1;
			$files_vars_descr{$key}{$1} = $files_descr{$key};
			undef($files_descr{$key});
		}
		# dup()
		elsif ( /^\s*(\w+)\:?\s+(d([bwudpfqt])\s+\w+\s*\(?\s*\bdup\b.*)/io )
		{
			$files_vars{$key}[++$#{$files_vars{$key}}] = $1;
			$files_vars_descr{$key}{$1} = $files_descr{$key};
			undef($files_descr{$key});
		}
		# MASM PROC
		elsif ( /^\s*(\w+):?\s+(proc)/io )
		{
			$files_funcs{$key}[++$#{$files_funcs{$key}}] = $1;
			$files_funcs_descr{$key}{$1} = $files_descr{$key};
			$inside_func = 1;
			$func_name = $1;
			$function = 2;
			undef($files_descr{$key});
		}
		# MASM STRUCTURE
		elsif ( /^\s*(\w+):?\s+(struc)/io )
		{
			$files_struct{$key}[++$#{$files_struct{$key}}] = $1;
			$files_struct_descr{$key}{$1} = $files_descr{$key};
			$structure = 1;
			$inside_struc = 1;
			$struc_name = $1;
			undef($files_descr{$key});
		}
		# some other type (like FASM structure instances)
		elsif ( /^\s*(\w+):?\s+(\w+)/io )
		{
			$files_vars{$key}[++$#{$files_vars{$key}}] = $1;
			$files_vars_descr{$key}{$1} = $files_descr{$key};
			undef($files_descr{$key});
		}
	}

	while ( <$asm> )
	{
		undef ($current_variable);
		undef ($current_variable_descr);
		undef ($current_variable_value);
		# IDA-Pro Subroutine comment substitution (MASM PROC)
		if ($undoc && ( /^;.*(S\s+U\s+B)/oi ))
		{
			$_ = ";; ";
		}
		# MASM Proc End
		if ( $inside_func && /^\s*(\w+):?\s+(endp)/io )
		{
			$inside_func = 0;
			$function = 0;
		}
		if ( $inside_func && $idapro )
		{
			$current_type = "";
			if ( /;/o )
			{
				$current_variable_descr = $_;
				$current_variable_descr =~ s/.*;//o;
			}
			else
			{
				$current_variable_descr = "";
			}
			# type 3 constant (var_15 = byte ptr -15h, arg_0 = word ptr 2)
			if ( /^\s*((arg|var)\w+)\s+\=\s+?([\w\s\-\+]+)[;]?/io )
			{
				# IDA-Pro when inside function arguments and variables.
				$current_variable = $1;
				$current_variable_value = $3;
				$current_type = $2;
			}
			if ($current_type ne "")
			{
				$files_funcs_vars{$key}{$func_name}[++$#{$files_funcs_vars{$key}{$func_name}}] = $current_variable;
				$files_funcs_vars_values{$key}{$func_name}{$current_variable} = $current_variable_value;
				$files_funcs_vars_descr{$key}{$func_name}{$current_variable} = $current_variable_descr;
				$current_variable =~ s/^\.//o;
				$files_funcs_vars_types{$key}{$func_name}{$current_variable} = $current_type;
				undef ($current_variable_descr);
			}
		}
		if ( $inside_struc && ( /^\s*(endstruc|\})/io || /^\s*(\w+):?\s+(ends)/io ) )
		{
			$structure = 0;
			$inside_struc = 0;
		}

		# MASM PROC (undoc)
 		if ( $undoc && /^\s*(\w+):?\s+(proc)/io )
		{
			$files_funcs{$key}[++$#{$files_funcs{$key}}] = $1;
			#$files_descr{$key} = "";
			#$files_funcs_descr{$key}{$1} = $files_descr{$key};
			$function = 2;
			$inside_func = 1;
			$func_name = $1;
 		}

		# szukać znakow zaczynających komentarz (look for characters which start a comment)
		next if ! ( /^\s*;;/o || /^\s*\/\*\*/o );

		$type = 1 if /^\s*;;/o;
		$type = 2 if /^\s*\/\*\*/o;
		$current_variable_descr = $_;
		$current_variable_descr =~ s/^\s*;+//o if $type == 1;
		$current_variable_descr =~ s/^\s*\/?\*+//o if $type == 2;

		$have_descr = 0;
		# Wszystko do pierwszej niezakomentowanej linii skopiować do aktualnego opisu.
		# (Put all up to the first non-comment line into the current description).
		while ( <$asm> )
		{
			next if /^\s*$/o;
			# to leave when an empty line is encountered (IDA Pro)
			if (/^\s*$/o && ! $idapro) {$_ = ";;\n"; last;}

			if ( $type == 1 ) {
				last if ( (! /^\s*;/o) || /^\s*;;\s*$/o && $have_descr );
			} elsif ( $type == 2 ) {
				last if /^\s*\*\/\s*$/o;
			}

			# odrzucamy wiodące znaki komentarza na początku linii
			# (removing leading comment characters from the beginning of the line)
			s/^\s*;+//o  if $type == 1;
			s/^\s*\/?\*+//o if $type == 2;

			$current_variable_descr .= $_ if $type != 0;
			$have_descr = 1;
		}
		if ( ! defined $_ )
		{
			close $asm;
			next FILES;
		}
		if ( $inside_func && $idapro )
		{
			$current_type = "";
			if ( /;/o )
			{
				$current_variable_descr = $_;
				$current_variable_descr =~ s/.*;//o;
			}
			else
			{
				$current_variable_descr = "";
			}
			# type 3 constant (var_15 = byte ptr -15h, arg_0 = word ptr 2)
			if ( /^\s*((arg|var)\w+)\s+\=\s+?([\w\s\-\+]+)[;]?/io )
			{
				# IDA-Pro when inside function arguments and variables.
				$current_variable = $1;
				$current_variable_value = $3;
				$current_type = $2;
			}
			if ($current_type ne "")
			{
				$files_funcs_vars{$key}{$func_name}[++$#{$files_funcs_vars{$key}{$func_name}}] = $current_variable;
				$files_funcs_vars_values{$key}{$func_name}{$current_variable} = $current_variable_value;
				$files_funcs_vars_descr{$key}{$func_name}{$current_variable} = $current_variable_descr;
				$current_variable =~ s/^\.//o;
				$files_funcs_vars_types{$key}{$func_name}{$current_variable} = $current_type;
				undef ($current_variable_descr);
			}
		}
		if ( /^\s*;;\s*$/o || /^\s*\*\/\s*$/o ) {
			$_ = <$asm>;
			if ( ! defined $_ )
			{
				close $asm;
				next FILES;
			}
		}
		while ( /^\s*$/o )
		{
			$_ = <$asm>;
			if ( ! defined $_ )
			{
				close $asm;
				next FILES;
			}
		}

		# znajdowanie nazwy zmiennej lub funkcji (finding the name of the variable or function)
		# zmienna lub stała typu 1 (variable/type 1 constant) (xxx equ yyy)
		if ( /^\s*([\.\w]+)(:|\s+)\s*(times\s|(d|r|res)[bwudpfqt]\s|equ\s|=)+\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/io )
		{
			$current_variable = $1;
			$function = 0;
			my $value = $5;
			if ( $3 =~ /equ/io || $3 =~ /=/o )
			{
				$current_variable_value = $value;
			}
			else
			{
				$current_variable_value = "";
			}
		}
		# stała typu 2 (type 2 constant) (.equ xxx yyy)
		elsif ( /^\s*\.equ?\s*(\w+)\s*,\s*([\w\,\.\+\-\s\*\/\\\'\"\!\@\#\$\%\^\&\\(\)\{\}\[\]\<\>\?\=\|]*)/io )
		{
			$current_variable = $1;
			$function = 0;
			$current_variable_value = $2;
		}
		# początek tradycyjnej procedury (traditional procedure beginning)
		elsif ( /^\s*(\w+)(:|\s*(proc|near|far){1,2})\s*($|;.*$)/io )
		{
			$current_variable = $1;
			$function = 1;
			$current_variable_value = "";
			$func_name = $1;
			# enabling this makes the script fail on procedures that don't have
			# an explicit end, because once such a procedure is encountered,
			# everything from that point is taken as a part of the procedure, because
			# $inside_func is reset to zero only when /endp/ was found
			#$inside_func = 1;
		}
		# procedura w składni HLA (HLA syntax procedure)
		elsif ( /^\s*proc(edure)?\s*(\w+)/io )
		{
			$current_variable = $2;
			$function = 1;
			$current_variable_value = "";
			$func_name = $2;
			$inside_func = 1;
		}
		# struktury (structures)
		elsif ( /^\s*struc\s+(\w+)/io )
		{
			$struc_name = $1;
			$function = 0;
			$structure = 1;
			$inside_struc = 0;
		}
		# makra (macros)
		elsif ( /^\s*((\%i?)?|\.)macro\s+(\w+)/io )
		{
			$current_variable = $3;
			$macro = 1;
			$current_variable_value = "";
		}
		elsif ( /^\s*(\w+)\s+macro/io )
		{
			$current_variable = $1;
			$macro = 1;
			$current_variable_value = "";
		}
		# structure instances in NASM
		elsif ( /^\s*(\w+):?\s+istruc\s+(\w+)/io )
		{
			$current_variable = $1;
			$current_variable_value = "";
		}
		# dup()
		elsif ( /^\s*(\w+)\:?\s+(d([bwudpfqt])\s+\w+\s*\(?\s*\bdup\b.*)/io )
		{
			$current_variable = $1;
			$current_variable_value = "";
		}
		# MASM PROC
		elsif ( /^\s*(\w+):?\s+(proc)/io )
		{
			$function = 2;
			$current_variable_value = "";
			$inside_func = 1;
		}
		# MASM STRUCTURE
		elsif ( /^\s*(\w+):?\s+(struc)/io )
		{
			$struc_name = $1;
			$structure = 1;
			$inside_struc = 0;
			$current_variable_value = "";
		}
		# some other type (like FASM structure instances)
		elsif ( /^\s*(\w+):?\s+(\w+)/io )
		{
			$current_variable = $1;
			$current_variable_value = "";
		}
		else
		{
			while ( /^\s*$/o )
			{
				$_ = <$asm>;
				if ( ! defined $_ )
				{
					close $asm;
					next FILES;
				}
			}
			if ( /^\s*$/o && $idapro )
			{
				$current_variable = " ";
				$current_variable_value = "";
			}
			elsif ( (! /^\s*end\s*$/io) || (! $idapro) )
			{
				s/[\r\n]*$//o;
				print encode($enc, "$0: $p: '$_' ???\n");
			}
			next;
		}

		if ( defined ($current_variable_descr) )
		{
			$current_variable_descr = tags($current_variable_descr);
		}

		if ( defined ($current_variable_value) )
		{
			# {@value}
			$current_variable_descr =~ s/\{\s*(\@|\\)value\s*\}/$current_variable_value/ig;
		}

		if ( $function )
		{
			$files_funcs{$key}[++$#{$files_funcs{$key}}] = $current_variable;
			$files_funcs_descr{$key}{$current_variable} = $current_variable_descr;
			if ( $function == 2 )
			{
				$files_funcs_vars{$key}{$func_name} = ();
				$files_funcs_vars_descr{$key}{$func_name} = ();
				$files_funcs_vars_values{$key}{$func_name} = ();
				$inside_func = 1;
				$function = 0;
			}
		}
		elsif ( $structure )
		{
			$files_struct{$key}[++$#{$files_struct{$key}}] = $struc_name;
			$files_struct_descr{$key}{$struc_name} = $current_variable_descr;
			$files_struct_vars{$key}{$struc_name} = ();
			$files_struct_vars_descr{$key}{$struc_name} = ();
			$files_struct_vars_values{$key}{$struc_name} = ();
			$inside_struc = 1;
			$structure = 0;
		}
		elsif ( $macro )
		{
			$files_macros{$key}[++$#{$files_macros{$key}}] = $current_variable;
			$files_macros_descr{$key}{$current_variable} = $current_variable_descr;
			$macro = 0;
		}
		else
		{
			if ( $inside_struc )
			{
				$files_struct_vars{$key}{$struc_name}[++$#{$files_struct_vars{$key}{$struc_name}}] = $current_variable;
				$files_struct_vars_descr{$key}{$struc_name}{$current_variable} = $current_variable_descr;
				$files_struct_vars_values{$key}{$struc_name}{$current_variable} = $current_variable_value;
			}
			elsif ( $inside_func )
			{
				$files_funcs_vars{$key}{$func_name}[++$#{$files_funcs_vars{$key}{$func_name}}] = $current_variable;
				$files_funcs_vars_descr{$key}{$func_name}{$current_variable} = $current_variable_descr;
				$files_funcs_vars_values{$key}{$func_name}{$current_variable} = $current_variable_value;
				$current_variable =~ s/^\.//o;
				$files_funcs_vars_types{$key}{$func_name}{$current_variable} = $current_type;
			}
			else
			{
				$files_vars{$key}[++$#{$files_vars{$key}}] = $current_variable;
				$files_vars_descr{$key}{$current_variable} = $current_variable_descr;
				$files_vars_values{$key}{$current_variable} = $current_variable_value;
			}
		}
	}

	close $asm;

	# Sort names
	if ( ! $nosort )
	{
		if ( $#{$files_vars{$key}} >= 0 ) {
			my @sorted = sort @{$files_vars{$key}};
			$files_vars{$key} = ();
			foreach (@sorted) { push @{$files_vars{$key}}, $_; }
		}

		if ( $#{$files_funcs{$key}} >= 0 ) {
			my @sorted = sort @{$files_funcs{$key}};
			$files_funcs{$key} = ();
			foreach (@sorted) { push @{$files_funcs{$key}}, $_; }
		}

		if ( $#{$files_struct{$key}} >= 0 )
		{
			my @sorted = sort @{$files_struct{$key}};
			$files_struct{$key} = ();
			foreach (@sorted) { push @{$files_struct{$key}}, $_; }
		}

		if ( $#{$files_macros{$key}} >= 0 )
		{
			my @sorted = sort @{$files_macros{$key}};
			$files_macros{$key} = ();
			foreach (@sorted) { push @{$files_macros{$key}}, $_; }
		}
	}
}

# zamiana tagu {@value} (changing the {@value} tag)
foreach my $k (keys %files_descr) {

	if ( $files_descr{$k} =~ /\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/io ) {
		my $variable = $2;
		if ( defined($files_vars_values{$k}{$variable}) ) {
			s/\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/$files_vars_values{$k}{$variable}/gi;
		}
	}
}
foreach my $k (keys %files_vars_descr) {

	foreach ($files_vars_descr{$k}) {
		if ( /\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/io ) {
			my $variable = $2;
			if ( defined($files_vars_values{$k}{$variable}) ) {
				s/\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/$files_vars_values{$k}{$variable}/gi;
			}
		}
	}
}
foreach my $k (keys %files_funcs_descr) {

	foreach ($files_funcs_descr{$k}) {
		if ( /\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/io ) {
			my $variable = $2;
			if ( defined($files_vars_values{$k}{$variable}) ) {
				s/\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/$files_vars_values{$k}{$variable}/gi;
			}
		}
	}
}
foreach my $k (keys %files_struct_descr) {

	foreach ($files_struct_descr{$k}) {
		if ( /\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/io ) {
			my $variable = $2;
			if ( defined($files_vars_values{$k}{$variable}) ) {
				s/\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/$files_vars_values{$k}{$variable}/gi;
			}
		}
	}
}
foreach my $k (keys %files_macros_descr) {

	foreach ($files_macros_descr{$k}) {
		if ( /\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/io ) {
			my $variable = $2;
			if ( defined($files_vars_values{$k}{$variable}) ) {
				s/\{(\@|\\)value\s+([\w\.\#]+\s*)?(\w+)\s*\}/$files_vars_values{$k}{$variable}/gi;
			}
		}
	}
}

# zmiana kropek w nazwach na myślniki, by nie tworzyć nazw z wieloma kropkami
# (changing dots to dashes in file names, so there won't be names with multiple dots)
foreach (@files) { s/\./-/go; }

# ============================ deprecated-list.html ===================================

my $have_const = 0;

# sprawdzamy, czy będą jakieś stałe (dla paska nawigacyjnego)
# (check if there will be any constants [for the navigation bar])
ST: foreach my $p (@files) {
	$p = (splitpath $p)[2];
	# najpierw sprawdzić, czy w danym pliku były jakiekolwiek stałe
	# (first check if there were any constants in the file)
	foreach (%{$files_vars_values{$p}}) {
		if ( defined($files_vars_values{$p}{$_}) && $files_vars_values{$p}{$_} ne "" ) {
			$have_const = 1;
			last ST;
		}
	}
}
if ( $have_const ) { open(my $xxx, ">constant-values.$html_ext"); close $xxx; } # touch constant-values.html;

# generować plik tylko, gdy potrzebny (generate the file only if necessary)
my ($depr_files, $depr_funcs, $depr_vars, $depr_str, $depr_ma);

$depr_files = 0;
foreach (keys %files_descr) {
	if ( $files_descr{$_} =~ /(\@|\\)deprecated/io ) {
		$depr_files = 1;
		last;
	}
}
$depr_vars = 0;
ZM: foreach my $k (keys %files_vars_descr) {

	foreach ( %{$files_vars_descr{$k}} ) {
		if ( defined($files_vars_descr{$k}{$_}) &&
			$files_vars_descr{$k}{$_} =~ /(\@|\\)deprecated/io ) {
			$depr_vars = 1;
			last ZM;
		}
	}
}
$depr_funcs = 0;
FC: foreach my $k (keys %files_funcs_descr) {

	foreach ( %{$files_funcs_descr{$k}} ) {
		if ( defined($files_funcs_descr{$k}{$_}) &&
			$files_funcs_descr{$k}{$_} =~ /(\@|\\)deprecated/io ) {
			$depr_funcs = 1;
			last FC;
		}
	}
}
$depr_str = 0;
ST: foreach my $k (keys %files_struct_descr) {

	foreach ( %{$files_struct_descr{$k}} ) {
		if ( defined($files_struct_descr{$k}{$_}) &&
			$files_struct_descr{$k}{$_} =~ /(\@|\\)deprecated/io ) {
			$depr_str = 1;
			last ST;
		}
	}
}
$depr_ma = 0;
MA: foreach my $k (keys %files_macros_descr) {

	foreach ( %{$files_macros_descr{$k}} ) {
		if ( defined($files_macros_descr{$k}{$_}) &&
			$files_macros_descr{$k}{$_} =~ /(\@|\\)deprecated/io ) {
			$depr_ma = 1;
			last MA;
		}
	}
}

if ( ! $nodeprecatedlist && ( $depr_files || $depr_vars || $depr_funcs || $depr_str || $depr_ma ) ) {

	open(my $deprec, ">:encoding($charset)", "deprecated-list.$html_ext")
		or die "$0: deprecated-list.$html_ext: $!\n";

	print $deprec "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$windowtitle - $title_depr{$language}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $deprec "<LINK REL=\"stylesheet\" HREF=\"stylesheet.css\" TYPE=\"text/css\">\n";
	} else {
		print $deprec "<LINK REL=\"stylesheet\" HREF=\"$stylesheetfile\" TYPE=\"text/css\">\n";
	}
	print $deprec "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, "deprecated-list.$html_ext")."\n".
		"<HR><CENTER><H2><B>$title_depr{$language}</B></H2></CENTER>\n<HR SIZE=\"4\" NOSHADE>\n".
		"<B>$contents_list{$language}</B>\n<UL>\n";

	if ( $depr_files ) {
		print $deprec "<LI><A HREF=\"#file\">$depr_files{$language}</A></LI>\n";
	}
	if ( $depr_funcs ) {
		print $deprec "<LI><A HREF=\"#function\">$depr_fcns{$language}</A></LI>\n";
	}
	if ( $depr_vars ) {
		print $deprec "<LI><A HREF=\"#variable\">$depr_var{$language}</A></LI>\n";
	}
	if ( $depr_str ) {
		print $deprec "<LI><A HREF=\"#structure\">$depr_str{$language}</A></LI>\n";
	}
	if ( $depr_ma ) {
		print $deprec "<LI><A HREF=\"#macro\">$depr_mac{$language}</A></LI>\n";
	}
	print $deprec "</UL>\n";

	my $descr;

	if ( $depr_files ) {
		print $deprec "<A NAME=\"file\" ID=\"file\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"$depr_files{$language}\">".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\"><B>$depr_files{$language}</B></TH></TR>\n";
		foreach (@files) {
			$_ = (splitpath $_)[2];
			if ( defined($files_descr{$_}) && $files_descr{$_} =~ /(\@|\\)deprecated/io ) {

				# Bierzemy tylko informację o przedawnieniu
				# (take only the deprecation information)
				($descr = $files_descr{$_}) =~ s/.*(\@|\\)deprecated\s+(.*)(\@\w|\\\w|$)/$2/i;

				print $deprec "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
					"<TD><A HREF=\"$_.$html_ext\">$files_orig{$_}</A>\n<BR>\n".
					"<I>$descr</I></TD></TR>\n";
			}
		}
		print $deprec "</TABLE>\n";
	}

	if ( $depr_funcs ) {
		print $deprec "<A NAME=\"function\" ID=\"function\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"$depr_fcns{$language}\">".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\"><B>$depr_fcns{$language}</B></TH></TR>\n";

		foreach my $p (@files) {
			$p = (splitpath $p)[2];
			if ( defined($files_funcs_descr{$p}) ) {

				foreach (%{$files_funcs_descr{$p}}) {

					next if ( ! defined($files_funcs_descr{$p}{$_}) ||
						$files_funcs_descr{$p}{$_} !~ /(\@|\\)deprecated/io );
					# Bierzemy tylko informację o przedawnieniu
					# (take only the deprecation information)
					$descr = $files_funcs_descr{$p}{$_};
					$descr =~ s/^[^\@\\]*//o;
					while ( $descr !~ /^[\@\\]deprecated/io ) { $descr =~ s/^[\@\\][^\@\\]+//o; }
					$descr =~ /(\@|\\)deprecated\s+([^\@\\]*)(\@\w.*|\\\w.*|$)/io;
					$descr = $2;

					my $no_under;
					($no_under = $_) =~ s/^_+//o;
					print $deprec "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
						"<TD><A HREF=\"$p.$html_ext#$no_under\">$files_orig{$p} -- $_</A>\n<BR>\n".
						"<I>$descr</I></TD></TR>\n";
				}
			}
		}
		print $deprec "</TABLE>\n";
	}

	if ( $depr_vars ) {
		print $deprec "<A NAME=\"variable\" ID=\"variable\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"$depr_var{$language}\">".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\"><B>$depr_var{$language}</B></TH></TR>\n";

		foreach my $p (@files) {
			$p = (splitpath $p)[2];
			if ( defined($files_vars_descr{$p}) ) {

				foreach (%{$files_vars_descr{$p}}) {

					next if ( ! defined($files_vars_descr{$p}{$_}) ||
						$files_vars_descr{$p}{$_} !~ /(\@|\\)deprecated/io );
					# Bierzemy tylko informację o przedawnieniu
					# (take only the deprecation information)
					$descr = $files_vars_descr{$p}{$_};
					$descr =~ s/^[^\@\\]*//o;
					while ( $descr !~ /^[\@\\]deprecated/io ) { $descr =~ s/^[\@\\][^\@\\]+//o; }
					$descr =~ /(\@|\\)deprecated\s+([^\@\\]*)(\@\w.*|\\\w.*|$)/io;
					$descr = $2;

					my $no_under;
					($no_under = $_) =~ s/^_+//o;
					print $deprec "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
						"<TD><A HREF=\"$p.$html_ext#$no_under\">$files_orig{$p} -- $_</A>\n<BR>\n".
						"<I>$descr</I></TD></TR>\n";
				}
			}
		}
		print $deprec "</TABLE>\n";
	}

	if ( $depr_str ) {
		print $deprec "<A NAME=\"structure\" ID=\"structure\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"$depr_fcns{$language}\">".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\"><B>$depr_str{$language}</B></TH></TR>\n";

		foreach my $p (@files) {
			$p = (splitpath $p)[2];
			if ( defined($files_struct_descr{$p}) ) {

				foreach (%{$files_struct_descr{$p}}) {

					next if ( ! defined($files_struct_descr{$p}{$_}) ||
						$files_struct_descr{$p}{$_} !~ /(\@|\\)deprecated/io );
					# Bierzemy tylko informację o przedawnieniu
					# (take only the deprecation information)
					$descr = $files_struct_descr{$p}{$_};
					$descr =~ s/^[^\@\\]*//o;
					while ( $descr !~ /^[\@\\]deprecated/io ) { $descr =~ s/^[\@\\][^\@\\]+//o; }
					$descr =~ /(\@|\\)deprecated\s+([^\@\\]*)(\@\w.*|\\\w.*|$)/io;
					$descr = $2;

					my $no_under;
					($no_under = $_) =~ s/^_+//o;
					print $deprec "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
						"<TD><A HREF=\"$p.$html_ext#$no_under\">$files_orig{$p} -- $_</A>\n<BR>\n".
						"<I>$descr</I></TD></TR>\n";
				}
			}
		}
		print $deprec "</TABLE>\n";
	}

	if ( $depr_ma ) {
		print $deprec "<A NAME=\"macro\" ID=\"macro\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"$depr_fcns{$language}\">".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\"><B>$depr_mac{$language}</B></TH></TR>\n";

		foreach my $p (@files) {
			$p = (splitpath $p)[2];
			if ( defined($files_macros_descr{$p}) ) {

				foreach (%{$files_macros_descr{$p}}) {

					next if ( ! defined($files_macros_descr{$p}{$_}) ||
						$files_macros_descr{$p}{$_} !~ /(\@|\\)deprecated/io );
					# Bierzemy tylko informację o przedawnieniu
					# (take only the deprecation information)
					$descr = $files_macros_descr{$p}{$_};
					$descr =~ s/^[^\@\\]*//o;
					while ( $descr !~ /^[\@\\]deprecated/io ) { $descr =~ s/^[\@\\][^\@\\]+//o; }
					$descr =~ /(\@|\\)deprecated\s+([^\@\\]*)(\@\w.*|\\\w.*|$)/io;
					$descr = $2;

					my $no_under;
					($no_under = $_) =~ s/^_+//o;
					print $deprec "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
						"<TD><A HREF=\"$p.$html_ext#$no_under\">$files_orig{$p} -- $_</A>\n<BR>\n".
						"<I>$descr</I></TD></TR>\n";
				}
			}
		}
		print $deprec "</TABLE>\n";
	}

	print $deprec "<HR>\n".nav_bar(0, "deprecated-list.$html_ext")."<HR>$bottom</BODY></HTML>";
	close $deprec;
}

# ============================ constant-values.html ===================================

# generować plik tylko, gdy potrzebny (generate the file only if necessary)
if ( $have_const ) {
	open(my $constv, ">:encoding($charset)", "constant-values.$html_ext")
		or die "$0: constant-values.$html_ext: $!\n";

	print $constv "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$windowtitle - $title_constants{$language}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $constv "<LINK REL=\"stylesheet\" HREF=\"stylesheet.css\" TYPE=\"text/css\">\n";
	} else {
		print $constv "<LINK REL=\"stylesheet\" HREF=\"$stylesheetfile\" TYPE=\"text/css\">\n";
	}
	print $constv "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, "constant-values.$html_ext")."\n";

	print $constv "<HR><CENTER><H1>$title_constants{$language}</H1></CENTER><HR SIZE=\"4\" NOSHADE>\n";

	foreach my $p (@files) {
		$p = (splitpath $p)[2];
		# najpierw sprawdzić, czy w danym pliku były jakiekolwiek stałe
		# (first check if there were any constants in the file)
		if ( defined($files_vars_values{$p}) ) {

			my @constants;
			foreach (%{$files_vars_values{$p}}) {
				if ( defined($files_vars_values{$p}{$_}) && $files_vars_values{$p}{$_} ne "" ) {
					push @constants, $_;
				}
			}

			next if scalar(@constants) < 1;
			print $constv "<TABLE BORDER=\"1\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
				"<TR BGCOLOR=\"#EEEEFF\" CLASS=\"TableSubHeadingColor\">\n".
				"<TH ALIGN=\"left\" COLSPAN=\"3\"><A HREF=\"$p.$html_ext\">$files_orig{$p}</A></TH></TR>\n";
			foreach (@constants) {

				my $no_under;
				($no_under = $_) =~ s/^_+//;
				print $constv "<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
					"<TD ALIGN=\"left\"><A NAME=\"$p.$no_under\" ID=\"$p.$no_under\"><!-- --></A>".
					"<CODE><A HREF=\"$p.$html_ext#$no_under\">$_</A></CODE></TD>\n".
					"<TD ALIGN=\"right\"><CODE>$files_vars_values{$p}{$_}</CODE></TD></TR>\n";
			}
			print $constv "</TABLE><BR>\n";
		}
	}

	print $constv "<HR>\n".nav_bar(0, "constant-values.$html_ext")."<HR>$bottom</BODY></HTML>";
	close $constv;
}

# ============================ overview.html =================================

if ( $overview ne "" ) {

	open(my $over, "<:encoding($encoding)", $overview) or die "$0: $overview: $!\n";

	my $contents;
	my $new_contents;

	# Pomijamy początkowy kod HTML, aż do znacznika <BODY>
	# (Skip over initial HTML, up to the <BODY> tag)
	do {
		$_ = <$over>;
	} while ( ! /<\s*(body|frameset)/io );

	($contents = $_) =~ s/.*<\s*(body|frameset)[^>]*>//io;

	# Zapisujemy całą zawartość pliku (save all the file contents)
	while ( <$over> ) { $contents .= $_; }
	close $over;

	$contents =~ s/<\/(body|frameset|html)>//gio;

	# Wstawiamy początkowy kod HTML i pasek nawigacyjny
	# (insert the initial HTML code and the navigation bar)

	$new_contents = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$windowtitle - $title_over{$language}</TITLE>\n";
	if ( $stylesheetfile eq "" ) {
		$new_contents .= "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"stylesheet.css\" TITLE=\"Style\">\n";
	} else {
		$new_contents .= "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"$stylesheetfile\" TITLE=\"Style\">\n";
	}

	$new_contents .= "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, $overview)."\n";

	if ( $doctitle ne "" ) {
		$new_contents .= "<CENTER><H1>$doctitle</H1></CENTER>";
	}
	$new_contents .= $contents . "<HR>\n".nav_bar(0, $overview)."<HR>$bottom</BODY></HTML>";

	unlink $overview;
	$overview = "overview-summary.$html_ext";

	# Zapisujemy nową zawartość do pliku (save new file content)
	open($over, ">:encoding($charset)", $overview) or die "$0: $overview: $!\n";
	print $over $new_contents;
	close $over;
}



# ============================ index.html =================================
# generujemy 1 index z lista wszystkich plikow jako linki (ramka z lewej okna)
# (generate 1 index file with the list of all files as links (the left-hand side frame)

open(my $index, ">:encoding($charset)", "index.$html_ext") or die "$0: index.$html_ext: $!\n";
print $index "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">\n".
	"<HTML><HEAD>\n".
	"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
	"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
	"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
	"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
	"<TITLE>$windowtitle</TITLE>\n";

if ( $stylesheetfile eq "" ) {
	print $index "<LINK REL=\"stylesheet\" HREF=\"stylesheet.css\" TYPE=\"text/css\">\n";
} else {
	print $index "<LINK REL=\"stylesheet\" HREF=\"$stylesheetfile\" TYPE=\"text/css\">\n";
}

print $index "</HEAD>\n".
	"<FRAMESET COLS=\"20%,80%\" TITLE=\"\">\n".
	"<FRAME SRC=\"allclasses-frame.$html_ext\" NAME=\"packageFrame\" TITLE=\"$allfiles{$language}\">\n";
if ( $overview ne "" ) {
	print $index "<FRAME SRC=\"$overview\" NAME=\"classFrame\" SCROLLING=\"yes\" TITLE=\"$title_over{$language}\">\n";
} else {
	print $index "<FRAME SRC=\"".(splitpath($files[0]))[2].".$html_ext\" NAME=\"classFrame\" SCROLLING=\"yes\" TITLE=\""
		.(splitpath($files[0]))[2].".$html_ext\">\n";
}
print $index "<NOFRAMES><H2>$fr_alert{$language}</H2>\n".
	"<P>$nofr{$language}<BR>\n";
if ( $overview ne "" ) {
	print $index "$linkto{$language} <A HREF=\"$overview\">$nonframe{$language}.</A>\n";
} else {
	print $index "$linkto{$language} <A HREF=\"".(splitpath($files[0]))[2].".$html_ext\">$nonframe{$language}.</A>\n";
}
print $index "</NOFRAMES></FRAMESET></HTML>\n";

close $index;


# ============================= allclasses-*.html ==================================


generate_allclasses(1);		# allclasses-frame
generate_allclasses(0);		# allclasses-noframe


# ============================= stylesheet.css ==================================

if ( $stylesheetfile eq "" ) {

	open(my $css, ">:encoding($charset)", "stylesheet.css") or die "$0: stylesheet.css: $!\n";

	print $css "/* Style sheet for AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/ */\n".
	"/* Copyright (c) 2020 Source Solutions, Inc. */\n".
	"\n".
	"/* Google fonts */\n".
	"\@import url('https://fonts.googleapis.com/css?family=Montserrat&display=swap');\n".
	"\@import url('https://fonts.googleapis.com/css?family=Roboto&display=swap');\n".
	"\n".
	"/* body */\n".
	"body {\n".
	"    font-family: Roboto, sans-serif;\n".
	"    color: #333333;\n".
	"    background: #f9f9f9;\n".
	"    font-size: 14px;\n".
	"    padding: 0px;}\n".
	"\n".
	"/* defined term */\n".
	"dt {\n".
	"    padding-top: 7px;\n".
	"    padding-bottom: 7px;\n".
	"    font-weight: bold;\n".
	"    color: #0e7c86;\n".
	"    font-size: 13px;}\n".
	"\n".
	"dd code {\n".
	"    color: #e53935;\n".
	"    background-color: rgba(38,50,56,0.05);\n".
	"    font-family: Courier,monospace;\n".
	"    border-radius: 2px;\n".
	"    border: 1px solid rgba(38,50,56,0.1);\n".
	"    padding: 0 5px;\n".
	"    font-size: 13px;\n".
	"    font-weight: 400;\n".
	"    word-break: break-word;}\n".
	"\n".
	"/* links */\n".
	"a {\n".
	"    text-decoration: none;\n".
	"    color: #32329f;}\n".
	"\n".
	"/* headings */\n".
	"h1 {\n".
	"    font-family: Montserrat,sans-serif;\n".
	"    font-weight: 400;\n".
	"    font-size: 1.85714em;\n".
	"    line-height: 1.6em;\n".
	"    color: #32329f;\n".
	"    margin-top: 0;\n".
	"    margin-bottom: 0.5em;}\n".
	"\n".
	"h2 {\n".
	"    font-family: Montserrat,sans-serif;\n".
	"    font-weight: 400;\n".
	"    font-size: 1.85714em;\n".
	"    line-height: 1.6em;\n".
	"	color: #32329f;}\n".
	"\n".
	"h3 {\n".
	"    font-size: 1.3em;\n".
	"    padding: 0.2em 0;\n".
	"    margin: 14px 0 14px;\n".
	"    color: #333333;\n".
	"    font-weight: normal;}\n".
	"\n".
	"/* horizontal rule */\n".
	"hr {\n".
	"    border-top: 1px solid rgba(38,50,56,0.5);\n".
	"    border-left: 0px;\n".
	"    border-right: 0px;\n".
	"    border-bottom: 0px;}\n".
	"\n".
	"/* tables */\n".
	"table {\n".
	"    border-collapse: collapse;}\n".
	"\n".
	"/* table colors */\n".
	".TableHeadingColor {\n".
	"    font-family: Roboto, sans-serif;\n".
	"    font-size: 1.17em;\n".
	"    font-weight: bold;\n".
	"	background: #333333;\n".
	"    color: #ffffff;\n".
	"    border: 1px solid #333333;}\n".
	".TableSubHeadingColor {\n".
	"    font-family: Roboto, sans-serif;\n".
	"    font-size: 1.17em;\n".
	"    font-weight: bold;\n".
	"	background: #333333;\n".
	"    color: #ffffff;\n".
	"    border: 1px solid #333333;}\n".
	".TableSubHeadingColor a {\n".
	"    color: white;}\n".
	".TableRowColor {\n".
	"    font-size: 13px;\n".
	"    background: #f9f9f9;\n".
	"    color: rgba(102,102,102,0.9);}\n".
	".TableRowColor a {\n".
	"    font-family: Courier, monospace;\n".
	"    font-size: 13px;\n".
	"    font-weight: normal;\n".
	"    color: #333333;}\n".
	".TableRowColor a:hover {\n".
	"    font-weight: bold;}\n".
	"\n".
	"/* font used in left-hand frame lists */\n".
	".FrameTitleFont {\n".
	"    font-family: Montserrat, sans-serif;\n".
	"    font-size: 0.929em;\n".
	"    text-transform: none;\n".
	"    color: #333333;}\n".
	".FrameHeadingFont {\n".
	"    font-family: Montserrat, sans-serif;\n".
	"    font-size: 0.929em;\n".
	"    text-transform: none;\n".
	"    color: #333333;}\n".
	".FrameItemFont {\n".
	"    font-family: Montserrat, sans-serif;\n".
	"    font-size: 0.929em;\n".
	"    text-transform: none;\n".
	"    color: #333333;\n".
	"    margin: 0px;\n".
	"    border: 0px;}\n".
	".FrameItemFont a {\n".
	"    cursor: pointer;\n".
	"    color: rgb(51, 51, 51);\n".
	"    background-color: #f9f9f9;\n".
	"    margin: 0px;\n".
	"    border: 0px;\n".
	"    padding: 6px;\n".
	"    display: flex;\n".
	"    -webkit-box-pack: justify;\n".
	"    justify-content: space-between;\n".
	"    font-family: Montserrat, sans-serif;\n".
	"    font-size: 0.929em;\n".
	"    text-transform: none;}\n".
	".FrameItemFont a:hover {\n".
	"    color: #32329f;\n".
	"    background-color: #e1e1e1;}\n".
	"\n".
	"/* navigation bar fonts and colors */\n".
	".NavBarCell1 {\n".
	"    background-color: #333333;\n".
	"    color:#e1e1e1;\n".
	"    padding: 3px;\n".
	"}\n".
	".NavBarCell1Rev {\n".
	"    background-color: #333333;\n".
	"    color: #e1e1e1;\n".
	"    padding: 3px;}\n".
	"\n".
	".NavBarFont1 {\n".
	"    color: #e1e1e1;\n".
	"    background-color: #333333;\n".
	"    font-family: Roboto, sans-serif;\n".
	"    border-radius: 2px;\n".
	"    border: 1px solid rgba(38,50,56,0.1);\n".
	"    padding: 0 5px;\n".
	"    font-size: 13px;\n".
	"    font-weight: 400;\n".
	"    word-break: break-word;\n".
	"}\n".
	".NavBarFont1Rev {\n".
	"    color: #333333;\n".
	"    background-color: #ffffff;\n".
	"    font-family: Roboto, sans-serif;\n".
	"    border-radius: 2px;\n".
	"    border: 1px solid rgba(38,50,56,0.1);\n".
	"    padding: 0 5px;\n".
	"    font-size: 13px;\n".
	"    font-weight: bold;\n".
	"    word-break: break-word;}\n".
	"\n".
	".NavBarCell2 {\n".
	"    visibility: hidden;}\n".
	".NavBarCell3 {\n".
	"    visibility: hidden;}\n".
	"\n".
	"body a[title=\"Skip navigation links\"] {\n".
	"    visibility: hidden;}\n".
	"\n".
	"frame a[target=\"classFrame\"] {\n".
	"    border: 0;\n".
	"    margin: 0;}\n";

	close $css;
}

# ============================ index-all.html ===================================

if ( ! $noindex ) {

	my @letters = ( "A" .. "Z" );
	my $letter_list = "";
	my $descr;
	open(my $indexall, ">:encoding($charset)", "index-all.$html_ext")
		or die "$0: index-all.$html_ext: $!\n";

	print $indexall "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$title_index{$language}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $indexall "<LINK REL=\"stylesheet\" HREF=\"stylesheet.css\" TYPE=\"text/css\">\n";
	} else {
		print $indexall "<LINK REL=\"stylesheet\" HREF=\"$stylesheetfile\" TYPE=\"text/css\">\n";
	}
	print $indexall "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, "index-all.$html_ext")."\n";

	LIT: foreach my $l (@letters) {
		foreach my $p (@files) {
			$p = (splitpath $p)[2];
			foreach (@{$files_vars{$p}}) {
				if ( $_ =~ /^$l/i ) {
					print $indexall "<A HREF=\"#".$l."__\">$l</A> ";
					$letter_list .= "<A HREF=\"#".$l."__\">$l</A> ";
					next LIT;
				}
			}
			foreach (@{$files_struct{$p}}) {
				if ( $_ =~ /^$l/i ) {
					print $indexall "<A HREF=\"#".$l."__\">$l</A> ";
					$letter_list .= "<A HREF=\"#".$l."__\">$l</A> ";
					next LIT;
				}
			}
			foreach (@{$files_funcs{$p}}) {
				if ( $_ =~ /^$l/i ) {
					print $indexall "<A HREF=\"#".$l."__\">$l</A> ";
					$letter_list .= "<A HREF=\"#".$l."__\">$l</A> ";
					next LIT;
				}
			}
			foreach (@{$files_macros{$p}}) {
				if ( $_ =~ /^$l/i ) {
					print $indexall "<A HREF=\"#".$l."__\">$l</A> ";
					$letter_list .= "<A HREF=\"#".$l."__\">$l</A> ";
					next LIT;
				}
			}
		}
	}
	print $indexall "\n<HR>\n";
	foreach my $l (@letters) {
		if ( $letter_list =~ /($l)__/i ) {
			print $indexall "<A NAME=\"".$l."__\" ID=\"".$l."__\"><!-- --></A><H2><B>$l</B></H2>\n<DL>";

			foreach my $p (@files) {
				$p = (splitpath $p)[2];
				foreach (@{$files_vars{$p}}) {
					if ( $_ =~ /^$l/i ) {

						next unless defined($files_vars_descr{$p}{$_});
						$descr = $files_vars_descr{$p}{$_};
						# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
						# (take only 1 sentence from the description unless it starts with a tag)
						if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
							$descr = "";
						} else {
							$descr =~ s/\..*/./o;
							$descr =~ s/(\@|\\)[^\s].*//go;
						}
						my $no_under;
						($no_under = $_) =~ s/^_+//o;
						print $indexall "<DT><A HREF=\"$p.$html_ext#$no_under\"><B>$_</B></A>".
							" - $var_in_file{$language} <A HREF=\"$p.$html_ext\">$files_orig{$p}</A>\n".
							"<DD>".$descr;
					}
				}
				foreach (@{$files_struct{$p}}) {
					if ( $_ =~ /^$l/i ) {

						next unless defined($files_struct_descr{$p}{$_});
						$descr = $files_struct_descr{$p}{$_};
						# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
						# (take only 1 sentence from the description unless it starts with a tag)
						if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
							$descr = "";
						} else {
							$descr =~ s/\..*/./o;
							$descr =~ s/(\@|\\)[^\s].*//go;
						}
						my $no_under;
						($no_under = $_) =~ s/^_+//o;
						print $indexall "<DT><A HREF=\"$p.$html_ext#$no_under\"><B>$_</B></A>".
							" - $str_in_file{$language} <A HREF=\"$p.$html_ext\">$files_orig{$p}</A>\n".
							"<DD>".$descr;
					}
				}
				foreach (@{$files_funcs{$p}}) {
					if ( $_ =~ /^$l/i ) {

						next unless defined($files_funcs_descr{$p}{$_});
						$descr = $files_funcs_descr{$p}{$_};
						# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
						# (take only 1 sentence from the description unless it starts with a tag)
						if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
							$descr = "";
						} else {
							$descr =~ s/\..*/./o;
							$descr =~ s/(\@|\\)[^\s].*//go;
						}
						my $no_under;
						($no_under = $_) =~ s/^_+//o;
						print $indexall "<DT><A HREF=\"$p.$html_ext#$no_under\"><B>$_</B></A>".
							" - $fcn_in_file{$language} <A HREF=\"$p.$html_ext\">$files_orig{$p}</A>\n".
							"<DD>".$descr;
					}
				}
				foreach (@{$files_macros{$p}}) {
					if ( $_ =~ /^$l/i ) {

						next unless defined($files_macros_descr{$p}{$_});
						$descr = $files_macros_descr{$p}{$_};
						# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
						# (take only 1 sentence from the description unless it starts with a tag)
						if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
							$descr = "";
						} else {
							$descr =~ s/\..*/./o;
							$descr =~ s/(\@|\\)[^\s].*//go;
						}
						my $no_under;
						($no_under = $_) =~ s/^_+//o;
						print $indexall "<DT><A HREF=\"$p.$html_ext#$no_under\"><B>$_</B></A>".
							" - $mac_in_file{$language} <A HREF=\"$p.$html_ext\">$files_orig{$p}</A>\n".
							"<DD>".$descr;
					}
				}
			}
			print $indexall "</DL><HR>\n";
		}
	}
	print $indexall $letter_list."<BR>".nav_bar(0, "index-all.$html_ext")."<HR>$bottom</BODY></HTML>";
	close $indexall;
}

# ============================ help-doc.html ===================================

if ( ! $nohelp && $helpfile eq "" ) {

	open(my $helpdoc, ">:encoding($charset)", "help-doc.$html_ext")
		or die "$0: help-doc.$html_ext: $!\n";

	print $helpdoc "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$title_help{$language}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $helpdoc "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"stylesheet.css\" TITLE=\"Style\">\n";
	} else {
		print $helpdoc "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"$stylesheetfile\" TITLE=\"Style\">\n";
	}

	print $helpdoc "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, "help-doc.$html_ext")."\n<HR>".
			$helpdoc_msg{$language}."<HR>\n".nav_bar(0, "help-doc.$html_ext")."<HR>$bottom</BODY></HTML>\n";
	close $helpdoc;
}

# =================== Zapisywanie plików wyjściowych (writing output files) =================
foreach my $p (@files) {

	my $descr;

	$p = (splitpath $p)[2];
	open(my $html, ">:encoding($charset)", $p.".$html_ext") or die "$0: $p.$html_ext: $!\n";

	print $html "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$windowtitle - $files_orig{$p}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $html "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"stylesheet.css\" TITLE=\"Style\">\n";
	} else {
		print $html "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"$stylesheetfile\" TITLE=\"Style\">\n";
	}

	print $html "</HEAD><BODY BGCOLOR=\"white\">\n".$top."<HR>".nav_bar(1, $p.".$html_ext").
		"<HR><H2>$file{$language} $files_orig{$p}</H2>\n";

	if ( defined ($files_descr{$p}) && ! $nocomment ) {

		if ( ! $version && $files_descr{$p} =~ /[\@\\]version/io ) {

			$files_descr{$p} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
		}

		if ( ! $author && $files_descr{$p} =~ /[\@\\]author/io ) {

			$files_descr{$p} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
		}

		if ( $nosince && $files_descr{$p} =~ /[\@\\]since/io ) {

			$files_descr{$p} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
		}

		if ( $nodeprecated && $files_descr{$p} =~ /[\@\\]deprecated/io ) {

			$files_descr{$p} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
		}

		foreach my $tag (keys %tags_subst) {

			$files_descr{$p} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
		}

		print $html "<DL><DD>".$files_descr{$p}."\n</DL>";
	}

	# Podsumowanie zmiennych (variable summary)
	if ( defined($files_vars{$p}) && (@{$files_vars{$p}} > 0) ) {

		print $html "\n<HR>\n<A NAME=\"var_summary\" ID=\"var_summary\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\">\n".
			"<B>$var_sum{$language}</B></TH></TR>\n";

		foreach (@{$files_vars{$p}}) {

			next unless defined ($files_vars_descr{$p}{$_});
			$descr = $files_vars_descr{$p}{$_};
			# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
			# (take only 1 sentence from the description unless it starts with a tag)
			if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
				$descr = "";
			} else {
				$descr =~ s/\..*/./o;
				$descr =~ s/(\@|\\)[^\s].*//go;
			}

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html
				"<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
				"<TD><CODE><B><A HREF=\"$p.$html_ext#$no_under\">$_</A></B></CODE><BR>\n".
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$descr</TD></TR>\n";
		}
		print $html "</TABLE><BR>\n\n";
	}

	# Podsumowanie struktur (structure summary)
	if ( defined($files_struct{$p}) && (@{$files_struct{$p}} > 0) ) {

		print $html "\n<HR>\n<A NAME=\"str_summary\" ID=\"str_summary\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\">\n".
			"<B>$str_sum{$language}</B></TH></TR>\n";

		foreach (@{$files_struct{$p}}) {

			next unless defined ($files_struct_descr{$p}{$_});
			$descr = $files_struct_descr{$p}{$_};
			# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
			# (take only 1 sentence from the description unless it starts with a tag)
			if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
				$descr = "";
			} else {
				$descr =~ s/\..*/./o;
				$descr =~ s/(\@|\\)[^\s].*//go;
			}

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html
				"<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
				"<TD><CODE><B><A HREF=\"$p.$html_ext#$no_under\">$_</A></B></CODE><BR>\n".
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$descr</TD></TR>\n";
		}
		print $html "</TABLE><BR>\n\n";
	}

	# Podsumowanie funkcji (function summary)
	if ( defined($files_funcs{$p}) && (@{$files_funcs{$p}} > 0) ) {

		print $html "\n<HR>\n<A NAME=\"function_summary\" ID=\"function_summary\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\">\n".
			"<B>$fcn_sum{$language}</B></TH></TR>\n";

		foreach (@{$files_funcs{$p}}) {

			next unless defined ($files_funcs_descr{$p}{$_});
			$descr = $files_funcs_descr{$p}{$_};
			# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
			# (take only 1 sentence from the description unless it starts with a tag)
			if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
				$descr = "";
			} else {
				$descr =~ s/\..*/./o;
				$descr =~ s/(\@|\\)[^\s].*//go;
			}

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html
				"<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
				"<TD><CODE><B><A HREF=\"$p.$html_ext#$no_under\">$_</A></B></CODE><BR>\n".
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$descr</TD></TR>\n";
		}
		print $html "</TABLE><BR>\n\n";
	}

	# Podsumowanie makr (macro summary)
	if ( defined($files_macros{$p}) && (@{$files_macros{$p}} > 0) ) {

		print $html "\n<HR>\n<A NAME=\"macro_summary\" ID=\"macro_summary\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"2\">\n".
			"<B>$mac_sum{$language}</B></TH></TR>\n";

		foreach (@{$files_macros{$p}}) {

			next unless defined ($files_macros_descr{$p}{$_});
			$descr = $files_macros_descr{$p}{$_};
			# z opisu brać tylko 1 zdanie, chyba ze zaczyna sie tagiem
			# (take only 1 sentence from the description unless it starts with a tag)
			if ( $nocomment || $descr =~ /^\s*(\@|\\)\w/o ) {
				$descr = "";
			} else {
				$descr =~ s/\..*/./o;
				$descr =~ s/(\@|\\)[^\s].*//go;
			}

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html
				"<TR BGCOLOR=\"white\" CLASS=\"TableRowColor\">\n".
				"<TD><CODE><B><A HREF=\"$p.$html_ext#$no_under\">$_</A></B></CODE><BR>\n".
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$descr</TD></TR>\n";
		}
		print $html "</TABLE><BR>\n\n";
	}


	# Szczegóły zmiennych (variable details)
	if ( defined($files_vars{$p}) && (@{$files_vars{$p}} > 0) ) {

		print $html
			"\n<HR>\n<A NAME=\"var_detail\" ID=\"var_detail\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"1\">\n".
			"<B>$var_det{$language}</B></TH></TR></TABLE>\n\n";

		foreach (@{$files_vars{$p}}) {

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html "<A NAME=\"$no_under\" ID=\"$no_under\"><!-- --></A><H3>$_</H3>\n";

			# sprawdzać, czy nie podano opcji wyłączających pewne znaczniki
			# (check if some options, wich disable tags, were given)
			if ( defined($files_vars_descr{$p}{$_}) && ! $nocomment ) {

				if ( ! $version && $files_vars_descr{$p}{$_} =~ /[\@\\]version/io ) {

					$files_vars_descr{$p}{$_} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
				}

				if ( ! $author && $files_vars_descr{$p}{$_} =~ /[\@\\]author/io ) {

					$files_vars_descr{$p}{$_} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nosince && $files_vars_descr{$p}{$_} =~ /[\@\\]since/io ) {

					$files_vars_descr{$p}{$_} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nodeprecated && $files_vars_descr{$p}{$_} =~ /[\@\\]deprecated/io ) {

					$files_vars_descr{$p}{$_} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
				}

				foreach my $tag (keys %tags_subst) {

					$files_vars_descr{$p}{$_} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
				}

				print $html "<DL><DD>$files_vars_descr{$p}{$_}\n</DD></DL><HR>\n\n";
			}
		}
	}

	# Szczegóły struktur (structure details)
	if ( defined($files_struct{$p}) && (@{$files_struct{$p}} > 0) ) {

		print $html
			"\n<HR>\n<A NAME=\"str_detail\" ID=\"str_detail\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"1\">\n".
			"<B>$str_det{$language}</B></TH></TR></TABLE>\n\n";

		foreach (@{$files_struct{$p}}) {

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html "<A NAME=\"$no_under\" ID=\"$no_under\"><!-- --></A><H3>$_</H3>\n";

			# sprawdzać, czy nie podano opcji wyłączających pewne znaczniki
			# (check if some options, wich disable tags, were given)
			if ( defined($files_struct_descr{$p}{$_}) && ! $nocomment ) {

				if ( ! $version && $files_struct_descr{$p}{$_} =~ /[\@\\]version/io ) {

					$files_struct_descr{$p}{$_} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
				}

				if ( ! $author && $files_struct_descr{$p}{$_} =~ /[\@\\]author/io ) {

					$files_struct_descr{$p}{$_} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nosince && $files_struct_descr{$p}{$_} =~ /[\@\\]since/io ) {

					$files_struct_descr{$p}{$_} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nodeprecated && $files_struct_descr{$p}{$_} =~ /[\@\\]deprecated/io ) {

					$files_struct_descr{$p}{$_} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
				}

				foreach my $tag (keys %tags_subst) {

					$files_struct_descr{$p}{$_} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
				}

				print $html "<DL><DD>$files_struct_descr{$p}{$_}\n</DD></DL>\n"
					."$_\n\{<BR>\n";

				foreach my $field (@{$files_struct_vars{$p}{$_}})
				{
					next unless defined $files_struct_vars_descr{$p}{$_}{$field};
					if ( ! $version && $files_struct_vars_descr{$p}{$_}{$field} =~ /[\@\\]version/io ) {

						$files_struct_vars_descr{$p}{$_}{$field} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
					}

					if ( ! $author && $files_struct_vars_descr{$p}{$_}{$field} =~ /[\@\\]author/io ) {

						$files_struct_vars_descr{$p}{$_}{$field} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
					}

					if ( $nosince && $files_struct_vars_descr{$p}{$_}{$field} =~ /[\@\\]since/io ) {

						$files_struct_vars_descr{$p}{$_}{$field} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
					}

					if ( $nodeprecated && $files_struct_vars_descr{$p}{$_}{$field} =~ /[\@\\]deprecated/io ) {

						$files_struct_vars_descr{$p}{$_}{$field} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
					}

					foreach my $tag (keys %tags_subst) {

						$files_struct_vars_descr{$p}{$_}{$field} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
					}

					print $html "<CODE>$field</CODE> $files_struct_vars_descr{$p}{$_}{$field}<BR>\n";
				}

				print $html "\n\}\n<HR>\n\n";
			}
		}
	}

	# Szczegóły funkcji (function details)
	if ( defined($files_funcs{$p}) && (@{$files_funcs{$p}} > 0) ) {

		print $html
			"<A NAME=\"function_detail\" ID=\"function_detail\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"1\">\n".
			"<B>$fcn_det{$language}</B></TH></TR></TABLE>\n";

		foreach (@{$files_funcs{$p}}) {

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html "<A NAME=\"$no_under\" ID=\"$no_under\"><!-- --></A><H3>$_</H3>\n";

			# sprawdzać, czy nie podano opcji wyłączających pewne znaczniki
			# (check if some options, wich disable tags, were given)
			if ( defined($files_funcs_descr{$p}{$_}) && ! $nocomment ) {

				if ( ! $version && $files_funcs_descr{$p}{$_} =~ /[\@\\]version/io ) {

					$files_funcs_descr{$p}{$_} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
				}

				if ( ! $author && $files_funcs_descr{$p}{$_} =~ /[\@\\]author/io ) {

					$files_funcs_descr{$p}{$_} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nosince && $files_funcs_descr{$p}{$_} =~ /[\@\\]since/io ) {

					$files_funcs_descr{$p}{$_} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nodeprecated && $files_funcs_descr{$p}{$_} =~ /[\@\\]deprecated/io ) {

					$files_funcs_descr{$p}{$_} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
				}

                                $files_funcs_descr{$p}{$_} =~ s/[\@\\]param[^\s]*\s+([\w\:\/\(\)\[\]\%]+)/\@param <code>$1<\/code>/gi;
				foreach my $tag (keys %tags_subst) {

					$files_funcs_descr{$p}{$_} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
				}

				print $html "<DL><DD>$files_funcs_descr{$p}{$_}\n</DD></DL><HR>\n\n";
			}
		}
	}

	# Szczegóły makr (macro details)
	if ( defined($files_macros{$p}) && (@{$files_macros{$p}} > 0) ) {

		print $html
			"<A NAME=\"macro_detail\" ID=\"macro_detail\"><!-- --></A>\n".
			"<TABLE BORDER=\"1\" WIDTH=\"100%\" CELLPADDING=\"3\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
			"<TR BGCOLOR=\"#CCCCFF\" CLASS=\"TableHeadingColor\">\n".
			"<TH ALIGN=\"left\" COLSPAN=\"1\">\n".
			"<B>$mac_det{$language}</B></TH></TR></TABLE>\n";

		foreach (@{$files_macros{$p}}) {

			my $no_under;
			($no_under = $_) =~ s/^_+//o;
			print $html "<A NAME=\"$no_under\" ID=\"$no_under\"><!-- --></A><H3>$_</H3>\n";

			# sprawdzać, czy nie podano opcji wyłączających pewne znaczniki
			# (check if some options, wich disable tags, were given)
			if ( defined($files_macros_descr{$p}{$_}) && ! $nocomment ) {

				if ( ! $version && $files_macros_descr{$p}{$_} =~ /[\@\\]version/io ) {

					$files_macros_descr{$p}{$_} =~ s/[\@\\]version[^\@\\]*(.*|$)/$1/ig;
				}

				if ( ! $author && $files_macros_descr{$p}{$_} =~ /[\@\\]author/io ) {

					$files_macros_descr{$p}{$_} =~ s/[\@\\]author[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nosince && $files_macros_descr{$p}{$_} =~ /[\@\\]since/io ) {

					$files_macros_descr{$p}{$_} =~ s/[\@\\]since[^\@\\]*(.*|$)/$1/ig;
				}

				if ( $nodeprecated && $files_macros_descr{$p}{$_} =~ /[\@\\]deprecated/io ) {

					$files_macros_descr{$p}{$_} =~ s/[\@\\]deprecated[^\@\\]*(.*|$)/$1/ig;
				}

                                $files_macros_descr{$p}{$_} =~ s/[\@\\]param[^\s]*\s+([\w\:\/\(\)\[\]\%]+)/\@param <code>$1<\/code>/gi;
				foreach my $tag (keys %tags_subst) {

					$files_macros_descr{$p}{$_} =~ s/[\@\\]$tag/\n<DT><B>$tags_subst{$tag}<\/B><DD>/ig;
				}

				print $html "<DL><DD>$files_macros_descr{$p}{$_}\n</DD></DL><HR>\n\n";
			}
		}
	}

 	print $html "<HR>\n".nav_bar(0, $p.".$html_ext")."<HR>$bottom</BODY></HTML>\n";
	close $html;
}

chdir catpath($disc, $directory, "");
exit 0;



# ============================ print_help ===================================

sub print_help {

	print $msg_help{$language};
}


# ============================ generate_allclasses ===================================

sub generate_allclasses {

	my $frame = shift;
	my $frameid = "";
	my $extra = "noframe";

	if ( $frame ) {
		$frameid = " TARGET=\"classFrame\"";
		$extra = "frame"
	}

	open(my $allclfr, ">:encoding($charset)", "allclasses-$extra.$html_ext")
		or die "$0: allclasses-$extra.$html_ext: $!\n";

	print $allclfr "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n".
		"<HTML><HEAD>\n".
		"<!-- Generated by AsmDoc. See http://rudy.mif.pg.gda.pl/~bogdro/inne/ -->\n".
		"<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=$charset\">\n".
		"<META HTTP-EQUIV=\"Content-Style-Type\" CONTENT=\"text/css\">\n".
		"<META NAME=\"Generator\" CONTENT=\"AsmDoc; see http://rudy.mif.pg.gda.pl/~bogdro/inne/\">\n".
		"<TITLE>$allfiles{$language}</TITLE>\n";

	if ( $stylesheetfile eq "" ) {
		print $allclfr "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"stylesheet.css\" TITLE=\"Style\">\n";
	} else {
		print $allclfr "<LINK REL=\"stylesheet\" TYPE=\"text/css\" HREF=\"$stylesheetfile\" TITLE=\"Style\">\n";
	}

	print $allclfr "</HEAD><BODY BGCOLOR=\"white\">\n".
			"<B>$allfiles{$language}</B><BR>\n<FONT CLASS=\"FrameItemFont\">\n";

	foreach (@files) {
		$_ = (splitpath $_)[2];
		print $allclfr "<A HREF=\"$_.$html_ext\"$frameid>$files_orig{$_}</A><br>\n";
	}
	print $allclfr "</FONT></BODY></HTML>\n";

	close $allclfr;
}



# =========================== Pasek nawigacyjny (navigation bar) ===========================

sub nav_bar {

	if ( $nonavbar ) { return ""; }

	my $top = shift;	# top?
	my $file = shift;	# current file name
	my $result = "";

	# link omijajacy pasek nawigacyjny
	# (a link which skips the navigation bar)
	if ( $top ) {
		$result .= "<A HREF=\"#skip_navbar_top\" TITLE=\"Skip navigation links\">$skipbar{$language}</A>\n";
	} else {
		$result .= "<A HREF=\"#skip_navbar_bottom\" TITLE=\"Skip navigation links\">$skipbar{$language}</A>\n";
	}

	$result .=
		"<TABLE BORDER=\"0\" WIDTH=\"100%\" CELLPADDING=\"1\" CELLSPACING=\"0\" SUMMARY=\"\">\n".
		"<TR><TD COLSPAN=\"2\" BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\">\n".
		"<TABLE BORDER=\"0\" CELLPADDING=\"0\" CELLSPACING=\"3\" SUMMARY=\"\">\n".
		"<TR ALIGN=\"center\" VALIGN=\"top\">\n";

	if ( $overview ne "" ) {
		if ( $file ne $overview ) {
			$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
				"<A HREF=\"$overview\"><FONT CLASS=\"NavBarFont1\"><B>".
				"$title_over{$language}</B></FONT></A>&nbsp;</TD>";
		} else {
			$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
				"<FONT CLASS=\"NavBarFont1Rev\"><B>$title_over{$language}</B></FONT>&nbsp;</TD>";
		}
	}
	# Sprawdzamy, w którym pliku jesteśmy i podświetlać właściwy element paska
	# (check in which file we cuurently are and highlight the right element of the bar)
	if ( 	$file ne "help-doc.$html_ext" &&
		$file ne "deprecated-list.$html_ext" &&
		$file ne "index-all.$html_ext" &&
		$file ne $helpfile &&
		$file ne $overview &&
		$file ne "constant-values.$html_ext" ) {

		$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
			"<FONT CLASS=\"NavBarFont1Rev\"><B>$file{$language}</B></FONT>&nbsp;</TD>\n";
	} else {
		$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
			"<FONT CLASS=\"NavBarFont1\">$file{$language}</FONT>&nbsp;</TD>\n";
	}

	if ( ! $nodeprecatedlist && -e "deprecated-list.$html_ext" ) {
		if ( $file ne "deprecated-list.$html_ext" ) {
			$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
				"<A HREF=\"deprecated-list.$html_ext\"><FONT CLASS=\"NavBarFont1\">".
				"<B>$deprec{$language}</B></FONT></A>&nbsp;</TD>\n";
		} else {
			$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
				"<FONT CLASS=\"NavBarFont1Rev\"><B>$deprec{$language}</B></FONT>&nbsp;</TD>\n";
		}
  	}
	if ( ! $noindex ) {
		if ( $file ne "index-all.$html_ext" ) {
			$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
				"<A HREF=\"index-all.$html_ext\"><FONT CLASS=\"NavBarFont1\">".
				"<B>$title_index{$language}</B></FONT></A>&nbsp;</TD>\n";
		} else {
			$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
				"<FONT CLASS=\"NavBarFont1Rev\"><B>$title_index{$language}</B></FONT>&nbsp;</TD>\n";
		}
	}
	if ( -e "constant-values.$html_ext" ) {
		if ( $file ne "constant-values.$html_ext" ) {
			$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
				"<A HREF=\"constant-values.$html_ext\"><FONT CLASS=\"NavBarFont1\">".
				"<B>$constants{$language}</B></FONT></A>&nbsp;</TD>\n";
		} else {
			$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
				"<FONT CLASS=\"NavBarFont1Rev\"><B>$constants{$language}</B></FONT>&nbsp;</TD>\n";
		}
	}
	if ( ! $nohelp ) {
		if ( $helpfile eq "" ) {
			if ( $file ne "help-doc.$html_ext" ) {
  				$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
  					"<A HREF=\"help-doc.$html_ext\"><FONT CLASS=\"NavBarFont1\">".
  					"<B>$title_help{$language}</B></FONT></A>&nbsp;</TD>\n";
  			} else {
  				$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
  					"<FONT CLASS=\"NavBarFont1Rev\"><B>$title_help{$language}</B></FONT>&nbsp;</TD>\n";
  			}
  		} else {
			if ( $file ne $helpfile ) {
	  			$result .= "<TD BGCOLOR=\"#EEEEFF\" CLASS=\"NavBarCell1\"> ".
	  				"<A HREF=\"$helpfile\"><FONT CLASS=\"NavBarFont1\"><B>".
	  				"$title_help{$language}</B></FONT></A>&nbsp;</TD>\n";
  			} else {
	  			$result .= "<TD BGCOLOR=\"#FFFFFF\" CLASS=\"NavBarCell1Rev\"> &nbsp;".
	  				"<FONT CLASS=\"NavBarFont1Rev\"><B>$title_help{$language}</B></FONT>&nbsp;</TD>\n";
  			}
  		}
  	}

	$result .= "</TR></TABLE></TD>\n<TD ALIGN=\"right\" VALIGN=\"top\" ROWSPAN=\"3\">";
	if ( $header ne "" && $top ) {
		$result .= "<EM>$header</EM>";
	} elsif ( $footer ne "" && ! $top ) {
		$result .= "<EM>$footer</EM>";
	}
	$result .= "</TD></TR>\n<TR><TD BGCOLOR=\"white\" CLASS=\"NavBarCell2\">\n";

	if ( 	$file ne "help-doc.$html_ext" &&
		$file ne "deprecated-list.$html_ext" &&
		$file ne "index-all.$html_ext" &&
		$file ne $helpfile &&
		$file ne $overview &&
		$file ne "constant-values.$html_ext" ) {

		# Znajdujemy numer pliku, w którym się znajdujemy
		# (find the number of the file, in which we currently are)
		my $i=0;
		my $which = -1;
		foreach (@files) {
			$_ = (splitpath $_)[2];
			if ( "$_.$html_ext" eq $file ) { $which = $i; last; }
			$i++;
		}

		# Linki "Następny" i "Poprzedni" (the "NEXT" and "PREV" links)
		if ( $which > 0 && $which <= $#files ) {
			$result .= "<A HREF=\"".(splitpath($files[$which-1]))[2].
				".$html_ext\" TITLE=\"".$file{$language}."\"><B>$prev_file{$language}</B></A>&nbsp;&nbsp;\n";
		} else {
			$result .= "$prev_file{$language}&nbsp;&nbsp;&nbsp;&nbsp;\n";
		}

		if ( $which >= 0 && $which < $#files ) {
			$result .= "<A HREF=\"".(splitpath($files[$which+1]))[2].
				".$html_ext\" TITLE=\"".$file{$language}."\"><B>$next_file{$language}</B></A></TD>\n";
		} else {
			$result .= "$next_file{$language}</TD>\n";
		}
	} else {
		$result .= "$prev_file{$language}&nbsp;&nbsp;&nbsp;&nbsp;$next_file{$language}</TD>\n";
	}

	$result .=
		"<TD BGCOLOR=\"white\" CLASS=\"NavBarCell2\">\n".
  		"<A HREF=\"index.$html_ext?$file\" TARGET=\"_top\"><B>$name_frames{$language}</B></A>  &nbsp;&nbsp;\n".
  		"<A HREF=\"$file\" TARGET=\"_top\"><B>$no_frames{$language}</B></A>  &nbsp;&nbsp;\n".
		"<A HREF=\"allclasses-noframe.$html_ext\"><B>$allfiles{$language}</B></A>\n\n".
		"</TD></TR>\n";

	# Linki do podsumowania i szczegółów tylko we właściwych plikach
	# (Add the links to summaries and details only to the correct files)
	if ( 	$file ne "help-doc.$html_ext" &&
		$file ne "deprecated-list.$html_ext" &&
		$file ne "index-all.$html_ext" &&
		$file ne $helpfile &&
		$file ne $overview &&
		$file ne "constant-values.$html_ext" ) {

		$result .=
			"<TR><TD VALIGN=\"top\" CLASS=\"NavBarCell3\">\n".
			"$summary{$language}:&nbsp;".
			"<A HREF=\"#var_summary\">$name_vars{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#str_summary\">$name_st{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#function_summary\">$name_fcns{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#macro_summary\">$name_mc{$language}</A></TD>\n".
			"<TD VALIGN=\"top\" CLASS=\"NavBarCell3\">\n".
			"$details{$language}:&nbsp;".
			"<A HREF=\"#var_detail\">$name_vars{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#str_detail\">$name_st{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#function_detail\">$name_fcns{$language}</A>&nbsp;|&nbsp;".
			"<A HREF=\"#macro_detail\">$name_mc{$language}</A></TD></TR>";
	}
	$result .= "</TABLE>\n";

	# cel linku omijajacego pasek nawigacyjny
	# (target of the link, which skips the navigation bar)
	if ( $top ) {
		if ( $doctitle ne "" ) {
			$result .= "<A NAME=\"skip_navbar_top\" ID=\"skip_navbar_top\"></A>\n\n".
				"<DIV ALIGN=\"CENTER\"><H1>$doctitle</H1></DIV>\n\n";
		} else {
			$result .= "<A NAME=\"skip_navbar_top\" ID=\"skip_navbar_top\"></A>\n\n";
		}
	} else {
		$result .= "<A NAME=\"skip_navbar_bottom\" ID=\"skip_navbar_bottom\"></A>\n\n";
	}

	return $result;
}

# ============================== tags =====================================
sub tags {

	my $current = shift;
	return $current if ( ! defined ($current) );

	# {@code}
	if ( $current =~ /\{\s*(\@|\\)code\s*(.*)\}/io ) {
		my $descr = $2;
		# zamieniamy zabronione znaki na encje HTML
		# (changing forbidden characters to HTML entities)
		$descr =~ s/&($|[^a])($|[^m])($|[^p])/&amp;$1$2$3/ig;
		$descr =~ s/<(\s|$)/&lt;$1/g;
		$descr =~ s/>(\s|$)/&gt;$1/g;
		$current =~ s/\{\s*(\@|\\)code\s*(.*)\}/<CODE>$descr<\/CODE>/ig;
	}

	# {@literal}
	if ( $current =~ /\{\s*(\@|\\)literal\s*(.*)\}/io ) {
		my $descr = $2;
		# zamieniamy zabronione znaki na encje HTML
		# (changing forbidden characters to HTML entities)
		$descr =~ s/&($|[^a])($|[^m])($|[^p])/&amp;$1$2$3/ig;
		$descr =~ s/<(\s|$)/&lt;$1/g;
		$descr =~ s/>(\s|$)/&gt;$1/g;
		$current =~ s/\{\s*(\@|\\)literal\s*(.*)\}/$descr/ig;
	}

	# {@docroot}
	$current =~ s/\{\s*(\@|\\)docroot\s*\}/$docroot/ig;

	# {@link}
	if ( $current =~ /\{\s*(\@|\\)link\s*(.*)\s+(.*)\}/io ) {
		my $target = $2;
		my $label = $3;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			my $file = $1;
			foreach (@files) {
				$_ = (splitpath $_)[2];
				$have_file = 1 if /$file/i;
			}
			$file =~ s/\./-/go;
		}
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file;
		$current =~ s/\{\s*(\@|\\)link\s*(.*)\s+(.*)\}/<A HREF="$target"><CODE>$label<\/CODE><\/A>/ig;
	}
	if ( $current =~ /\{\s*(\@|\\)link\s*(.*)\}/io ) {
		my $target = $2;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			my $file = $1;
			foreach (@files) {
				$_ = (splitpath $_)[2];
				$have_file = 1 if /$file/i;
			}
			$file =~ s/\./-/go;
		}
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file;
		$current =~ s/\{\s*(\@|\\)link\s*(.*)\s+(.*)\}/<A HREF="$target"><CODE>$target<\/CODE><\/A>/ig;
	}

	# {@linkplain}
	if ( $current =~ /\{\s*(\@|\\)linkplain\s*(.*)\s+(.*)\}/io ) {
		my $target = $2;
		my $label = $3;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			my $file = $1;
			foreach (@files) {
				$_ = (splitpath $_)[2];
				$have_file = 1 if /$file/i;
			}
			$file =~ s/\./-/go;
		}
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file;
		$current =~ s/\{\s*(\@|\\)linkplain\s*(.*)\s+(.*)\}/<A HREF="$target">$label<\/A>/ig;
	}
	if ( $current =~ /\{\s*(\@|\\)linkplain\s*(.*)\}/io ) {
		my $target = $2;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			my $file = $1;
			foreach (@files) {
				$_ = (splitpath $_)[2];
				$have_file = 1 if /$file/i;
			}
			$file =~ s/\./-/go;
		}
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file;
		$current =~ s/\{\s*(\@|\\)linkplain\s*(.*)\s+(.*)\}/<A HREF="$target">$target<\/A>/ig;
	}

	# @see
	if ( $current =~ /(\@|\\)see\s*([^\s]+)\s+([^\s]+)/io &&
		$current !~ /(\@|\\)see\s*<a\s+/io ) {

		$current =~ /(\@|\\)see\s*([^\s]+)\s+([^\s]+)/io;
		my $target = $2;
		my $label = $3;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			$file = $1;
			foreach (keys %files_orig) {
				if ( $files_orig{$_} =~ /$file/i ) {
					$have_file = 1;
					last;
				}
			}
			$file =~ s/\./-/go;
		}
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file && $file ne "";
		if ( $have_file ) {
			$current =~ s/(\@|\\)see\s*([^\s]+)\s+([^\s]+)/\@see <A HREF="$target">$label<\/A>/ig;
		} else {
			$current =~ s/(\@|\\)see\s*([^\s]+)\s+([^\s]+)/\@see $label/ig;
		}
	}
	if ( $current =~ /(\@|\\)see\s*([^\s]+)/io &&
		$current !~ /(\@|\\)see\s*<a\s+/io ) {

		$current =~ /(\@|\\)see\s*([^\s]+)/io;
		my $target = $2;
		my $file;
		my $have_file = 0;
		if ( $target =~ /\#(\w+)/o ) {
			$target =~ s/\#(\w+)\([^\)]\)/\#$1/g;
			$file = "";
			$have_file = 1;
		}
		if ( $target =~ /^([\w\.\-\+]+)/o ) {
			$file = $1;
			foreach (keys %files_orig) {
				if ( $files_orig{$_} =~ /$file/i ) {
					$have_file = 1;
					last;
				}
			}
			$file =~ s/\./-/go;
		}
		my $target_st = $target;
		$target =~ s/^([\w\.\-\+]+)/$file.$html_ext/ if $have_file && $file ne "";
		if ( $have_file ) {
			$current =~ s/(\@|\\)see\s*([^\s]+)/\@see <A HREF="$target">$target_st<\/A>/ig;
		} else {
			$current =~ s/(\@|\\)see\s*([^\s]+)/\@see $target/ig;
		}
	}
	return $current;
}
