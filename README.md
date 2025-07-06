# Terraform ile Base Debian VM Oluşturma

Bu repo Terraform ile Libvirt kullanarak temel bir Debian 12 sanal makinesi (VM) oluşturmak için gerekli yapılandırma dosyalarını içerir. Sanal makine, cloud-init aracılığıyla otomatik olarak yapılandırılır. Hostname ayarlanır, root kullanıcısı için SSH anahtarı eklenir ve temel paketler kurulur. Root kullanıcısı için parola ile giriş devre dışı bırakılmıştır, yalnızca SSH anahtarı ile erişim mümkündür.

## Gereksinimler

- Terraform: Sisteminizde Terraform kurulu olmalıdır.

- Libvirt: Ana makinenizde Libvirt kurulu ve çalışır durumda olmalıdır (genellikle qemu-kvm, libvirt-daemon, libvirt-clients paketleri).

- İnternet Erişimi: Sanal makinenin internete erişimi olmalıdır (paketleri indirmek için). Libvirt'in varsayılan ağı (default network) genellikle DHCP ve NAT ile internet erişimi sağlar.

## Kullanım

1.  **Repoyu Klonlayın:**
    ```bash
    git clone https://github.com/berkbal/terraform-libvirt-base-debian
    cd terraform-libvirt-debian-base-vm
    ```

2.  **`files/cloud-init.yml` Dosyasını Düzenleyin:**
    `files/cloud-init.yml` dosyasını açın ve `SSH-PUBLIC-KEY` yerini kendi SSH ortak anahtarınızla (`~/.ssh/id_ed25519.pub` veya `~/.ssh/id_rsa.pub` dosyanızın içeriği) değiştirin.

    ```yaml
    # files/cloud-init.yml
    # ...
    users:
      - name: root
        ssh-authorized-keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPs/hWAelf2ahoRid1xEPs75fecE/bci0Lt3RI6Feqpk berk@berk # Kendi public key'iniz buraya gelecek
        lock_passwd: true
        shell: /bin/bash
    # ...
    ```

3.  **Terraform'u Başlatın:**
    Terraform sağlayıcılarını indirmek için:
    ```bash
    terraform init
    ```

4.  **Planı Gözden Geçirin:**
    Terraform'un ne gibi değişiklikler yapacağını görmek için:
    ```bash
    terraform plan
    ```

5.  **Altyapıyı Uygulayın:**
    Sanal makineyi oluşturmak için:
    ```bash
    terraform apply --auto-approve
    ```
    (Production ortaminda `--auto-approve` kullanmadan önce `plan` çıktısını dikkatlice incelemeniz önerilir.)
