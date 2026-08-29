use strict;
use warnings;

use ExtUtils::MakeMaker;

# DBD::mysql 5.x builds only against the MySQL 8 client library. A host whose
# mysql_config is MariaDB's (every RHEL and Debian) gets a wall of undeclared
# MYSQL_OPT_SSL_MODE errors from cpanm and gives up. Say so before that
# happens, once, loudly.
{
    my $cfg = ( grep { -x $_ } map { ("$_/mysql_config", "$_/mariadb_config") }
        split /:/, $ENV{PATH} )[0];
    my $ver = $cfg ? `$cfg --version 2>/dev/null` : '';
    chomp $ver;
    my $have_dbd = eval { require DBD::mysql; 1 };
    if ( !$have_dbd && ( !$cfg || $ver =~ /^1\d\./ || $cfg =~ /mariadb_config$/ ) ) {
        warn <<"EOW";

**********************************************************************
DBD::mysql is not installed and the client library here is
@{[ $cfg ? "$cfg ($ver)" : 'not found' ]}.

cpanm will pick DBD::mysql 5.x, which only builds against the MySQL 8
client library. It does not build against MariaDB's connector, and no
amount of retrying changes that. Pick one:

  - install the MySQL 8 client dev package and let cpanm build 5.x
  - cpanm --notest DBD::mysql\@4.050   (the last release that builds
    against MariaDB; it is 2020 code, treat it as a stopgap)
  - use DBD::MariaDB and set DB_ENGINE=MariaDB in nictoolserver.conf

Old client libraries and old perls are the reason installs get stuck.
Update them; this project will not pin itself to them.
**********************************************************************

EOW
    }
}

my %WriteMakefileArgs = (
    "ABSTRACT" => "NicTool API reference server",
    "AUTHOR"   => "Matt Simerson <msimerson\@cpan.org>, Damon Edwards, Abraham Ingersoll, Greg Schueler",
    "CONFIGURE_REQUIRES" => { "ExtUtils::MakeMaker" => 0 },
    "DISTNAME"           => "NicToolServer",
    "EXE_FILES"          => [],
    "LICENSE"            => "agpl_3",
    "MIN_PERL_VERSION"   => "5.030",
    "NAME"               => "NicToolServer",
    "PREREQ_PM"          => {
        "Apache::DBI"          => 0,
        "BIND::Conf_Parser"    => 0,
        "CGI"                  => "4.21",
        "Crypt::KeyDerivation" => 0,
        "Crypt::Mac::HMAC"     => 0,
        "CryptX"               => "0.021",
        "Cwd"                  => 0,
        "DBD::mysql"           => "4.050",
        "DBI"                  => "1.20",
        "DBIx::Simple"         => 0,
        "Data::Dumper"         => 0,
        "English"              => 0,
        "File::Copy"           => 0,
        "File::Path"           => 0,
        "HTML::Parser"         => 0,
        "IO::File"             => 0,
        "JSON"                 => 0,
        "LWP::UserAgent"       => 0,
        "MIME::Base32"         => 0,
        "MIME::Base64"         => 0,
        "Net::DNS::ZoneFile"   => 0,
        "Net::IP"              => 0,
        "Params::Validate"     => "0.8",
        "RPC::XML"             => 0,
        "RPC::XML::Parser"     => 0,
        "SOAP::Lite"           => "0.51",
        "Scalar::Util"         => 0,
        "Time::HiRes"          => "1.9",
        "Time::Local"          => 0,
        "Time::TAI64"          => 2,
        "XML::Parser"          => 0,
        "constant"             => 0,
        "lib"                  => 0,
        "parent"               => "0.2",
        "strict"               => 0,
        "vars"                 => 0,
        "warnings"             => 0
    },
    "TEST_REQUIRES" => {
        "Exporter"     => 0,
        "Test"         => 0,
        "Test::More"   => 0,
        "Test::Output" => 0
    },
    "VERSION" => "2.41",
    "test"    => { "TESTS" => "t/*.t" }
);

my %FallbackPrereqs = (
    "APR::Table"           => 0,
    "Apache::DBI"          => 0,
    "BIND::Conf_Parser"    => 0,
    "CGI"                  => 3,
    "Crypt::KeyDerivation" => 0,
    "Crypt::Mac::HMAC"     => 0,
    "CryptX"               => "0.021",
    "Cwd"                  => 0,
    "DBD::mysql"           => "4.050",
    "DBI"                  => "1.20",
    "DBIx::Simple"         => 0,
    "Data::Dumper"         => 0,
    "English"              => 0,
    "Exporter"             => 0,
    "ExtUtils::MakeMaker"  => 0,
    "File::Copy"           => 0,
    "File::Path"           => 0,
    "IO::File"             => 0,
    "JSON"                 => 0,
    "LWP::UserAgent"       => 0,
    "MIME::Base32"         => 0,
    "MIME::Base64"         => 0,
    "Net::DNS::ZoneFile"   => 0,
    "Net::IP"              => 0,
    "NicTool"              => 0,
    "Params::Validate"     => "0.8",
    "RPC::XML"             => 0,
    "RPC::XML::Parser"     => 0,
    "SOAP::Lite"           => "0.51",
    "Scalar::Util"         => 0,
    "Test"                 => 0,
    "Test::More"           => 0,
    "Test::Output"         => 0,
    "Time::HiRes"          => "1.9",
    "Time::Local"          => 0,
    "Time::TAI64"          => 2,
    "XML::Parser"          => 0,
    "constant"             => 0,
    "lib"                  => 0,
    "mod_perl"             => 0,
    "parent"               => "0.2",
    "strict"               => 0,
    "vars"                 => 0,
    "warnings"             => 0
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
    delete $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{BUILD_REQUIRES};
    $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
