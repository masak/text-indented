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

done;
