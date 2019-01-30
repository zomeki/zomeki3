require 'csv'

# patch for ruby 2.6.0
CSV.singleton_class.prepend Module.new {
  def generate(str=nil, **options)
    options[:encoding] ||= 'utf-8'
    super(str, options)
  end
}
