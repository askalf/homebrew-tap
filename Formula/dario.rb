class Dario < Formula
  desc "Run every AI coding tool you own on your Claude and ChatGPT subscriptions"
  homepage "https://github.com/askalf/dario"
  url "https://registry.npmjs.org/@askalf/dario/-/dario-6.19.0.tgz"
  sha256 "678913d66947b137f4d8f00cc2cac2c446d243864d9f996776e701f88c7cc700"
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
