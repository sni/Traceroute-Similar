use 5.008000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Traceroute::Similar',
    VERSION_FROM      => 'lib/Traceroute/Similar.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Traceroute/Similar.pm', # retrieve abstract from module
       AUTHOR         => 'Sven Nierlein <nierlein@cpan.org>') : ()),
);
