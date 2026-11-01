class Factory < Formula
  desc "KaaS Factory command line"
  homepage "https://kaas.team"
  version "6.2.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/KaaS-team/KaaS-factory/releases/download/v6.2.0/factory-darwin-arm64"
      sha256 "8e81b71a36c8d032ad843c3caf5712ac3cf59c9b05e21165ad6c4378f5823057"
    end
    on_intel do
      url "https://github.com/KaaS-team/KaaS-factory/releases/download/v6.2.0/factory-darwin-x64"
      sha256 "88693446d50847567c4fa9a93b84b455c8f578bd80f5d383ae5ab3f61972f919"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/KaaS-team/KaaS-factory/releases/download/v6.2.0/factory-linux-arm64"
      sha256 "00651e02b31fd255fe29c1d39c42980da4a7bbe1df65bb80eacdf1458d3a2bce"
    end
    on_intel do
      url "https://github.com/KaaS-team/KaaS-factory/releases/download/v6.2.0/factory-linux-x64"
      sha256 "6de887fdbfe3dfc9b478f653b1b097190153472a12ee9c39a816da24abad19b7"
    end
  end

  def install
    bin.install Dir["factory-*"].first => "factory"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/factory --version")
  end
end
