class Swtpm < Formula
  desc "Software TPM Emulator based on libtpms"
  homepage "https://github.com/stefanberger/swtpm"
  url "https://github.com/stefanberger/swtpm/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "ad433f9272fb794aafd550914d24cc0ca33d4652cfd087fa41b911fa9e54be3d"
  license "BSD-3-Clause"

  bottle do
    sha256 arm64_ventura:  "9215c7720ece452ecbe25f2954c63d6d616b04abdafaea2b718b24541a4cb8e1"
    sha256 arm64_monterey: "e64ec8dfc81f9199988ced1cf856376ee943c08960339c37e5e07204c53a745f"
    sha256 arm64_big_sur:  "db386f2737ef9305ce649a1cc776511ee84ca80094f91c07b8587f31a007195b"
    sha256 monterey:       "a706d9534f003e7fbf8d3cd42594e51f3d15e65f0ee05b8d187f6342eff68a0a"
    sha256 big_sur:        "f178191eb052c516e200709635508e8b707af00ff1d787d4260d2926f12ef6cb"
    sha256 catalina:       "a2e95c5c912c5e86a0552b69a496a8b611f54a18b989e61055ae161113284068"
    sha256 x86_64_linux:   "e49ae25d839661e0add9e92edb2165f4764b2ccf5c67e88316c9765c3ff8f252"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gawk" => :build
  depends_on "libtool" => :build
  depends_on "socat" => :build
  depends_on "gnutls"
  depends_on "json-glib"
  depends_on "libtasn1"
  depends_on "libtpms"
  depends_on "openssl@3"

  uses_from_macos "expect"

  on_linux do
    depends_on "libseccomp"
    depends_on "net-tools"
  end

  def install
    ENV.append "LDFLAGS", "-L#{Formula["openssl@3"].opt_lib}" if OS.linux?

    system "./autogen.sh", *std_configure_args, "--with-openssl"
    system "make"
    system "make", "install"
  end

  test do
    port = free_port
    pid = fork do
      system bin/"swtpm", "socket", "--ctrl", "type=tcp,port=#{port}"
    end
    sleep 2
    system bin/"swtpm_ioctl", "--tcp", "127.0.0.1:#{port}", "-s"
  ensure
    Process.wait pid
  end
end
