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
    begin
      mapping = YAML.parse(File.open(filepath)).children.first
    rescue
      puts "Couldn't read #{filepath}... "
      puts ""
      return
    end

    [TOP_LEVEL, NOMINAL, MEMBER].each do |type|
      parse_mapping(mapping, type, PROVIDER)
      parse_mapping(mapping, type, DEPENDENT)
    end

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

    if provide_or_depend == DEPENDENT
      values = get_non_private_depends(mapping, type)
      create_dependencies(values, type, PROVIDER)
    end

  end

  def get_non_private_depends(mapping, type)
    type = type_string(type, DEPENDENT)

    mapping.children.each_with_index do |child, index|
      if child.is_a?(Psych::Nodes::Scalar)
        if child.value == type
          node = mapping.children[index + 1]
          return get_non_private_children(node)
        end
      end
    end
  end

  def type_string(type, provide_or_depend)
    "#{prefix(provide_or_depend)}-#{type}"
  end

  def get_values(mapping, type, provide_or_depend)
    type = type_string(type, provide_or_depend)
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
      return unless value.is_a? String
      dependency = Dependency.find_or_create_by(value: value, dependency_type: type)
      FileDependency.find_or_create_by(dependency: dependency,
                            swift_file: self,
                            dependent_or_provider: provider_or_dependent)
  end

  def get_non_private_children(node)
    return unless node.is_a? Psych::Nodes::Sequence

    node.children.map do |child|
      next unless child.tag != "!private"
      if child.is_a? Psych::Nodes::Sequence
        child.children.map(&:value).join("-")
      elsif child.is_a? Psych::Nodes::Scalar
        child.value
      end
    end.compact
  end

  def parse_children(node)
    return unless node.is_a? Psych::Nodes::Sequence

    node.children.map do |child|
      if child.is_a? Psych::Nodes::Sequence
        child.children.map(&:value).join("-")
      elsif child.is_a? Psych::Nodes::Scalar
        child.value
      end
    end
  end
end
