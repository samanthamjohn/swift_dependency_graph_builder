require 'rails_helper'

describe SwiftFile, type: :model do
  before(:all) do
    ENV["ROOT_FILE_PATH"] = Rails.root.join("spec/fixtures").to_s

    @filename = "action_view.swiftdeps"
  end

  describe("provides") do
    it 'is dependencies where the file_dependency dependent_or_provider is provider' do
      file = SwiftFile.create(filename: @filename)
      provide = Dependency.create(value: "Foo")
      file_dependency = FileDependency.create(dependency: provide,
                                              swift_file: file,
                                              dependent_or_provider: SwiftFile::PROVIDER)

      expect(file.provides.map(&:id)).to eq([provide.id])
    end

    it 'does not include dependencies that are dependent' do
      file = SwiftFile.create(filename: @filename)
      dependency = Dependency.create(value: "Foo")
      file_dependency = FileDependency.create(dependency: dependency,
                                              swift_file: file,
                                              dependent_or_provider: SwiftFile::DEPENDENT)

      expect(file.provides.count).to eq(0)
    end
  end

  describe("depends") do
    it 'is dependencies where the file_dependency dependent_or_provider is dependent' do
      file = SwiftFile.create(filename: @filename)
      depend = Dependency.create(value: "Foo")
      file_dependency = FileDependency.create(dependency: depend,
                                              swift_file: file,
                                              dependent_or_provider: SwiftFile::DEPENDENT)

      expect(file.depends.map(&:id)).to eq([depend.id])
    end

    it 'does not include dependencies that are providers' do
      file = SwiftFile.create(filename: @filename)
      provider = Dependency.create(value: "Foo")
      file_dependency = FileDependency.create(dependency:provider,
                                              swift_file: file,
                                              dependent_or_provider: SwiftFile::PROVIDER)

      expect(file.depends.count).to eq(0)
    end
  end

  describe("setup_dependencies") do
    before(:all) do
      @swift_file = SwiftFile.create(filename: @filename)
      @swift_file.setup_dependencies
    end

    it 'sets the provides-top-level == ActionView' do
      top_level_provides = @swift_file.provides_for_type(SwiftFile::TOP_LEVEL)
      expect(top_level_provides.map(&:value)).to include("ActionView")
    end

    it 'adds non-private depends to the provides-top-level' do
      top_level_provides = @swift_file.provides_for_type(SwiftFile::TOP_LEVEL)
      expect(top_level_provides.map(&:value)).to include("BooleanLiteralType")
    end

    it 'does not add private depends to the provides-top-level' do
      top_level_provides = @swift_file.provides_for_type(SwiftFile::TOP_LEVEL)
      expect(top_level_provides.map(&:value)).not_to include("CGSize")
    end

    it 'sets the depends-top-level' do
      top_level_provides = @swift_file.depends_for_type(SwiftFile::TOP_LEVEL)
      expect(top_level_provides.map(&:value)).to eq(["CGSize", "*", "BooleanLiteralType"])
    end

    it 'provides-nominal includes entries in the provides-nominal sequence' do
      nominal_provides = @swift_file.provides_for_type(SwiftFile::NOMINAL)
      expect(nominal_provides.map(&:value)).to include("C9Hopscotch10ActionView")
    end

    it 'provides-nominal includes entries in the depends-nominal sequence that are not private' do
      nominal_provides = @swift_file.provides_for_type(SwiftFile::NOMINAL)
      expect(nominal_provides.map(&:value)).to include("C9Hopscotch10ActionView")
    end

    it 'does not duplicate dependencies' do
      nominal_provides = @swift_file.provides_for_type(SwiftFile::NOMINAL)
      expect(nominal_provides.map(&:value)).to eq(["C9Hopscotch10ActionView"])
    end

    it 'sets depends-nominal' do
      nominal_depends = @swift_file.depends_for_type(SwiftFile::NOMINAL)
      expect(nominal_depends.map(&:value)).to eq(["Ps16AbsoluteValuable", "C9Hopscotch10ActionView"])
    end

    it 'uses the same dependency when the value is the same' do
      nominal_depends = @swift_file.depends_for_type(SwiftFile::NOMINAL)
      nominal_provides = @swift_file.provides_for_type(SwiftFile::NOMINAL)
      expect(nominal_provides[0]).to eq(nominal_depends[1])
    end

    it 'sets provides dynamic-lookup == []' do
      provides = @swift_file.provides_for_type(SwiftFile::DYNAMIC_LOOKUP)
      expect(provides.map(&:value)).to eq([])
    end

    it 'sets depends-dynamic-lookup' do
      provides = @swift_file.depends_for_type(SwiftFile::DYNAMIC_LOOKUP)
      expect(provides.map(&:value)).to eq([])
    end

    it 'adds provides member from the sequence' do
      provides = @swift_file.provides_for_type(SwiftFile::MEMBER)
      expect(provides.map(&:value)).to include("C9Hopscotch10ActionView-")
    end

    it 'adds provides-member from non-private dependencies' do
      provides = @swift_file.provides_for_type(SwiftFile::MEMBER)
      expect(provides.map(&:value)).to include("Ps9Equatable-messageContainerView")
      expect(provides.map(&:value)).to include("Ps9Equatable-messageContainerView")
    end

    it 'sets depends-member' do
      provides = @swift_file.depends_for_type(SwiftFile::MEMBER)
      expect(provides.map(&:value)).to eq(["Ps16AbsoluteValuable-IntegerLiteralType", "Ps9Equatable-messageContainerView", "PSo8NSCoding-messageView"])
    end

    it "does not set depends-external" do
      provides = @swift_file.depends_for_type(SwiftFile::EXTERNAL)
      expect(provides.map(&:value)).to eq([])
    end
  end

end

