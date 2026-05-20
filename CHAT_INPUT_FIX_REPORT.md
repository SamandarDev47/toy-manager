# Chat input position fix

Chat sahifasida xabar yozish maydoni tepaga chiqib ketgani tuzatildi.

## O'zgargan fayl
- `lib/pages/chat/chat_page.dart`

## Tuzatishlar
- Pastki padding `96` dan `22` ga tushirildi.
- Xabar yozish maydoni zamonaviy oq container ichiga olindi.
- Send tugmasi ixcham circle button qilindi.
- Keyboard ochilganda sahifa moslashishi uchun `resizeToAvoidBottomInset: true` qo'shildi.
- Input endi bottom navigationdan haddan tashqari tepada turmaydi.
