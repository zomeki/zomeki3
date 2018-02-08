class Cms::Lib::Modules::ModuleSet
  @@modules = nil

  attr_accessor :name
  attr_accessor :label
  attr_accessor :sort_no
  attr_accessor :contents
  attr_accessor :directories
  attr_accessor :pages
  attr_accessor :pieces

  def self.load_modules
    @@modules
  end

  def self.draw(name, label, sort_no, &block)
    @@modules = [] unless @@modules
    yield mod = self.new
    mod.name  = name
    mod.label = label
    mod.sort_no = sort_no
    @@modules << mod
  end

  def initialize
    @contents    = []
    @directories = []
    @pages       = []
    @pieces      = []
  end
  
  def content(name, label, options = {})
    @contents << Model.new(self, name, label, :content, options)
  end
  
  def directory(name, label, options = {})
    label = "ディレクトリ/#{label}" if label != 'ディレクトリ'
    @directories << Model.new(self, name, label, :directory, options)
  end
  
  def page(name, label, options = {})
    label = "ページ/#{label}"
    @pages << Model.new(self, name, label, :page, options)
  end
  
  def piece(name, label, options = {})
    @pieces << Model.new(self, name, label, :piece, options)
  end

  class Model
    attr_accessor :name
    attr_accessor :label
    attr_accessor :type
    attr_accessor :options
    
    def initialize(mod, name, label, type = nil, options = {})
      @mod = mod
      self.name  = name
      self.label = label
      self.type  = type
      self.options = options
    end

    def model
      "#{@mod.name}/#{name}".singularize.camelize
    end

    def full_label
      "#{@mod.label}/#{label}"
    end
  end
end
