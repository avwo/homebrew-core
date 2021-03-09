class Automake < Formula
  desc "Tool for generating GNU Standards-compliant Makefiles"
  homepage "https://www.gnu.org/software/automake/"
  url "https://ftp.gnu.org/gnu/automake/automake-1.16.3.tar.xz"
  mirror "https://ftpmirror.gnu.org/automake/automake-1.16.3.tar.xz"
  sha256 "ff2bf7656c4d1c6fdda3b8bebb21f09153a736bcba169aaf65eab25fa113bf3a"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b989d3db71b5bc3456f52edd92b818d1fcb5c03e62ab5c6ffeb5bf404dc22aa5"
    sha256 cellar: :any_skip_relocation, big_sur:       "b19be0f4672d3ed2c258eee5f676d27429e5da189c80dc04ba8d01bc44ead320"
    sha256 cellar: :any_skip_relocation, catalina:      "25fe47e5fb1af734423e1e73f0dc53637e89d825ef8d8199add239352b5b974e"
    sha256 cellar: :any_skip_relocation, mojave:        "6e25193e573d0e11376322018c9cdf96ddd68ad7e4fe7bb464212380d5e6b9cf"
  end

  depends_on "autoconf"

  def install
    on_macos do
      ENV["PERL"] = "/usr/bin/perl"
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<~EOS
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      int main() { return 0; }
    EOS
    (testpath/"configure.ac").write <<~EOS
      AC_INIT(test, 1.0)
      AM_INIT_AUTOMAKE
      AC_PROG_CC
      AC_CONFIG_FILES(Makefile)
      AC_OUTPUT
    EOS
    (testpath/"Makefile.am").write <<~EOS
      bin_PROGRAMS = test
      test_SOURCES = test.c
    EOS
    system bin/"aclocal"
    system bin/"automake", "--add-missing", "--foreign"
    system "autoconf"
    system "./configure"
    system "make"
    system "./test"
  end
end
