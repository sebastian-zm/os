FROM quay.io/fedora/fedora-kinoite:42

RUN dnf upgrade -y

# RPM Fusion
RUN dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
RUN dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY vscode.repo /etc/yum.repos.d/

RUN dnf install -y \
  https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm

RUN dnf install -y \
  # akmod-nvidia \
  @multimedia @development-tools \
  code virtualbox \
  steam gamescope mangohud \
  vim fzf bat \
  tailscale librewolf \
  proton-vpn-gnome-desktop

RUN dnf install -y --allowerasing vim-default-editor

# Packet Tracer
COPY Cisco*Packet*.deb Packet*Tracer*.deb /home/
RUN curl -sSL https://raw.githubusercontent.com/thiagoojack/packettracer-fedora/refs/heads/main/setup.sh | sh

# Proton
RUN dnf install -y \
  https://proton.me/download/mail/linux/ProtonMail-desktop-beta.rpm \
  https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm

# DNIe
RUN rpm -Uvh --nodeps \
  https://www.dnielectronico.es/descargas/distribuciones_linux/libpkcs11-dnie-1.6.8-1.x86_64.rpm
RUN echo "module: /usr/lib64/libpkcs11-dnie.so" > /usr/share/p11-kit/modules/dnie.module
RUN ln -sf /usr/share/libpkcs11-dnie/AC\ RAIZ\ DNIE\ 2.crt /usr/share/pki/ca-trust-source/anchors/AC\ RAIZ\ DNIE\ 2.crt
RUN update-ca-trust
  
COPY steam.desktop /usr/share/wayland-sessions/
COPY steam-session steamos-session-select /usr/bin/
RUN chmod +x /usr/bin/steam-session /usr/bin/steamos-session-select

COPY os.build /usr/share/containers/systemd/

COPY * .* /usr/share/os/

# Upgrade again in case we are using podman cache from another build
RUN dnf upgrade -y

# Lint the container
RUN bootc container lint

# Define required labels for this bootc image to be recognized as such.
LABEL containers.bootc 1
LABEL ostree.bootable 1

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
