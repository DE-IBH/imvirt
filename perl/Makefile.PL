use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'ImVirt',
    'VERSION_FROM'	=> 'lib/ImVirt.pm', # finds $VERSION
    'PREREQ_PM'		=> {
	Module::Find => 0,
	File::Slurp => 0,
    },
);
