class Dario < Formula
  desc "Run every AI coding tool you own on your Claude and ChatGPT subscriptions"
  homepage "https://github.com/askalf/dario"
  url "https://registry.npmjs.org/@askalf/dario/-/dario-6.19.1.tgz"
  sha256 "5cca3bb3120a8b385e836518cb3a2b629a49d73216250422f73104c8fafface7"
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
