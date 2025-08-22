FROM quay.io/fedora/fedora-bootc:42

RUN dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  fedora-workstation-repositories \
  dnf5-plugins \
  && \
  dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
  && \
  dnf5 config-manager setopt google-chrome.enabled=1 \
  && \
  dnf5 install -y \
  @swaywm-extended \
  @standard @base-graphical @hardware-support @multimedia @fonts @domain-client @printing \
  cascadia-code-nf-fonts cascadia-mono-nf-fonts \
  steam gamescope mangohud \
  git gh \
  tailscale \
  firefox google-chrome-stable \
  obs-studio obs-studio-plugin-x264 \
  NetworkManager-openvpn \
  skopeo jq \
  && \
  dnf5 clean all && \
  systemctl set-default graphical.target

# DNIe
# --nodeps because pinentry-gtk2 doesn't exist.
RUN rpm -Uvh --nodeps \
  https://www.dnielectronico.es/descargas/distribuciones_linux/libpkcs11-dnie-1.6.8-1.x86_64.rpm && \
  echo "module: /usr/lib64/libpkcs11-dnie.so" > /usr/share/p11-kit/modules/dnie.module && \
  ln -sf /usr/share/libpkcs11-dnie/AC\ RAIZ\ DNIE\ 2.crt /usr/share/pki/ca-trust-source/anchors/AC\ RAIZ\ DNIE\ 2.crt

COPY usr/ /usr/

RUN chmod +x /usr/bin/steam-session /usr/bin/steamos-session-select /usr/bin/jupiter-biosupdate /usr/bin/steamos-select-branch \
    && \
    systemctl disable bootc-fetch-apply-updates.timer


# Allow nix installer, for user configuration with home-manager, which cannot work without a /nix directory
RUN mkdir -p /nix

# Lint the container
RUN find /var/log -type f ! -empty -delete && bootc container lint

# Metadata labels
LABEL containers.bootc="1" \
      ostree.bootable="1"

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
