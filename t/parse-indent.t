use Test;
use Text::Indented;

sub parse($input) {
    Text::Indented.parse($input)
        or die "Couldn't parse input";
    return $/.ast;
}

sub parses_correctly($input, $message) {
    try {
        parse($input);
        ok 1, $message;

        CATCH {
            ok 0, $message;
        }
    }
}

sub fails_with($input, $ex_type, $message = $ex_type.^name) {
    try {
        parse($input);
        ok 0, $message;

        CATCH {
            ok $_ ~~ $ex_type, $message;
            default {
                die $_ unless $_ ~~ $ex_type;
            }
        }
    }
}

{
    my $input = q:to/EOF/;
    Level 1
        Level 2
    EOF

    parses_correctly($input, 'single indent');
}

{
    my $input = q:to/EOF/;
    Level 1
            Level 3!
    EOF

    fails_with($input, Text::Indented::TooMuchIndent);
}

{
    my $input = q:to/EOF/;
    Level 1
        Level 2
    EOF

    my $root = parse($input);

    isa_ok $root, Text::Indented::Suite;
    is $root.items.elems, 2, 'two things were parsed:';
    isa_ok $root.items[0], Str, 'a string';
    isa_ok $root.items[1], Text::Indented::Suite, 'and a suite';
}

{
    my $input = q:to/EOF/;
    Level 1
        Level 2
    Level 1 again
    EOF

    my $root = parse($input);

    is $root.items.elems, 3, 'three things were parsed:';
    isa_ok $root.items[0], Str, 'a string';
    isa_ok $root.items[1], Text::Indented::Suite, 'a suite';
    isa_ok $root.items[2], Str, 'and a string';
}

{
    my $input = q:to/EOF/;
    Level 1
        Level 2
            Level 3
            Level 3
    Level 1 again
    EOF

    my $root = parse($input);

    is $root.items.elems, 3, 'three things on the top level';
    is $root.items[1].items[1].items.elems, 2, 'two lines on indent level 3';
}

{
    my $input = q:to/EOF/;
    Level 1
          Level 2 and a half!
    EOF

    fails_with($input, Text::Indented::PartialIndent);
}

{
    my $input = q:to/EOF/;
        Level 2 already on the first line!
    EOF

    fails_with($input, Text::Indented::InitialIndent);
}

done;
