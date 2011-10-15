require 'pathname'

APPLICATION = "ekylibre".freeze

locales = Dir["???"].select do |locale|
  File.exist?(File.join(locale, "index.xml"))
end

def xsltproc(source, stylesheet, options={})
  command  = "xsltproc --xinclude --nonet"
  command << " #{options.delete(:args)}" if options[:args]
  for name, value in options
    command << " --stringparam #{name} #{value}"
  end
  command << " /usr/share/xml/docbook/stylesheet/docbook-xsl/#{stylesheet}"
  command << " #{source}"
  return `#{command}`
end

def compress_dir(source)
  basename = File.basename(source)
  command = "cd #{File.dirname(source)}"
  command << " && tar cjvf #{basename}.tar.bz2 #{basename}"
  command << " && tar czvf #{basename}.tar.gz  #{basename}"
  command << " && zip -r   #{basename}.zip     #{basename}"
  return `#{command}`
end

def layoutize(files)

  replaces = {
    "</head>"=>"head",
    "<body>"=>"body-top",
    "</body>"=>"body-bottom"
  }
  for k, v in replaces
    File.open("layout/#{v}.html", "rb") do |f|
      replaces[k] = f.read.gsub(/\s*\n\s*/, '').to_s
      replaces[k].gsub!(/(src|href)\=((\'|\")[^\'\"]+(\'|\"))/) do |m|
        o = m.split("=")
        n = [o[0], o[1..-1].join("=")]
        n[1].gsub!(/[\'\"]/, '')
        unless n[1].match(/http(s)?:\/\//)
          n[1] = "https://www.ekylibre.org/site#{'/' unless n[0].match(/^\//)}"+n[1]
        end
        n[1] = "\"#{n[1]}\""
        n.join("=")
      end
    end
  end

  for file in files
    source = ""
    File.open(file, 'rb') { |f| source = f.read.to_s }
    for k, v in replaces
      source.gsub!(k, v)
    end
    File.open(file, 'wb') { |f| f.write(source) }
  end
end

def add_assets(source, dest, mode=:cp_r)
  Dir.chdir(source) do
    Dir.glob("*") do |asset|
      FileUtils.send(mode, source.join(asset), dest.join(asset)) if File.directory?(asset)
    end
  end
end


desc "Build version.xml with VERSION"
task :version do
  version = []
  root = Pathname.new(File.dirname(__FILE__))
  File.open(root.join("VERSION"), "rb:UTF-8") do |f|
    version = f.read.split(".")
  end
  File.open(root.join("version.xml"), "wb:UTF-8") do |f|
    f.write "<!-- Don't edit this file directly, use `rake version` to update it. -->\n"
    f.write "<!ENTITY version \"#{version.join('.')}\">\n"
    f.write "<!ENTITY majorversion \"#{version[0..1].join('.')}\">\n"
  end
end


desc "Build documentation for all locales (#{locales.join(', ')})"
task :doc do
  root = Pathname.new(File.dirname(__FILE__))
  dir = root.join('manual')
  version = "x.y.z"
  File.open(root.join("VERSION"), "rb:UTF-8") do |f|
    version = f.read
  end

  FileUtils.rm_rf(dir)

  options = {"section.autolabel"=>1, "section.autolabel.max.depth" => 5, "section.label.includes.component.label"=> 1, "toc.section.depth" => 4, "generate.index" => 1}

  for locale in locales
    source_dir = root.join(locale)
    source = source_dir.join("index.xml")
    next unless File.exist?(source)
    ldir = dir.join(locale)
    base_name = "#{APPLICATION}-#{version}-#{locale}"

    # website
    odir = ldir.join(base_name)
    FileUtils.mkdir_p(odir)
    xsltproc(source, "xhtml/chunk.xsl", options.merge("base.dir" => odir.to_s+"/", "html.stylesheet" => "stylesheets/global.css", "chunk.quietly" => 1, "use.id.as.filename" => "yes"))
    layoutize(Dir.glob(odir.join("*.html")))
    add_assets(source_dir, odir)
    compress_dir(odir)

    # monolithic
    odir = ldir.join("#{base_name}.monolithic")
    FileUtils.mkdir_p(odir)
    xsltproc(source, "xhtml/docbook.xsl", options.merge(:args => "-o #{odir.join('index.html')}", "base.dir" => odir.to_s+"/", "html.stylesheet" => "stylesheets/global.css"))
    add_assets(source_dir, odir)
    compress_dir(odir)

    # pdf
    odir = ldir.join("pdf")
    FileUtils.mkdir_p(odir)
    fo = odir.join('_.fo')
    xsltproc(source, "fo/docbook.xsl", options.merge(:args => "-o #{fo}", "base.dir" => odir.to_s+"/", "default.image.width" => 400, "draft.mode" => "no", "paper.type" => "A4"))
    add_assets(source_dir, odir, :ln_sf)
    `fop #{fo} #{ldir.join("#{base_name}.pdf")}`
    FileUtils.rm_rf(odir)

  end
end

#              
task :default=>[:version, :doc]
