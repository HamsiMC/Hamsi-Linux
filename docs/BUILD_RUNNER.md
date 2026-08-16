# ISO derleyicisi

Tam Plasma/Qt/Chromium sınıfı Yocto derlemesi sıradan GitHub barındırılan
işleyicisinin disk ve süre sınırlarına uygun değildir. `build-iso.yml` bu
nedenle `self-hosted, linux, x64, hamsi-builder` etiketli bir işleyici ister.

## Önerilen kaynaklar

- Ubuntu 24.04 LTS veya Yocto'nun desteklediği eşdeğer Linux
- 16+ CPU iş parçacığı
- 32 GiB RAM (64 GiB önerilir)
- 250 GiB boş NVMe (400 GiB önerilir)
- Docker gerekmez; KVM/OVMF duman testi için önerilir

Ana bilgisayarda Yocto belgelerinde listelenen paketler, Python 3 ve `kas`
bulunmalıdır. Örnek kas kurulumu:

```bash
python3 -m pip install --user 'kas==5.4'
```

İşleyiciyi GitHub deposuna bağladıktan sonra etiketlerine `hamsi-builder`
ekleyin. Derleme iş akışı önce kaynak doğrulamasını ve kapasite kontrolünü
yapar; yetersiz disk/RAM ile pahalı derlemeyi başlatmaz.

## Önbellek

`.work/kas/downloads` ile `.work/kas/sstate-cache` korunursa sonraki derlemeler
önemli ölçüde hızlanır. `tmp` klasörünü sürümler arasında paylaşmak zorunlu
değildir. Hiçbir önbellek dosyası Git'e eklenmez.

## Çıktı paylaşımı

Tek GitHub Release varlığının boyut sınırına takılmamak için ISO 1900 MiB'lık
parçalara ayrılır. Her parça ve birleşmiş ISO için SHA-256 üretilir. Gerçek ISO
ayrıca `dist/` altında kalır ve istenirse Google Drive'a yüklenebilir.
