import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/features/community/data/repositories/community_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController(); final _bodyCtrl = TextEditingController();
  String _type = 'discussion'; bool _loading = false;

  static const _types = [
    ('discussion','نقاش','Discussion',Icons.chat_bubble_outline_rounded,AppColors.info),
    ('question','سؤال','Question',Icons.help_outline_rounded,Color(0xFFFFAB00)),
    ('experience','تجربة','Experience',Icons.star_outline_rounded,AppColors.success),
    ('announcement','إعلان','Announcement',Icons.campaign_outlined,AppColors.error),
  ];

  @override void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: Navigation.back),
        title: Text(isAr ? 'منشور جديد' : 'New Post', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.md), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isAr ? 'نوع المنشور' : 'Post Type', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
          final sel = _type == t.$1;
          return GestureDetector(onTap: () => setState(() => _type = t.$1),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? t.$5.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? t.$5 : AppColors.dividerLight, width: sel ? 2 : 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(t.$4, size: 15, color: sel ? t.$5 : AppColors.textSecondaryLight),
                const SizedBox(width: 5),
                Text(isAr ? t.$2 : t.$3, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? t.$5 : AppColors.textSecondaryLight)),
              ])));
        }).toList()),
        const SizedBox(height: AppSizes.lg),
        CustomTextField(controller: _titleCtrl, hint: isAr ? 'العنوان' : 'Title', prefixIcon: Icons.title, validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
        const SizedBox(height: AppSizes.md),
        TextFormField(controller: _bodyCtrl, maxLines: 6, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(hintText: isAr ? 'اكتب محتوى منشورك هنا...' : 'Write your post content here...')),
        const SizedBox(height: AppSizes.xl),
        CustomButton(label: isAr ? 'نشر' : 'Publish', onTap: () async {
          if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().length < 10) {
            CustomSnackBar.show(message: isAr ? 'أكمل البيانات' : 'Please complete the form', type: SnackBarType.warning); return;
          }
          setState(() => _loading = true);
          try {
            final post = await CommunityRepository().createPost(title: _titleCtrl.text.trim(), body: _bodyCtrl.text.trim(), postType: _type);
            if (mounted) Navigator.pop(context, post);
          } catch (e) { if (mounted) { setState(() => _loading = false); CustomSnackBar.show(message: e.toString(), type: SnackBarType.error); } }
        }, isLoading: _loading, useGradient: true),
      ])),
    );
  }
}
