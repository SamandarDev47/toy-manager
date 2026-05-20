# Small stability fix

Qilingan o‘zgarishlar:

1. Dark/Light mode endi ilovadan chiqib qayta kirganda ham saqlanadi.
   - `shared_preferences` qo‘shildi.
   - `AppSettings.load()` `main()` ichida chaqirildi.

2. Chatda "Kimlar ko‘rgan?" endi token/uid ko‘rsatmaydi.
   - `users/{uid}` dan foydalanuvchi ismi olinadi.
   - Faqat xabar egasi o‘z xabari kimlar tomonidan ko‘rilganini ko‘ra oladi.
   - O‘zingiz ko‘rganingiz ro‘yxatda chiqmaydi.

3. Boshqa odam yozgan xabarida "Kimlar ko‘rgan?" menyusi chiqmaydi.

4. Xabar o‘chirilsa, "Xabar o‘chirildi" deb qolmaydi — Firebase’dan butunlay o‘chiriladi.
