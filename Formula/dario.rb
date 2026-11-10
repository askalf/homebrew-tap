class Dario < Formula
  desc "Run every AI coding tool you own on your Claude and ChatGPT subscriptions"
  homepage "https://github.com/askalf/dario"
  url "https://registry.npmjs.org/@askalf/dario/-/dario-6.23.6.tgz"
  sha256 "0eeeef36a1610bbe387c097c768050c1f1c45874afd28b327ab3b5e7dfc57544"
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
