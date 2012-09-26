use strict;
use warnings;
$\ =$/;
my @words = qw ( Is there any body ? );
splice(@words, 4, 0, 'out','there');
#              |  |   |______|
#              |__|___|_start from index
#                 |___|__how many to remove
#                     |____what to place there 
print join(" ", @words);

splice(@words, 4, 1 );
#              |  |   |______|
#              |__|___|_start from index
#                 |___|__how many to remove
#                     |____what to place there 
print join(" ", @words);