# Timewatch
Redmine üzerinde harcanan zaman kayıtlarını temel alarak, e-posta yolu ile bilgi verip, iş kayıtlarının otomatik güncellenmesini sağlar.
Redmine v3 uyumludur.

## Özellikleri
1. Özel Zaman Eşiği: Bir iş kaydına girilen toplam harcanan zaman; eklenti ayarlarında belirtilen zaman aralığı değerinin (Örn: 10 saat) yine eklenti ayarlarında belirtilen oranını (Örn: %80) geçtiği zaman iş kaydına yeni bir girdi ekler.
2. Tahmini Zaman Eşiği: Bir projeye eklenen 'ondalık sayı' tipindeki özel alanına girilen toplam değer; eklenti ayarlarında belirtilen oranını (Örn: %80) geçtiği zaman iş kaydına yeni bir girdi ekler.
3. İş kaydına eklenecek girdi özelleştirilebilir.
4. Eklenti ayarları her projede farklı ayarlanabilir.

## Ayarlar
* Eklenti için ön tanımlı ayar kaydedilebileceği gibi, her proje için ayrı ayar da oluşturulabilir. Eklenti ayarlarına yönetici hesabı ile /administration/plugins/redmine_timewatch_plugin configure adresinden ulaşılabilir.
* Eklentinin hangi özelliği kullanılacaksa o özellik etkinleştirilmelidir. 2 ayrı özellik ayrı ayrı etkin/pasif edilebilir.
* Notification time base interval in hours: Yüzdesi alınacak zaman aralığı değeridir.
* Warning ratio (%): Uyarı zaman aralığının alınacak yüzdesidir.

**Örnek:**

Notification time base interval in hours: 10
Warning ratio (%): 80

Sistem bu ayarlarla her 10 saatlik periyotlarda, +8 saat geçince iş kaydına -ayarlarda belirtilen- mesajı gönderecektir.
İş kaydına girilen zaman değeri örn. 7 saat ise bir tepki vermeyecektir. 8 saat olunca uyarı mesajını gönderecektir. Harcanan zaman değeri 8 ve 10 arasında iken bir uyarı girmeyecektir. Çünkü daha önce 8. saatte uyarı yollandığı için, 9. saatte uyarı gönderilmeyip 18. saatte uyarı gönderilecektir.

* Email konusu (Email subject): Uyarının gönderileceği epostanın konusudur.
* Email alıcıları (Email recipients): Uyarı epostasının gönderileceği adresler girilir. Çoklu adresler virgül ile ayrılır. (ornek@ornek.com,ornek2@ornek.com)
* Email şablonu: (Email template): Gönderilecek epostanın içeriğidir. Bu içerikte Redmine iş numarasını göstermek için ISSUE_NUMBER ve eşik zaman değeri için ISSUE_SPENT_TIME / ISSUE_CUSTOM_ESTIMATED_TIME anahtar kelimeleri kullanılmalıdır.
* Tahmini süre için özel alan (Custom field for estimated time): Eklentinin dikkate alacağı özel alan (custom field) seçilir. Bunun için ilgili projeye 'ondalık sayı' tipinde bir özel alan eklenmiş olmalıdır.
