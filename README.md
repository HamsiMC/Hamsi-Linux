# Hamsi Linux

Hamsi Linux, başka bir dağıtımın ISO'sunu değiştirerek üretilen bir türev
değildir. Linux çekirdeğini kullanan; kullanıcı alanını, paket seçimini,
masaüstü politikasını, markalamasını, canlı ortamını ve kurulum akışını
OpenEmbedded/Yocto ile sıfırdan oluşturan bağımsız bir dağıtım projesidir.

## Tasarım hedefi

- x86-64 bilgisayarlarda UEFI açılış
- USB'den canlı kullanım ve güvenli grafik kurulum
- KDE Plasma 6 / Wayland, alt görev çubuğu ve özgün Hamsi görünümü
- systemd, PipeWire, NetworkManager, BlueZ, CUPS ve Flatpak
- Hamsi Mağaza (Plasma Discover + Flathub)
- Yandex Browser ve Blender dahil masaüstü uygulamaları
- geliştirme, ofis, medya, uzaktan erişim ve disk yönetimi araçları
- SPDX 3.0 yazılım malzeme listesi ve yeniden üretilebilir sürüm bilgisi
- ISO için kesin 12 GiB üst sınırı; sahte dolgu dosyası yok

Hedeflenen ilk sürüm `0.1.0 Karadeniz`'dir. Plasma, Qt ve OpenEmbedded
katmanları kayan dal adlarına değil sabit commit kimliklerine bağlıdır.

## Hızlı başlangıç

Derleme ana bilgisayarı Linux, en az 16 işlemci iş parçacığı, 32 GiB RAM ve
250 GiB boş SSD alanına sahip olmalıdır. `kas`, Yocto'nun ana bilgisayar
bağımlılıkları ve internet erişimi gerekir.

```bash
./scripts/check-runner.sh
./scripts/build.sh
```

Başarılı derlemenin çıktıları `dist/` altında oluşur:

- `hamsi-linux-0.1.0-x86_64.iso` — canlı ve kurulabilir ISO
- `hamsi-linux-0.1.0-x86_64.iso.sha256` — bütünlük özeti
- `hamsi-linux-0.1.0-x86_64.iso.parts/` — GitHub'a yükleme için parçalar
- SPDX ve build-info dosyaları

Kaynak doğrulaması tam Yocto derlemesi gerektirmez:

```bash
python3 scripts/validate-repo.py
```

## Donanım ve oturum

Canlı kullanıcı `hamsi` olarak otomatik açılır. Kurulum programı hedef diski,
kullanıcı adını ve parolayı sorar; kurulu sistemde otomatik oturum ve
parolasız yönetici yetkisi kaldırılır. Kurulum aracı yalnızca UEFI/GPT hedefler
ve seçilen diskin tüm içeriğini silmeden önce ikinci, yazılı onay ister.

## Üçüncü taraf yazılımlar

Blender resmi Blender Foundation arşivinden, Yandex Browser ise resmi Yandex
RPM deposundan derleme sırasında indirilir ve SHA-256 ile doğrulanır. Kaynak
deposu bu ikili dosyaları barındırmaz. Yandex paketi `CLOSED` olarak işaretlidir;
genel dağıtım yapmadan önce sağlayıcının güncel lisans ve yeniden dağıtım
koşullarını doğrulayın. Yandex'siz derleme için:

```bash
HAMSI_INCLUDE_YANDEX=0 ./scripts/build.sh
```

## Depo düzeni

- `kas/`: sabitlenmiş üst katmanlar ve tek komutluk derleme tanımı
- `meta-hamsi/`: dağıtım, görüntü, uygulama ve marka tarifleri
- `scripts/`: derleme, ISO doğrulama ve parçalara ayırma araçları
- `docs/`: mimari, paket kapsamı, derleyici ve lisans notları
- `.github/workflows/`: hızlı kaynak denetimi ve öz-barındırılan ISO derlemesi

Bu depo ISO'nun kaynağıdır. ISO yalnızca başarılı tam derleme ve önyükleme
kontrollerinden sonra sürüm varlığı olarak yayımlanır.
