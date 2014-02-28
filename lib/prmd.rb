require "diff-lcs"
require "erubis"
require "json"

dir = File.dirname(__FILE__)
require File.join(dir, 'prmd', 'commands', 'combine')
require File.join(dir, 'prmd', 'commands', 'doc')
require File.join(dir, 'prmd', 'commands', 'expand')
require File.join(dir, 'prmd', 'commands', 'init')
require File.join(dir, 'prmd', 'commands', 'verify')
require File.join(dir, 'prmd', 'schema')
require File.join(dir, 'prmd', 'version')

module Prmd
end
