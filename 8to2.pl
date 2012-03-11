#!/usr/bin/perl

use strict;
use Getopt::Long;
my $fifteen = 0;
my $padding = 0;
my $help = 0;
my $octal = 0;
my $filename;

GetOptions("filename=s" => \$filename,
           "padding" => \$padding,
           "fifteen" => \$fifteen,
           "octal" => \$octal,
           "help" => \$help,
           "h" => \$help);

sub print_padding(@)
{
    my $num_zeros = @_[0];
    my $str = ('0' x $num_zeros);
    if ($padding)
    {
        printf("$str");
    }
}

sub convert_to_bin_24(@)
{
    my $octal_line = @_[0];

    #remove the whitespace from each line
    $octal_line =~ s/ //g;
    for (my $i = 0; $i < 5; $i++)
    {
        print_padding(4);
        #perl printf cant handle 024 digit in its formatting
        #so I had to break this one up into 4 groups of 6bits
        for (my $x = 0; $x < 4; $x++)
        {
            my $oct_data = substr($octal_line, ($i * 8) + ($x * 2), 2);
            if ($octal)
            {
                printf("%02o", oct($oct_data));
            }
            else
            {
                printf("%06b", oct($oct_data));
            }
        }
        print_padding(4);
        print("\n");
    }
}

sub convert_to_bin_15(@)
{
    my @octal_line = split(/ /,@_[0]);

    foreach my $word (@octal_line)
    {
        print_padding(4);
        if ($octal)
        {
            printf("%05o", oct($word));
        }
        else
        {
            printf("%015b", oct($word));
        }
        print_padding(5);
        print("\n");
    }
}

sub convert_oct_to_bin(@)
{
    #split the input up on the new lines
    my @octal_data = split(/\n/, @_[0]);

    #loop over each line in the input
    foreach my $octal_line (@octal_data)
    {
        if (!(($octal_line =~ /^;/) || 
            (length($octal_line) == 0) ||
            ($octal_line =~ /BANK/)))
        {
            if ($fifteen)
            {
                convert_to_bin_15($octal_line);
            }
            else
            {
                convert_to_bin_24($octal_line);
            }
        }
    }
}

sub print_help()
{
    print("\n--filename=<input.txt>\n");
    print("--padding - Add padding zeros to the front and end of the output\n");
    print("--fifteen - Print the output 15 bits per line (one opcode per line)\n");
    print("--octal   - Print the output in octal rather than binary\n");
    print("--help -h - get help\n\n");
    exit;
}

sub main()
{
    if ($help)
    {
        print_help();
    }
    else
    {
        #read input file
        my $octal_data;
        open FILE, $filename or print_help();
        while (<FILE>)
        {
            $octal_data .= $_;
        }
        close FILE;

        #convert the input to the output
        convert_oct_to_bin($octal_data);
    }
}

main();
