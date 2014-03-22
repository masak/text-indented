grammar Text::Indented;

class TooMuchIndent is Exception {}

constant TABSTOP = 4;

regex TOP {
    :my @*SUITES = "root";

    <line>*
}

sub indent { @*SUITES.end }

regex line {
    ^^ (<{ "\\x20" x TABSTOP }>*) (\h*) (\N*) $$ \n?

    {
        my $new_indent = $0.chars div TABSTOP;

        die TooMuchIndent.new
            if $new_indent > indent() + 1;
    }
}
