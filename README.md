# Swift Weather App

Bu Swift Weather uygulaması, SwiftUI kullanılarak geliştirilmiş bir hava durumu uygulamasıdır. Hava durumu verilerini almak için bir API kullanılmıştır ve kullanıcıya hava durumu tahminlerini gösterir.

## Özellikler

- Kullanıcıya anlık hava durumu bilgilerini gösterme
- Kullanıcı konumuna bağlı olarak hava durumu verilerini otomatik olarak güncelleme
- Kullanıcı dostu arayüz ile kolay kullanım
- Akıllı Plan ekranı ile şemsiye, kıyafet, dışarı çıkmak için en iyi saat ve saatlik plan önerileri
- Yağmur, rüzgar ve UV risk kartları
- Kısa süreli cache ile ağ hatalarında son başarılı hava planını gösterme

## Kullanılan Teknolojiler

- SwiftUI
- RESTful API
- Core Location
- KeychainAccess

## Kurulum

1. Bu depoyu klonlayın veya ZIP dosyası olarak indirin.
2. Xcode'u açın ve `WeatherApp.xcodeproj` dosyasını açarak projeyi çalıştırın. Swift Package Manager bağımlılıkları otomatik olarak çözülecektir.
3. [OpenWeatherMap](https://openweathermap.org/) üzerinden bir API key alın. Ücretsiz kullanım uygulamayı geliştirmek ve test etmek için yeterlidir.
4. Uygulama ilk açıldığında API key ekranı görünür. OpenWeatherMap API key'inizi bu ekrandaki alana girip **Kaydet** butonuna basın.

## API Key Yönetimi

API key uygulama içinde `KeychainAccess` paketi ile iOS/macOS Keychain'e kaydedilir. Bu yüzden API key'i `UserDefaults`, kaynak kod, `Info.plist` veya repoya commit edilen bir `Keys.plist` içinde saklamayın.

Önerilen kullanım:

1. Uygulamayı çalıştırın.
2. İlk açılışta gelen **API Key** ekranına OpenWeatherMap API key'inizi girin.
3. **Kaydet** butonuna basın.
4. API key Keychain'e kaydedildikten sonra uygulama normal hava durumu ekranlarını açar.

API key'i değiştirmek veya silmek için uygulamadaki **API Key** sekmesini kullanabilirsiniz. Kayıtlı anahtar silinirse uygulama tekrar API key giriş ekranına döner.

Geliştirme sırasında eski `Keys.plist` dosyası kullanılmışsa uygulama bunu ilk çalıştırmada Keychain'e taşımayı dener. Yeni geliştirmelerde tercih edilen yöntem uygulama içindeki API Key ekranıdır.

> Not: Keychain cihaz üzerinde güvenli saklama sağlar, ancak client uygulama ile dağıtılan sabit API key tamamen gizlenemez. Üretim ortamında daha güçlü güvenlik gerekiyorsa API key'i bir backend/proxy servisinde tutup uygulamanın doğrudan OpenWeatherMap anahtarını bilmemesi tercih edilmelidir.

## Kullanım

Uygulamayı çalıştırdıktan sonra, cihazınızın konum izinlerini vererek veya şehir adı girerek hava planı önerilerini alabilirsiniz.

**Plan** sekmesinde şehir adı yazabilir veya konum izni vererek günlük önerileri görebilirsiniz. Bu ekran yağış ihtimali, rüzgar, UV ve hissedilen sıcaklığı birlikte değerlendirerek pratik karar kartları üretir.

## Test

```bash
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Katkıda Bulunma

Her türlü katkı ve geri bildirimleriniz memnuniyetle karşılanmaktadır. Eğer katkıda bulunmak isterseniz, lütfen bir pull request oluşturun. Lütfen önce sorunlar(issues) bölümünde bir konu açın.
![issues](<[text](https://github.com/developersailor/WeatherApp/issues/new)>)

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakınız.
