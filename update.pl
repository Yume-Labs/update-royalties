use strict;
use warnings;

use Const::Fast;
use File::Slurp;
use Getopt::Args;
use JSON;

use Data::Dumper;

arg input => (
    isa => 'Str',
    comment => 'The folder containing the output from metaboss decode.',
    required => 1
);

arg output => (
    isa => 'Str',
    comment => 'The folder to write output to.',
    required => 1
);

arg creators => (
    isa => 'Str',
    comment => 'List of colon-separated creators in the format: CREATOR,SHARE,VERIFIED i.e. EDgWRRm2XtiGkddk4vVzFYvh5Vay9jMkvh8WbaqZDxiE,100,false:GkCN4jAHcCoBdNuHkmGygdmjasbceyMhzFsy82Hpdq8y,0,true',
    required => 1
);

opt verbose => (
    isa => 'Bool',
    default => 0,
    comment => 'Print extra debug information.'
);

my $ref = optargs;
my $json = JSON->new->allow_nonref;

die "Input directory not found." unless (-d $ref->{input});
die "Output directory not found." unless (-d $ref->{output});

my @files = glob($ref->{input} . '/*.json');

my @creators_raw = split(/\:/, $ref->{creators});
my @creators = ();

for my $creator (@creators_raw) {
    my @split_creator = split(/,/, $creator);

    die "Creators are formatted incorrectly." unless (
        scalar(@split_creator) == 3 &&
        int($split_creator[1]) <= 100 &&
        int($split_creator[1]) >= 0 &&
        (
            $split_creator[2] eq 'true' ||
            $split_creator[2] eq 'false'
        )
    );

    my %local_creator = (
        address => $split_creator[0],
        share => $split_creator[1],
        verified => $split_creator[2] eq 'true' ? $JSON::true : $JSON::false
    );

    push(@creators, \%local_creator);
}

for my $file (@files) {
    my $obj = $json->decode(read_file($file));

    my %nft_data = (
        name => $obj->{data}->{name},
        symbol => $obj->{data}->{symbol},
        uri => $obj->{data}->{uri},
        seller_fee_basis_points => $obj->{data}->{seller_fee_basis_points},
        creators => \@creators
    );

    my %new_obj = (
        mint_account => $obj->{mint},
        nft_data => \%nft_data
    );

    print "Saving ${$obj->{mint}}." if $ref->{verbose};
    open(my $fh, '>', $ref->{output} . '/' . $obj->{mint} . '.json');

    print $fh $json->encode(\%new_obj);
    close($fh);
}
