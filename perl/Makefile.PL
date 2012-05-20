use ExtUtils::MakeMaker;

WriteMakefile(
    'AUTHOR'		=> 'Thomas Liske <liske@ibh.de>',
    'LICENSE'		=> 'gpl',
    'NAME'		=> 'ImVirt',
    'VERSION_FROM'	=> 'lib/ImVirt.pm',
    'PREREQ_PM'		=> {
	Module::Find => 0,
	File::Slurp => 0,
	File::Which => 0,
    },
);
