imvirtp: imvirtp-core imvirtp-bundle

imvirtp-core: ../imvirt ../perl/lib/ImVirt.pm ../perl/lib/ImVirt/*/*.pm
	pp -x -P -o imvirtp-core -I ../perl/lib ../imvirt

imvirtp-bundle: ../imvirt ../perl/lib/ImVirt.pm ../perl/lib/ImVirt/*/*.pm
	pp -x -B -P -o imvirtp-bundle -I ../perl/lib ../imvirt
