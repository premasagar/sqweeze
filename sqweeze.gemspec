# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sqweeze}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrea Fiore"]
  s.date = %q{2010-05-01}
  s.default_executable = %q{sqweeze}
  s.description = %q{A command line web-asset optimisation tool}
  s.email = %q{and@inventati.org}
  s.executables = ["sqweeze"]
  s.extra_rdoc_files = ["README.rdoc", "bin/sqweeze", "lib/compilers/assetLinker.rb", "lib/compilers/cssDomCompiler.rb", "lib/compilers/jsDomCompiler.rb", "lib/compressor.rb", "lib/compressors/cssCompressor.rb", "lib/compressors/gifCompressor.rb", "lib/compressors/jpegCompressor.rb", "lib/compressors/jsCompressor.rb", "lib/compressors/pngCompressor.rb", "lib/confManager.rb", "lib/domCompiler.rb", "lib/sqweezeUtils.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "bin/sqweeze", "lib/compilers/assetLinker.rb", "lib/compilers/cssDomCompiler.rb", "lib/compilers/jsDomCompiler.rb", "lib/compressor.rb", "lib/compressors/cssCompressor.rb", "lib/compressors/gifCompressor.rb", "lib/compressors/jpegCompressor.rb", "lib/compressors/jsCompressor.rb", "lib/compressors/pngCompressor.rb", "lib/confManager.rb", "lib/domCompiler.rb", "lib/sqweezeUtils.rb", "spec/confManager_spec.rb", "spec/domCompiler_spec.rb", "spec/sqw_spec_helper.rb", "sqweeze.gemspec"]
  s.homepage = %q{http://github.com/premasagar/sqweeze}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sqweeze", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sqweeze}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A command line web-asset optimisation tool}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0", "= 0.8.2"])
      s.add_runtime_dependency(%q<closure-compiler>, [">= 0.2.2"])
      s.add_runtime_dependency(%q<yui-compressor>, [">= 0", "= 0.9.1"])
    else
      s.add_dependency(%q<hpricot>, [">= 0", "= 0.8.2"])
      s.add_dependency(%q<closure-compiler>, [">= 0.2.2"])
      s.add_dependency(%q<yui-compressor>, [">= 0", "= 0.9.1"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0", "= 0.8.2"])
    s.add_dependency(%q<closure-compiler>, [">= 0.2.2"])
    s.add_dependency(%q<yui-compressor>, [">= 0", "= 0.9.1"])
  end
end
