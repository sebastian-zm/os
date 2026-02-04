FROM quay.io/fedora/fedora-minimal:43 AS build-clipboard-sync

WORKDIR /src
RUN dnf install -y git rpm-build rpmdevtools libxcb-devel systemd-rpm-macros rust cargo
RUN git clone --depth 1 https://github.com/sebastian-zm/clipboard-sync.git .
RUN make rpm

FROM quay.io/fedora/fedora-bootc:43

RUN dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  fedora-workstation-repositories \
  dnf5-plugins \
  && \
  dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
  && \
  dnf5 config-manager addrepo --from-repofile=https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo \
  && \
  dnf5 config-manager setopt google-chrome.enabled=1

RUN dnf5 install -y packages-microsoft-prod

RUN dnf5 install -y \
  @swaywm @swaywm-extended cage glibc-langpack-en \
  @standard @base-graphical @hardware-support @multimedia @fonts @domain-client @printing \
  @firefox google-chrome-stable

RUN dnf5 install -y \
  nodejs ruby golang uv nix \
  java-25-openjdk maven \
  rust cargo

RUN dnf5 install -y \
  steam gamescope mangohud \
  cascadia-code-nf-fonts cascadia-mono-nf-fonts \
  tailscale \
  git gh \
  skopeo jq

RUN dnf5 install -y \
  v4l2loopback akmod-v4l2loopback \
  VirtualBox akmod-VirtualBox \
  obs-studio obs-studio-plugin-x264 obs-studio-plugin-vkcapture \
  @networkmanager-submodules NetworkManager-openvpn

RUN dnf5 install -y neovim

# Build for the kernel that’s in the image, then refresh modules.dep
RUN akmods --force --kernels $(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core) && \
    depmod -a $(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core)

# DNIe
# --nodeps because pinentry-gtk2 doesn't exist.
RUN rpm -Uvh --nodeps \
  https://www.dnielectronico.es/descargas/distribuciones_linux/libpkcs11-dnie-1.6.8-1.x86_64.rpm && \
  echo "module: /usr/lib64/libpkcs11-dnie.so" > /usr/share/p11-kit/modules/dnie.module && \
  ln -sf /usr/share/libpkcs11-dnie/AC\ RAIZ\ DNIE\ 2.crt /usr/share/pki/ca-trust-source/anchors/AC\ RAIZ\ DNIE\ 2.crt

COPY --from=build-clipboard-sync /root/rpmbuild/RPMS/*/clipboard-sync-*.rpm /tmp/
RUN dnf5 install -y /tmp/clipboard-sync-*.rpm \
    && \
    rm -f /tmp/clipboard-sync-*.rpm

COPY usr/ /usr/

RUN chmod +x /usr/bin/* /usr/bin/steamos-polkit-helpers/* \
  && \
  systemctl disable bootc-fetch-apply-updates.timer \
  && \
  systemctl enable ostree-state-overlay@nix.service \
  && \
  systemctl enable psacct.service

# Clean up /var and lint the container
RUN dnf5 clean all && \
   find /var/log -type f -delete && \
   find /var/cache/libdnf5 -type d -exec rm -rf {} + && \
   find /var/lib/dnf/repos -type d -exec rm -rf {} + && \
   rm -rf /var/lib/systemd/catalog/database \
     /var/lib/authselect/checksum \
     /var/cache/ldconfig/aux-cache \
     /var/cache/akmods && \
   find /var/cache -type f -delete && \
   bootc container lint --no-truncate --fatal-warnings


# Metadata labels
LABEL containers.bootc="1" \
      ostree.bootable="1"

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
