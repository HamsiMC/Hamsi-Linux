# Uygulama kapsamı

ISO boyutu uygulama ve kütüphanelerin gerçek içeriğinden oluşur; dolgu dosyası
üretilmez. Aşağıdaki çekirdek seçki görüntüye doğrudan dahildir.

| Alan | Dahil edilenler |
|---|---|
| Web | Yandex Browser (varsayılan), Angelfish (açık kaynak yedek) |
| 3B ve üretim | Blender 5.2.0 |
| Dosya ve terminal | Dolphin, Konsole, File Roller, rsync |
| Belge ve görüntü | Okular, Gwenview, GNOME Text Editor |
| Ses ve video | PipeWire, WirePlumber, VLC, Elisa, Dragon |
| Ağ | NetworkManager, Wi-Fi, Bluetooth, WireGuard, KDE Connect, Avahi |
| Uzak çalışma | Remmina, FreeRDP 3, OpenSSH |
| Disk ve donanım | GParted, UDisks2, fwupd, SMART, LVM, mdadm, LUKS araçları |
| Yazdırma | CUPS, filtreler ve Gutenprint |
| Geliştirme | GCC/G++, Git, Python 3/pip, CMake, Ninja ve temel SDK araçları |
| Mağaza | Hamsi Mağaza, Plasma Discover, Flatpak ve Flathub |

LibreOffice, Krita, Kdenlive, OBS Studio, Thunderbird ve benzeri büyük
uygulamalar Hamsi Mağaza'dan kurulabilir. Bunları ISO'ya ikinci kez gömmemek,
ilk görüntüyü 12 GiB sınırında tutar ve uygulamaların bağımsız güvenlik
güncellemelerini almasını sağlar.

## Yandex seçeneği

Varsayılan derleme resmi Yandex RPM'sini indirir. Lisans koşulları nedeniyle
genel yeniden dağıtım yapacak kişiler `HAMSI_INCLUDE_YANDEX=0` seçeneğini
kullanabilir. Bu durumda Angelfish çalışır durumda kalır ve Yandex daha sonra
sağlayıcının resmi kanalından kurulabilir.
