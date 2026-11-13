class Dario < Formula
  desc "Run every AI coding tool you own on your Claude and ChatGPT subscriptions"
  homepage "https://github.com/askalf/dario"
  url "https://registry.npmjs.org/@askalf/dario/-/dario-6.23.12.tgz"
  sha256 "c5e9093b4d7e64b98bba25408999f1135f1c85cac4525a4f8b3633a0f8a96274"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dario --version")
    assert_match "dario proxy", shell_output("#{bin}/dario --help")
  end
end
