use strict;
use inc::Module::Install;

name        'MessageBus';
license     'MIT';
all_from    'lib/MessageBus.pm';

requires    'DBM::Deep';
requires    'Data::UUID';
requires    'Class::Accessor::Fast';

sign; WriteAll;
