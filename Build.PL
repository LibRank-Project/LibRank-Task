use Module::Build;
use Module::Build::Prereqs::FromCPANfile;

my $build = Module::Build->new(
  module_name => 'LibRank::Task',
  dist_version => '0.01',
  dist_abstract => 'Task object',
  mb_prereqs_from_cpanfile()
);
$build->create_build_script;
