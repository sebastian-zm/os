FROM quay.io/fedora/fedora-kinoite:42

# RPM Fusion
RUN dnf5 install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  && \
  dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
  && \
  dnf5 install -y \
  @multimedia \
  steam gamescope mangohud \
  tailscale \
  firefox \
  google-chrome-stable \
  https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm \
  && \
  dnf5 clean all

# DNIe
# --nodeps because pinentry-gtk2 doesn't exist.
RUN rpm -Uvh --nodeps \
  https://www.dnielectronico.es/descargas/distribuciones_linux/libpkcs11-dnie-1.6.8-1.x86_64.rpm && \
  echo "module: /usr/lib64/libpkcs11-dnie.so" > /usr/share/p11-kit/modules/dnie.module && \
  ln -sf /usr/share/libpkcs11-dnie/AC\ RAIZ\ DNIE\ 2.crt /usr/share/pki/ca-trust-source/anchors/AC\ RAIZ\ DNIE\ 2.crt && \
  update-ca-trust
  
COPY steam.desktop /usr/share/wayland-sessions/
COPY steam-session steamos-session-select /usr/bin/
RUN chmod +x /usr/bin/steam-session /usr/bin/steamos-session-select

# Allow nix installer, for user configuration with home-manager, which cannot work without a /nix directory
RUN mkdir -p /nix

# Lint the container
RUN bootc container lint

# Metadata labels
LABEL containers.bootc="1" \
      ostree.bootable="1"

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
