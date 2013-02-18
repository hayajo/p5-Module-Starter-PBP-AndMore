use inc::Module::Install;
use Module::Install::Repository;
use Module::Install::ReadmePodFromPod;
name 'Module-Starter-PBP-AndMore';
all_from 'lib/Module/Starter/PBP/AndMore.pm';
readme_pod_from 'lib/Module/Starter/PBP/AndMore.pm';

requires 'Module::Starter'      => '1.60';
requires 'Module::Starter::PBP' => '0.0.3';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
