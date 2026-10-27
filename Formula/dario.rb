class Dario < Formula
  desc "Run every AI coding tool you own on your Claude and ChatGPT subscriptions"
  homepage "https://github.com/askalf/dario"
  url "https://registry.npmjs.org/@askalf/dario/-/dario-6.17.2.tgz"
  sha256 "7d2cd083324ce7822afb217cf4bd2d1b757c378fee13d77ced737705d553dcfa"
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
