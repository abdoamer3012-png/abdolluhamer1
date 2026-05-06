# متطلبات النشر

قبل نشر منصة عامر بالمعرفة اضبط المتغيرات التالية في بيئة الاستضافة:

- `DATABASE_URL`: رابط قاعدة بيانات Postgres الحقيقي.
- أو بدلا منه `SUPABASE_URL` و `SUPABASE_SERVICE_ROLE_KEY` لاستخدام Supabase REST من الخادم.
- `NEXT_PUBLIC_SUPABASE_URL`: رابط مشروع Supabase، ويستخدم أيضا لتفعيل تحقق البريد عبر Supabase Auth.
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`: مفتاح Supabase publishable/anon لإرسال رابط تحقق البريد.
- `RESEND_API_KEY`: اختياري. إذا وُجد سيتم إرسال كود تحقق رقمي بدلا من رابط Supabase.
- `EMAIL_FROM`: اختياري مع Resend فقط.
- `GROQ_API_KEY`: مفتاح Groq للمساعد الذكي.
- `GROQ_MODEL`: موديل Groq المستخدم، والقيمة الافتراضية `llama-3.1-8b-instant`.

## تحقق البريد

النظام يعمل بطريقتين:

1. إذا كان `RESEND_API_KEY` موجودا: يرسل كود تحقق رقمي إلى البريد.
2. إذا لم يكن Resend موجودا: يستخدم Supabase Auth ويرسل رابط تحقق حقيقي إلى البريد.
3. إذا لم توجد أي خدمة بريد: يتم إنشاء الحساب في انتظار موافقة المدير، ويقوم المدير بتفعيله من لوحة الإدارة.

لتفعيل Supabase Auth:

- افتح Supabase Dashboard.
- ادخل إلى `Authentication` ثم `Providers`.
- فعظ‘ل `Email`.
- فعظ‘ل خيار تأكيد البريد `Confirm email`.
- من `Authentication` ثم `URL Configuration` ضع رابط الموقع بعد النشر في `Site URL`.

## قاعدة البيانات

بعد إنشاء مشروع Supabase، شغظ‘ل ملف `supabase-production.sql` من SQL Editor داخل Supabase. الملف ينشئ الجداول وينظف البيانات بحيث لا يوجد إلا المدير الأساسي.

وضع الإنتاج لا يعمل بدون `DATABASE_URL` أو `SUPABASE_SERVICE_ROLE_KEY`.

## ملاحظات مهمة

- لا يتم إرجاع كود التحقق إلى المتصفح.
- `SUPABASE_SERVICE_ROLE_KEY` سري جدا، لا تضعه في الواجهة أو في أي ملف عام.
- المساعد الذكي لا يعمل بدون `GROQ_API_KEY`.


