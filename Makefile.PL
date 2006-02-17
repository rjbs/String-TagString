use strict;
use warnings;

use inc::Module::Install;

name          ('Text-TagString');
author        ('Ricardo SIGNES <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/Text/TagString.pm');

sign(1);

WriteAll();
