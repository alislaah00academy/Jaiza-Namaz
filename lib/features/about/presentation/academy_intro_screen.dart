import 'package:flutter/material.dart';

import '../../../core/widgets/jaiza_scaffold.dart';

/// Urdu introduction document for Al Islaah Academy (RTL).
class AcademyIntroScreen extends StatelessWidget {
  const AcademyIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Text(
              _Content.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _Content.introParagraph,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  _Content.sectionAghaz,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _Content.aghazBody1,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  _Content.aghazBody2,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  _Content.aghazBody3,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _Content.departmentsLead,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  _Content.educationDeptTitle,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _Content.educationDeptBody,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _Content.detailedCoursesHeading,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._Content.detailedCourses.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• $line',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JaizaSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _Content.shortCoursesHeading,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  _Content.shortCourses.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${i + 1}.',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _Content.shortCourses[i],
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _Content.closingLine,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

abstract final class _Content {
  static const title = 'الاصلاح اکیڈمی کا مختصر تعارف';

  static const introParagraph =
      'الاصلاح اکیڈمی ایک ایسا تعلیمی ادارہ ہے جو مختلف شعبہ جات میں اپنی خدمات انجام دے رہا ہے۔ اس کا نصب العین یہی ہے کہ لوگوں کی جاری زندگیوں میں بہتری لائی جائے۔ معاشرے میں ہر ممکن مثبت تبدیلیاں پیدا ہوں، اور مسلمان اپنی حقیقی پہچان کو سمجھیں اور اپنے اسلام پر عمل کرنے والے بنیں۔';

  static const sectionAghaz = 'آغاز:';

  static const aghazBody1 =
      'الحمدللہ! ابتدا کا کام الاصلاح اکیڈمی نے نہایت سادگی سے کیا۔ یہ چند دوستوں کی خواہش تھی کہ عام مسلمانوں کے لیے سستا مگر معیاری دینی کورس کروایا جائے۔ اس کورس کے دوران سب مشکلات کا سامنا کرنا پڑا، لیکن الحمدللہ آہستہ آہستہ کام آگے بڑھتا گیا۔ کچھ عرصہ کے بعد ایک مستقل ادارہ قائم کیا گیا، اور اس کا نام الاصلاح اکیڈمی رکھا گیا اور اس کی بنیاد پر اساتذہ کرام نے دین کی تعلیم کو عام کرنے کا عزم کیا۔ اس دوران حضرت عثمان غنی رضی اللہ عنہ کی خدمات کو سامنے رکھا گیا اور اس نام کو چننے کا مقصد بھی یہی تھا کہ معاشرے میں اصلاح کا کام عام ہو۔';

  static const aghazBody2 =
      'الاصلاح اکیڈمی کا باقاعدہ نظام قائم کرنے کے لیے حافظ محمد فاروق صاحب نے نمایاں کردار ادا کیا، اور پھر ان کے ساتھ دیگر اساتذہ بھی شامل ہوتے گئے۔ الاصلاح اکیڈمی میں اس وقت قرآن، حدیث، فقہ اور دیگر علوم کی تعلیم دی جا رہی ہے۔';

  static const aghazBody3 =
      'الاصلاح اکیڈمی کے قیام میں ہمیں اساتذہ کرام کا تعاون حاصل رہا، اور پھر حضرت استاد محترم مولانا مشتاق صاحب کی نگرانی میں یہ ادارہ ترقی کرتا گیا۔';

  static const departmentsLead =
      'الاصلاح اکیڈمی کے چند ایک شعبہ جات درج ذیل ہیں:';

  static const educationDeptTitle = '☆ تعلیمی شعبہ';

  static const educationDeptBody =
      'اس شعبہ میں علومِ شرعیہ وغیرہ کی تعلیم دی جاتی ہے۔ الاصلاح اکیڈمی میں مختلف کورسز کا انعقاد مختلف اوقات میں ہوتا رہتا ہے جن میں کثیر تعداد میں طلبہ شریک ہوتے ہیں۔';

  static const detailedCoursesHeading = 'تفصیلی کورسز:';

  static const detailedCourses = <String>[
    'آٹھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)',
    'آن لائن چھ سالہ درسِ نظامی (وفاق المدارس العربیہ پاکستان)',
    'دو سالہ درسِ حدیث للبنات',
  ];

  static const shortCoursesHeading = 'مختصر کورسز:';

  static const shortCourses = <String>[
    'سیرت النبی ﷺ کورس',
    'مثالی اسلامی کورس',
    'منتخب احادیث',
    'آسان تفسیر کورس',
    'تجوید کورس',
    'آسان عربی',
    'عقیدہ کورس',
    'ترجمہ قرآن کورس',
    'حفظِ قرآن کورس',
    'عقائد و ایمانیات کورس',
    'تصوف و اصلاحی تربیت',
  ];

  static const closingLine =
      'ان کے علاوہ بھی کئی کورسز کی کلاسز جاری ہیں';
}
