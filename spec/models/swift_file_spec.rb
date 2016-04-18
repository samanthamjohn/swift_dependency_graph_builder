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
      expect(top_level_provides.map(&:value)).to eq(["ActionView"])
    end

    it 'sets the depends-top-level' do
      top_level_provides = @swift_file.depends_for_type(SwiftFile::TOP_LEVEL)
      expect(top_level_provides.map(&:value)).to eq(["CGSize", "*", "BooleanLiteralType"])
    end

    it 'sets provides-nominal == [C9Hopscotch10ActionView]' do
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

    it 'sets provides dynamic-lookup == ["execution_completion", "layout_subviews"]' do
      provides = @swift_file.provides_for_type(SwiftFile::DYNAMIC_LOOKUP)
      expect(provides.map(&:value)).to eq(["executeCompletion", "layoutSubviews"])
    end

    it 'sets depends-dynamic-lookup' do
      provides = @swift_file.depends_for_type(SwiftFile::DYNAMIC_LOOKUP)
      expect(provides.map(&:value)).to eq([])
    end

    it 'sets provides member == [["C9Hopscotch10ActionView", ""]]' do
      provides = @swift_file.provides_for_type(SwiftFile::MEMBER)
      expect(provides.map(&:value)).to eq(["C9Hopscotch10ActionView-"])
    end

    it 'sets depends-member' do
      provides = @swift_file.depends_for_type(SwiftFile::MEMBER)
      expect(provides.map(&:value)).to eq(["Ps16AbsoluteValuable-IntegerLiteralType", "Ps9Equatable-messageContainerView", "PSo8NSCoding-messageView"])
    end

    it "sets depends-external" do
      provides = @swift_file.depends_for_type(SwiftFile::EXTERNAL)
      expect(provides.map(&:value)).to eq(["/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator/x86_64/Swift.swiftmodule", "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator/x86_64/AssetsLibrary.swiftmodule"])
    end
  end

end

