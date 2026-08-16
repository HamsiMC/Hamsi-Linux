# Sürüm doğrulama kapıları

Bir Hamsi ISO'su aşağıdaki kapıların tümünü geçmeden yayımlanmaz:

1. `validate-repo.py`: katman pinleri, tarif özetleri, betik sözdizimi ve büyük
   ikili dosya denetimi.
2. BitBake parse ve tam `hamsi-desktop-image` derlemesi.
3. ISO boyutu 1–12 GiB, ISO9660 imzası ve UEFI El Torito girişi.
4. QEMU + OVMF ile en az 75 saniyelik UEFI önyükleme duman testi.
5. SHA-256, kaynak manifesti, build-info ve SPDX 3.0 üretimi.
6. Gerçek donanımda Wi-Fi, Bluetooth, ses, askıya alma, yazdırma, canlı oturum
   ve boş diske kurulum kabul testi.

Otomasyon ilk beş kapıyı uygular. Altıncı kapı fiziksel cihaz matrisi
gerektirdiğinden sürüm notuna test edilen modeller açıkça yazılmalıdır.
