class Stash < Formula
  desc "Bidirectionally sync Markdown files with Apple Notes"
  homepage "https://github.com/shakedlokits/stash"
  url "https://github.com/shakedlokits/stash/releases/download/v0.1.0/stash"
  sha256 "PLACEHOLDER"
  license "GPL-3.0-or-later"

  depends_on "pandoc"
  depends_on "pcre"
  depends_on :macos

  def install
    bin.install "stash"
  end

  test do
    assert_match "stash", shell_output("#{bin}/stash --help")
  end
end
