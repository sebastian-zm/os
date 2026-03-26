FROM registry.redhat.io/rhel10/rhel-bootc:10

COPY usr/ /usr/

RUN dnf5 upgrade -y

RUN dnf5 install -y \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm \
  https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm \
  dnf5-plugins \
  && \
  dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/rhel/$(rpm -E %rhel)/tailscale.repo \
  && \
  dnf5 config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo \
  && \
  dnf5 install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

RUN dnf5 group install --with-optional -y \
  standard hardware-support base-graphical multimedia fonts domain-client printing

RUN dnf5 install -y \
  sway swaybg swayidle swaylock waybar foot \
  glibc-langpack-en firefox

RUN dnf5 install -y \
  nodejs ruby golang \
  java-21-openjdk java-21-openjdk-javadoc java-21-openjdk-src maven \
  rust cargo

RUN dnf5 install -y \
  tailscale \
  git gh \
  skopeo jq

RUN dnf5 install -y \
  v4l2loopback akmod-v4l2loopback \
  VirtualBox akmod-VirtualBox \
  obs-studio obs-studio-plugin-x264 \
  NetworkManager-openvpn

RUN dnf5 install -y neovim btop

RUN dnf5 install -y genisoimage

# Build kernel modules for the image kernel, then refresh modules.dep
RUN akmods --force --kernels $(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core) && \
    depmod -a $(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core)

RUN chmod +x /usr/bin/* /usr/bin/steamos-polkit-helpers/* \
  && \
  systemctl disable bootc-fetch-apply-updates.timer \
  && \
  systemctl enable psacct.service

# Clean up /var and lint the container
RUN bootc container lint --no-truncate


# Metadata labels
LABEL containers.bootc="1" \
      ostree.bootable="1"

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
