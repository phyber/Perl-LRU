package LRU;
require Tie::Hash;
use strict;
use warnings;
use Time::HiRes qw /time/;

sub TIEHASH {
	my ($class, %args) = @_;
	my $hash = bless {
		%args,
		_data	=> {},
		_time	=> {},
	}, $class;
	# Set a default size for the hash if one wasn't passed.
	if (!$hash->{size}) {
		$hash->{size} = 10;
	}
	return $hash;
}

sub STORE {
	my ($self, $key, $value) = @_;
	my $data = $self->{_data};
	my $time = $self->{_time};
	$data->{$key} = $value;
	$time->{$key} = time();
	my $size = keys %{$data};
	if ($size > $self->{size}) {
		# If the hash is too big, time the last recently accessed key and delete it.
		foreach my $key (sort { $time->{$a} cmp $time->{$b} } keys %{$time}) {
			delete $data->{$key};
			delete $time->{$key};
			last;
		}
	}
}

sub FETCH {
	my ($self, $key) = @_;
	my $data = $self->{_data};
	my $time = $self->{_time};
	# Update the last access time
	$time->{$key} = time();
	return $data->{$key};
}

sub FIRSTKEY {
	my ($self) = @_;
	my $data = $self->{_data};
	my $a = scalar keys %{$data};
	each %{$data};
}

sub NEXTKEY {
	my ($self) = @_;
	my $data = $self->{_data};
	each %{$data};
}

sub EXISTS {
	my ($self, $key) = @_;
	my $data = $self->{_data};
	exists $data->{$key};
}

sub DELETE {
	my ($self, $key) = @_;
	my $data = $self->{_data};
	my $time = $self->{_time};
	delete $time->{$key};
	delete $data->{$key};
}

sub CLEAR {
	my ($self, $key) = @_;
	my $data = $self->{_data};
	my $time = $self->{_time};
	%{$data} = ();
	%{$time} = ();
}

sub SCALAR {
	my ($self) = @_;
	my $data = $self->{_data};
	scalar %{$data};
}

1;
