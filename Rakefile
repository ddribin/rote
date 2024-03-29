# Rote Rakefile (run with 'rake' command)
#
# Copyright 2005 Ross Bamford (and contributors). All rights reserved.
# Rote is distributed under an MIT style license.  See LICENSE for details.
#
# This Rakefile is heavily based on Rake's own Rakefile.
# Portions copyright (c)2003, 2004 Jim Weirich (jim <AT> weirichhouse.org)
#
# $Id: Rakefile 185 2006-10-26 19:41:31Z roscopeco $
#

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
# This needs to go at the front of the libpath
# Otherwise, any pre-installed rote gets found,
# and used from there. This is only necessary
# for Rote's build, to make sure we always unit-
# test and build doc with the working copy.
$LOAD_PATH.unshift 'lib'
require 'rote'
require 'rote/filters/redcloth'
require 'rote/filters/syntax'
require 'rote/filters/tidy'
require 'rote/format/html'
require 'rote/extratasks'
include Rote

CLEAN.include('tidy.log')
CLOBBER.include('TAGS')
CLOBBER.include('html')

def announce(msg='')
  STDERR.puts msg
end

# Determine the current version of the software

if `ruby -Ilib ./bin/rote --version` =~ /\S+$/
  CURRENT_VERSION = $&
else
  CURRENT_VERSION = "0.0.0"
end

if ENV['REL']
  PKG_VERSION = ENV['REL']
else
  PKG_VERSION = CURRENT_VERSION
end


SRC_RB = FileList['lib/**/*.rb']

# The default task is run if rake is given no explicit arguments.

desc "Default Task (All tests)"
task :default => :alltests

# Test Tasks ---------------------------------------------------------

task :ta => :alltests
#task :tf => :funtests
task :tu => :unittests
task :test => :unittests

Rake::TestTask.new(:alltests) do |t|
  t.test_files = FileList[
    'test/test*.rb',
    'test/contrib/test*.rb',
    'test/fun*.rb'
  ]
  t.warning = true
  t.verbose = true
end

Rake::TestTask.new(:unittests) do |t|
  t.test_files = FileList['test/test*.rb']
  t.warning = true
  t.verbose = false
end

# Rake::TestTask.new(:funtests) do |t|
#   t.test_files = FileList['test/fun*.rb']
#   t.warning = true
#   t.warning = true
# end

# directory 'testdata'
# [:alltests, :unittests].each do |t|
#   task t => ['testdata']
# end

# CVS Tasks ----------------------------------------------------------

# Install rote using the standard install.rb script.
desc "Install the application"
task :install do
  ruby "install.rb"
end

# Website / Doc tasks ------------------------------------------------

# Create a task to build the RDOC documentation tree.
rd = Rake::RDocTask.new(:rdoc) { |rdoc|
  rdoc.rdoc_dir = 'html/rdoc'
#  rdoc.template = 'kilmer'
#  rdoc.template = 'css2'
  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = "Rote"
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'LICENSE', 'TODO', 'CONTRIBUTORS')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
  rdoc.rdoc_files.exclude(/\bcontrib\b/)
  rdoc.rdoc_files.exclude('lib/rote/project/**/*')
}

# Code coverage report
Rote::RCovTask.new { |rcov|
  rcov.test_files.include 'test/gem*.rb'
  rcov.source_files.include 'lib/**/*.rb'
  rcov.profile = true
  rcov.output_dir = 'html/coverage'
}

# Create a task build the website / docs
ws = Rote::DocTask.new(:doc) { |site| 
  site.output_dir = 'html'
  site.layout_dir = 'doc/layouts'
  site.pages.dir = 'doc/pages'
  site.pages.include('**/*')  
  
  site.ext_mapping(/(html)/, '$1') do |page|
    # Let's use the HTML stuff everywhere ...
    page.extend Rote::Format::HTML
    
    # use 'page' layout, textile formatting, ruby syntax, Tidy to xhtml
    page.layout 'page'

    page.page_filter Filters::RedCloth.new(:textile)
    page.page_filter Filters::Syntax.new
    
    page.post_filter Filters::Tidy.new
  end
  
  site.res.dir = 'doc/res'
  site.res.include('**/*.png')
  site.res.include('**/*.gif')
  site.res.include('**/*.jpg')
  site.res.include('**/*.css')
}

# add rdoc/rcov deps to doc task
task :doc => [:rdoc, :rcov]

desc "Publish the documentation and web site"
task :doc_upload => [ :doc ] do
  if acct = ENV['RUBYFORGE_ACCT']
    require 'rake/contrib/sshpublisher'
    Rake::SshDirPublisher.new(
      "#{acct}@rubyforge.org",
      "/var/www/gforge-projects/rote",
      "html"
    ).upload
  else
    $stderr << "Skipping documentation upload - Need to set RUBYFORGE_ACCT to your rubyforge.org user name"
  end
end

# ====================================================================
# Create a task that will package the Rote software into distributable
# tar, zip and gem files.

# don't include rendered website and all that Jazz 
PKG_FILES = FileList[
  'install.rb',
  '[A-Z]*',
  'bin/**/*', 
  'lib/**/*.rb', 
  'lib/rote/builtin.rf', 
  'lib/rote/project/**/*',
  'test/**/*',
  'doc/**/*'
]

# don't want GIMP originals
PKG_FILES.exclude('**/*.xcf')

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    
    #### Basic information.

    s.name = 'rote'
    s.version = PKG_VERSION
    s.summary = "Adds template-based doc support to Rake."
    s.description = <<-EOF
      Rote is a set of Rake task libraries and utilities that
      enable easy rendering of textual documentation formats
      (like HTML) for websites and offline documentation.
    EOF

    #### Dependencies and requirements.

    s.add_dependency('RedCloth', '> 3.0')
    s.add_dependency('rake', '> 0.6')
    #s.requirements << ""

    #### Which files are to be included in this gem? 

    s.files = PKG_FILES.to_a

    #### Load-time details: library and application (you will need one or both).

    s.require_path = 'lib'                         # Use these for libraries.

    s.bindir = "bin"                               # Use these for applications.
    s.executables = ["rote"]
    s.default_executable = "rote"
    
    #### Documentation and testing.

    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options <<
      '--title' <<  'Rote -- Template-based doc support for Rake' <<
      '--main' << 'README' <<
      '--line-numbers' << 
      '--inline-source' <<
      '--template' << 'doc/jamis.rb'
      '-o' << 'html'      

    s.test_files = Dir.glob('test/gem_*.rb')
    
    #### Author and project details.

    s.author = "Ross Bamford"
    s.email = "ross@roscopeco.co.uk"
    s.homepage = "http://rote.rubyforge.org"
    s.rubyforge_project = "rote"
#     if ENV['CERT_DIR']
#       s.signing_key = File.join(ENV['CERT_DIR'], 'gem-private_key.pem')
#       s.cert_chain  = [File.join(ENV['CERT_DIR'], 'gem-public_cert.pem')]
#     end
  end
  
  # Quick fix for Ruby 1.8.3 / YAML bug
  if (RUBY_VERSION == '1.8.3')
    def spec.to_yaml
      out = super
      out = '--- ' + out unless out =~ /^---/
      out
    end  
  end

  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar_gz = true
    pkg.package_dir = 'pkg'    
  end
end

# Misc tasks =========================================================

def count_lines(filename)
  lines = 0
  codelines = 0
  open(filename) { |f|
    f.each do |line|
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  }
  [lines, codelines]
end

def show_line(msg, lines, loc)
  printf "%6s %6s   %s\n", lines.to_s, loc.to_s, msg
end

desc "Count total lines in source"
task :lines do
  total_lines = 0
  total_code = 0
  show_line("File Name", "LINES", "LOC")
  SRC_RB.each do |fn|
    lines, codelines = count_lines(fn)
    show_line(fn, lines, codelines)
    total_lines += lines
    total_code  += codelines
  end
  show_line("TOTAL", total_lines, total_code)
end

ARCHIVEDIR = '/mnt/usb'

task :archive => [:package] do
  cp FileList["pkg/*.tar.gz", "pkg/*.zip", "pkg/*.gem"], ARCHIVEDIR
end

# Define an optional publish target in an external file.  If the
# publish.rf file is not found, the publish targets won't be defined.

load "publish.rf" if File.exist? "publish.rf"

# Support Tasks ------------------------------------------------------

desc "Look for TODO and FIXME tags in the code"
task :todo do
  FileList['**/*.rb'].egrep /#.*(FIXME|TODO|TBD)/
end

desc "Look for Debugging print lines"
task :dbg do
  FileList['**/*.rb'].egrep /\bDBG|\bbreakpoint\b/
end

desc "List all ruby files"
task :rubyfiles do 
  puts Dir['**/*.rb'].reject { |fn| fn =~ /^pkg/ }
  puts Dir['bin/*'].reject { |fn| fn =~ /CVS|(~$)|(\.rb$)/ }
end

desc "Show deprecation notes"
task :deprecated do
  Dir['lib/**/*.r?'].each do |fn|
    File.open(fn) do |f| 
      [*f].each_with_index do |line,i| 
        if line =~ /#(.*)vv([0-9\.]+)(?:[\s\t]*)v-([0-9\.]+)/
          cmnt = $~[1].strip
          cmnt = '<No comment>' if (cmnt.nil? or cmnt.empty?)          
          printf "%s:%d\n%-60s    %5s    %5s\n\n", fn, i+1, cmnt, $~[2].strip, $~[3].strip
        end #if splits okay
      end #each_w_idx
    end #fopen
  end #dir
end

desc "Find features deprecated at VER"
task :deprecated_by do
  fail "\nYou must specify the version to check (VER=x.y.z)\n\n" unless ver = ENV['VER']
  Dir['lib/**/*.r?'].each do |fn|
    File.open(fn) do |f| 
      [*f].each_with_index do |line,i| 
        if line =~ /vv#{ver}/
          if line =~ /#(.*)vv([0-9\.]+)(?:[\s\t]*)v-([0-9\.]+)/
            cmnt = $~[1].strip
            cmnt = '<No comment>' if (cmnt.nil? or cmnt.empty?)          
            printf "%s:%d\n%-60s    %5s    %5s\n\n", fn, i+1, cmnt, $~[2].strip, $~[3].strip
          end #if splits okay
        end #if line is dep remove
      end #each_w_idx
    end #fopen
  end #dir
end

desc "Find deprecated features to be removed by VER"
task :deprecated_due do
  fail "\nYou must specify the version to check (VER=x.y.z)\n\n" unless ver = ENV['VER']
  Dir['lib/**/*.r?'].each do |fn|
    File.open(fn) do |f| 
      [*f].each_with_index do |line,i| 
        if line =~ /v-#{ver}/
          if line =~ /#(.*)vv([0-9\.]+)(?:[\s\t]*)v-([0-9\.]+)/
            cmnt = $~[1].strip
            cmnt = '<No comment>' if (cmnt.nil? or cmnt.empty?)          
            printf "%s:%d\n%-60s    %5s    %5s\n\n", fn, i+1, cmnt, $~[2].strip, $~[3].strip
          end #if splits okay
        end #if line is dep remove
      end #each_w_idx
    end #fopen
  end #dir
end

# --------------------------------------------------------------------
# Creating a release

desc "Make a new release"
task :release => [
  :prerelease,
  :clobber,
  :alltests,
  :update_version,
  :package,
  :tag,
  :doc_upload] do
  
  announce 
  announce "**************************************************************"
  announce "* Release #{PKG_VERSION} Complete."
  announce "* Packages ready to upload."
  announce "**************************************************************"
  announce 
end

# Validate that everything is ready to go for a release.
task :prerelease do
  announce 
  announce "**************************************************************"
  announce "* Making RubyGem Release #{PKG_VERSION}"
  announce "* (current version #{CURRENT_VERSION})"
  announce "**************************************************************"
  announce  

  # Is a release number supplied?
  unless ENV['REL']
    fail "Usage: rake release REL=x.y.z [REUSE=tag_suffix]"
  end

  # Is the release different than the current release.
  # (or is REUSE set?)
  if PKG_VERSION == CURRENT_VERSION && ! ENV['REUSE']
    fail "Current version is #{PKG_VERSION}, must specify REUSE=tag_suffix to reuse version"
  end

  # Are all source files checked in?
  if ENV['RELTEST']
    announce "Release Task Testing, skipping checked-in file test"
  else
    announce "Checking for unchecked-in files..."
    data = `svn status`
    unless data =~ /^$/
      fail "SVN status is not clean ... do you have unchecked-in files?"
    end
    announce "No outstanding checkins found ... OK"
  end
end

task :update_version => [:prerelease] do
  if PKG_VERSION == CURRENT_VERSION
    announce "No version change ... skipping version update"
  else
    announce "Updating Rote version to #{PKG_VERSION}"
    open("lib/rote.rb") do |rakein|
      open("lib/rote.rb.new", "w") do |rakeout|
	rakein.each do |line|
	  if line =~ /^ROTEVERSION\s*=\s*/
	    rakeout.puts "ROTEVERSION = '#{PKG_VERSION}'"
	  else
	    rakeout.puts line
	  end
	end
      end
    end
    mv "lib/rote.rb.new", "lib/rote.rb"
    if ENV['RELTEST']
      announce "Release Task Testing, skipping commiting of new version"
    else
      sh %{svn commit -m "Updated to version #{PKG_VERSION}" lib/rote.rb}
    end
  end
end

desc "Create a new SVN tag with the latest release number (REL=x.y.z)"
task :tag => [:prerelease] do
  reltag = "REL_#{PKG_VERSION.gsub(/\./, '_')}"
  reltag << ENV['REUSE'].gsub(/\./, '_') if ENV['REUSE']
  announce "Tagging CVS with [#{reltag}]"
  if ENV['RELTEST']
    announce "Release Task Testing, skipping SVN tagging"
  else
    # need to get current base URL
    s = `svn info`
    if s =~ /URL:\s*([^\n]*)\n/
      svnroot = $1
      if svnroot =~ /^(.*)\/trunk/
        svnbase = $1
        sh %{svn cp #{svnroot} #{svnbase}/tags/#{reltag} -m "Release #{PKG_VERSION}"}
      else
        fail "Please merge to trunk before making a release"
      end
    else 
      fail "Unable to determine repository URL from 'svn info' - is this a working copy?"
    end  
  end
end

# Require experimental XForge/Metaproject support.
# load 'xforge.rf' if File.exist?('xforge.rf')

