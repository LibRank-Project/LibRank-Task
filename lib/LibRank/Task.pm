package LibRank::Task;
use Moose;
use namespace::autoclean;

#use Smart::Comments -ENV;
use MooseX::Types::Moose qw(Str Num Int Bool ArrayRef HashRef);
use MooseX::Types::Structured qw(Dict Map slurpy);
use MooseX::Types -declare => [ qw(Doc) ];

subtype Doc,
  as Dict[
	record_id => Str,
	features => Map[ Str, Num ],
	qrel => Dict[ gradual => Int, binary => Bool ],
	slurpy HashRef
  ];


has 'query' => (is => 'ro', required => 1);
has 'sid'   => (is => 'ro', required => 1);
# docs should have a stable ordering (e.g. needed to build feature matrix)
has '_docs'  => (is => 'rw', isa=> ArrayRef[Doc], default => sub { [] });
# fast lookup of docs (e.g. needed to merge data with other doc lists)
has '_docs_idx'  => (is => 'rw', default => sub { {} });


sub add_doc {
  my $self = shift;
  my $doc = shift;
  ### ensure: Doc->assert_valid($doc);

  my $rid = $doc->{record_id};
  push @{$self->_docs}, $doc;
  $self->_docs_idx->{$rid} = $doc;
}

sub docs {
  my $self = shift;
  return $self->_docs;
}

sub doc_ids {
  my $self = shift;
  return [ map { $_->{record_id} } @{$self->_docs} ];
}

sub get_doc {
  my $self = shift;
  my $rid = shift;

  return $self->_docs_idx->{$rid};
}

__PACKAGE__->meta->make_immutable;
