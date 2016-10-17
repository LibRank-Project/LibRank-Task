package LibRank::Task::JSONReader;
use Moose;
use namespace::autoclean;

#use Smart::Comments -ENV;
use IO::File;
use JSON;
use Iterator::Simple qw(iter list);
use Iterator::Simple::Util qw(igroup);
use LibRank::Task qw(Doc);

sub from_file {
  my $class = shift;
  my $file = shift;
  my $fh = IO::File->new($file, '<:utf8')
	or die sprintf('Error opening file (%s)', $file);
  my $iter = iter($fh)->filter(sub { chomp; from_json($_); });
  return $iter;
}

# $iter: Iterator::Simple::Iterator
#		 $iter should return hashrefs that fulfill
#        1. Doc->assert_valid($iter->next)
#        2. and additionally contain the keys 'SearchTask' and 'query'
sub tasks {
  my $class = shift;
  my $iter = shift;
  ### ensure: $iter->isa('Iterator::Simple::Iterator')

  $iter = igroup { $a->{SearchTask} eq $b->{SearchTask} } $iter;
  return $iter->filter(sub {
	my $docs = list($_);
	my $task = LibRank::Task->new(
	  sid   => $docs->[0]{SearchTask},
	  query => $docs->[0]{query}
	);

	foreach my $doc (@$docs) {
	  delete $doc->{query};
	  delete $doc->{SearchTask};
	  $task->add_doc($doc);
	}
	return $task;
  });
}


__PACKAGE__->meta->make_immutable;
