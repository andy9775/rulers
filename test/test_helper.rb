require 'rack/test'
require 'test/unit'

#
# always use the local rulers installation
# first fetch the local directory
d = File.join(File.dirname(__FILE__), '..', 'lib')
# Add local rulers directory to head of LOAD_PATH
$LOAD_PATH.unshift File.expand_path(d)
# $LOAD_PATH is a list of directories which are checked when requiring a library
#

require 'rulers'
