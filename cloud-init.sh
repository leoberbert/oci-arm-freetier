#!/bin/bash

# Atualizando o sistema
apt-get update
apt-get upgrade -y

# Instalando pacotes essenciais
apt-get install -y htop vim git curl wget unzip btrfs-progs net-tools iotop

# Removendo pacotes indesejados
apt-get remove -y snapd

# Limpando cache de pacotes
apt-get clean
apt-get autoremove -y

# Otimizando sysctl para melhor desempenho de rede
cat > /etc/sysctl.d/99-tunning.conf << 'EOL'
fs.file-max = 2097152
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.msgmax = 65536
kernel.msgmnb = 65536
kernel.panic = 3
kernel.printk = 4 4 1 7
kernel.sysrq = 0
net.core.default_qdisc = fq_codel
net.core.somaxconn = 65535
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_default_ttl = 77
net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ip_no_pmtu_disc = 1
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_fack = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mtu_probing = 1
net.netfilter.nf_conntrack_acct = 1
net.netfilter.nf_conntrack_checksum = 1
net.netfilter.nf_conntrack_timestamp = 1
net.netfilter.nf_conntrack_tcp_loose = 0
net.netfilter.nf_conntrack_buckets = 16384
net.netfilter.nf_conntrack_expect_max = 64
net.netfilter.nf_conntrack_max = 200000
net.netfilter.nf_conntrack_tcp_timeout_established = 1800
net.netfilter.nf_conntrack_tcp_timeout_close = 10
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 10
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 10
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 10
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 10
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 5
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 5
net.netfilter.nf_conntrack_udp_timeout = 10
net.netfilter.nf_conntrack_udp_timeout_stream = 180
vm.dirty_background_ratio = 5
vm.dirty_ratio = 15
vm.vfs_cache_pressure = 50
vm.swappiness = 10
EOL

# Aplicar as configurações sysctl
sysctl -p /etc/sysctl.d/99-tunning.conf

# Otimizando Systemd - aplicar mask no journald
systemctl mask systemd-journald
systemctl mask systemd-journald.socket
systemctl stop systemd-journald

# Aplicando mask no rsyslog
systemctl mask syslog.socket
systemctl mask rsyslog
systemctl stop rsyslog

# Recarregando daemon do systemd
systemctl daemon-reload

# Verificando se o BBR está ativo
sysctl net.ipv4.tcp_congestion_control
