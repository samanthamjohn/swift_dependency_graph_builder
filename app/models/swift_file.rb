class SwiftFile < ActiveRecord::Base
  has_many :file_providers, -> { where("dependent_or_provider = '#{PROVIDER}'") }, class_name: "FileDependency"
  has_many :provides, through: :file_providers, class_name: "Dependency", source: :dependency

  has_many :file_depends, -> { where("dependent_or_provider = '#{DEPENDENT}'") }, class_name: "FileDependency"
  has_many :depends, through: :file_depends, class_name: "Dependency", source: :dependency

  validate :filename, required: true


  DEPENDENT = "dependent"
  PROVIDER = "provider"
  TOP_LEVEL = "top-level"
  NOMINAL = "nominal"
  DYNAMIC_LOOKUP = "dynamic-lookup"
  MEMBER = "member"
  EXTERNAL = "external"

  def swift_filename
    filename.chomp("deps")
  end

  def setup_dependencies
    mapping = YAML.parse(File.open(filepath)).children.first

    [TOP_LEVEL, NOMINAL, DYNAMIC_LOOKUP, MEMBER].each do |type|
      parse_mapping(mapping, type, PROVIDER)
      parse_mapping(mapping, type, DEPENDENT)
    end

    parse_mapping(mapping, EXTERNAL, DEPENDENT)
  end

  def provides_for_type(type)
    provides.where("dependency_type = ?", type)
  end

  def depends_for_type(type)
    depends.where("dependency_type = ?", type)
  end

  private

  def filepath
    File.expand_path(ENV["ROOT_FILE_PATH"] + "/" + filename)
  end


  def parse_mapping(mapping, type, provide_or_depend)
    values = get_values(mapping, type, provide_or_depend)
    create_dependencies(values, type, provide_or_depend)

  end

  def get_values(mapping, type, provide_or_depend)
    type = "#{prefix(provide_or_depend)}-#{type}"
    mapping.children.each_with_index do |child, index|
      if child.is_a?(Psych::Nodes::Scalar)
        if child.value == type
          node = mapping.children[index + 1]
          return parse_children(node)
        end
      end
    end
  end

  def prefix(provide_or_depend)
    if provide_or_depend == PROVIDER
      "provides"
    else
      "depends"
    end
  end

  def create_dependencies(values, type, provide_or_depend)
    return if values.blank?
    values.each do |value|
      create_dependency(value, type, provide_or_depend)
    end
  end

  def create_dependency(value, type, provider_or_dependent)
      dependency = Dependency.find_or_create_by(value: value, dependency_type: type)
      FileDependency.find_or_create_by(dependency: dependency,
                            swift_file: self,
                            dependent_or_provider: provider_or_dependent)
  end

  def parse_children(node)
    return unless node.is_a? Psych::Nodes::Sequence

    node.children.map do |child|
      if child.is_a? Psych::Nodes::Sequence
        child.children.map(&:value).join("-")
      else if child.is_a? Psych::Nodes::Value
        child.value
      else
        ""
      end
    end
  end
end
