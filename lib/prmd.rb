require "diff-lcs"
require "erubis"
require "json"

dir = File.dirname(__FILE__)
require File.join(dir, 'prmd', 'combine')
require File.join(dir, 'prmd', 'doc')
require File.join(dir, 'prmd', 'expand')
require File.join(dir, 'prmd', 'init')
require File.join(dir, 'prmd', 'verify')
require File.join(dir, 'prmd', 'version')

module Prmd
end
