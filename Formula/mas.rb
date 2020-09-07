class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.7.1",
      revision: "b8dcb4ce4b1d78ada7556565dd5c73e9913758d8"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    cellar :any
    sha256 "de5acfedda59b73fbd36e4a966120aa1aa7e5eea4c07c19e75c0b21819b0900d" => :catalina
    sha256 "de5acfedda59b73fbd36e4a966120aa1aa7e5eea4c07c19e75c0b21819b0900d" => :mojave
    sha256 "de5acfedda59b73fbd36e4a966120aa1aa7e5eea4c07c19e75c0b21819b0900d" => :high_sierra
    sha256 "de5acfedda59b73fbd36e4a966120aa1aa7e5eea4c07c19e75c0b21819b0900d" => :sierra
    sha256 "de5acfedda59b73fbd36e4a966120aa1aa7e5eea4c07c19e75c0b21819b0900d" => :el_capitan
  end

  depends_on "carthage" => :build
  depends_on xcode: ["10.2", :build]

  def install
    # Working around build issues in dependencies
    # - Prevent warnings from causing build failures
    # - Prevent linker errors by telling all lib builds to use max size install names
    # - Ensure dependencies build for the current CPU; otherwise Commandant will
    #   build for x86_64 when running arm64
    xcconfig = buildpath/"Overrides.xcconfig"
    xcconfig.write <<~EOS
      GCC_TREAT_WARNINGS_AS_ERRORS = NO
      OTHER_LDFLAGS = -headerpad_max_install_names
      VALID_ARCHS = #{Hardware::CPU.arch}
    EOS
    ENV["XCODE_XCCONFIG_FILE"] = xcconfig

    # Only build necessary dependencies
    system "carthage", "bootstrap", "--platform", "macOS", "Commandant"
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_include shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
