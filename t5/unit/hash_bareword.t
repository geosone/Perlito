
no warnings;

print "1..12\n";
my $v;

{
    @ARGV = ("yy");
    my %h = ( +foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "foo";
    print "ok 1 - +foo is bareword before '=>'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h = ( -foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "-foo";
    print "ok 2 - -foo is bareword before '=>'; concatenates '-'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h = ( foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "foo";
    print "ok 3 - foo is bareword before '=>'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h = ( +Baz::foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "Baz::foo";
    print "ok 4 - +Baz::foo is bareword before '=>'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h = ( -Baz::foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "-Baz::foo";
    print "ok 5 - -Baz::foo is bareword before '=>'; concatenates '-'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h = ( Baz::foo => 101, );
    ($v) = keys %h;
    print "not " if $v ne "Baz::foo";
    print "ok 6 - Baz::foo is bareword before '=>'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{ +foo } = 101;
    ($v) = keys %h;
    print "not " if $v ne "foo";
    print "ok 7 - +foo is bareword in hash index  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{-foo} = 101;
    ($v) = keys %h;
    print "not " if $v ne "-foo";
    print "ok 8 - -foo is bareword in hash index; concatenates '-'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{foo} = 101;
    ($v) = keys %h;
    print "not " if $v ne "foo";
    print "ok 9 - foo is bareword call in hash index  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{ +Baz::foo } = 101;
    ($v) = keys %h;
    print "not " if $v ne "Baz::foo";
    print "ok 10 - +Baz::foo is bareword in hash index  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{ -Baz::foo } = 101;
    ($v) = keys %h;
    print "not " if $v ne "-Baz::foo";
    print "ok 11 - -Baz::foo is bareword in hash index; concatenates '-'  # $v\n";
}
{
    @ARGV = ("yy");
    my %h;
    $h{ Baz::foo } = 101;
    ($v) = keys %h;
    print "not " if $v ne "Baz::foo";
    print "ok 12 - Baz::foo is bareword in hash index  # $v\n";
}

