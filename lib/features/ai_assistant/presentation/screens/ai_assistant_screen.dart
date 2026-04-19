// lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:section/core/constants/app_assets.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/ai_assistant/data/repositories/ai_repository.dart';
import 'package:section/features/ai_assistant/presentation/cubit/ai_chat_cubit.dart';
import 'package:section/features/ai_assistant/presentation/cubit/ai_chat_state.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProfile(),
      builder: (_, snap) {
        final faculty = snap.data?['faculty'] as String? ?? 'medicine';
        final year    = snap.data?['academic_year'] as int? ?? 1;
        return BlocProvider(
          create: (_) => AiChatCubit(AiRepository(), faculty: faculty, academicYear: year),
          child: const _AiChatView(),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return null;
    return SupabaseService.client.from('profiles').select('faculty,academic_year').eq('id', uid).maybeSingle();
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();
  @override State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _hasText = false;

  @override void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _send(BuildContext ctx) {
    if (_ctrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ctx.read<AiChatCubit>().sendMessage(_ctrl.text);
    _ctrl.clear();
    setState(() => _hasText = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<AiChatCubit, AiChatState>(
      listener: (_, s) { if (s.messages.isNotEmpty) _scrollToBottom(); },
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Section AI', style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 16)),
              Text(isAr ? 'مساعدك الشخصي • يدرس معك' : 'Your personal AI • Studies with you',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppColors.textSecondaryLight)),
            ]),
          ]),
          actions: [
            if (state.messages.isNotEmpty) IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => ctx.read<AiChatCubit>().clearChat(),
              tooltip: isAr ? 'مسح' : 'Clear',
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: state.messages.isEmpty
                ? _emptyState(ctx, isAr, state)
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length + (state.status == AiChatStatus.loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      // typing indicator at top (bottom in reversed list)
                      if (i == 0 && state.status == AiChatStatus.loading) {
                        return Align(alignment: Alignment.centerLeft,
                          child: Container(margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.backgroundLight,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomRight: Radius.circular(14))),
                            child: Lottie.asset(AppAssets.lottieTyping, width: 50, height: 28)));
                      }
                      final idx = state.status == AiChatStatus.loading ? i - 1 : i;
                      final msg = state.messages[state.messages.length - 1 - idx];
                      return _Bubble(body: msg.content, isUser: msg.isUser, time: _fmt(msg.createdAt));
                    },
                  ),
          ),
          // Quick chips
          if (state.showQuickChips)
            _QuickChips(isAr: isAr, onTap: (t) => ctx.read<AiChatCubit>().sendMessage(t)),
          // Error
          if (state.status == AiChatStatus.error)
            Container(color: AppColors.error.withOpacity(0.1), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 16), const SizedBox(width: 8),
                Expanded(child: Text(isAr ? 'خطأ في الاتصال. تحقق من الإنترنت' : 'Connection error. Check internet.',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.error))),
              ])),
          // Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5))),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
                  maxLines: null,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isAr ? 'اسأل Section AI أي سؤال...' : 'Ask Section AI anything...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.dividerLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.dividerLight)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), isDense: true),
                )),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: state.status == AiChatStatus.loading ? null : () => _send(ctx),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: _hasText && state.status != AiChatStatus.loading ? AppColors.primaryGradient : null,
                      color: (!_hasText || state.status == AiChatStatus.loading) ? AppColors.dividerLight : null,
                      shape: BoxShape.circle),
                    child: state.status == AiChatStatus.loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState(BuildContext ctx, bool isAr, AiChatState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 52)),
        const SizedBox(height: 20),
        Text(isAr ? 'أهلاً! أنا Section AI 🎓' : 'Hello! I\'m Section AI 🎓',
          style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 24), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          isAr ? 'مساعدك الشخصي الذكي. اسألني عن التشريح، الكريبس، الأدوية، أو أي شيء تريده!' : 'Your smart personal assistant. Ask me about anatomy, Krebs cycle, pharmacology, or absolutely anything!',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondaryLight, height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (state.showQuickChips) _QuickChips(isAr: isAr, onTap: (t) => ctx.read<AiChatCubit>().sendMessage(t)),
      ]),
    );
  }

  String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

class _Bubble extends StatelessWidget {
  final String body, time; final bool isUser;
  const _Bubble({required this.body, required this.isUser, required this.time});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : (isDark ? AppColors.cardDark : const Color(0xFFEBF3FF)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 2), bottomRight: Radius.circular(isUser ? 2 : 16)),
        ),
        child: Column(crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          if (!isUser) Row(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 10)),
            const SizedBox(width: 5),
            const Text('Section AI', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.primary)),
            const SizedBox(height: 4),
          ]),
          isUser
              ? Text(body, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white, height: 1.5))
              : MarkdownBody(data: body,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    strong: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    code: TextStyle(fontFamily: 'Cairo', backgroundColor: AppColors.primary.withOpacity(0.1), color: AppColors.primary, fontSize: 13),
                    h2: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 16),
                    h3: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 14),
                  )),
          const SizedBox(height: 3),
          Text(time, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
            color: isUser ? Colors.white.withOpacity(0.7) : AppColors.textSecondaryLight)),
        ]),
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  final bool isAr; final void Function(String) onTap;
  const _QuickChips({required this.isAr, required this.onTap});

  static const _ar = ['اشرح لي دورة الكريبس 🔬','ساعدني أذاكر التشريح 🦴','ما أفضل سماعة طبيب؟ 🩺','أيه الكتب المهمة لسنتي؟ 📚','اشرح ميكانيزم الأدوية 💊'];
  static const _en = ['Explain Krebs cycle 🔬','Help me study anatomy 🦴','Best stethoscope for beginners? 🩺','What books for my year? 📚','Explain drug mechanisms 💊'];

  @override
  Widget build(BuildContext context) {
    final chips = isAr ? _ar : _en;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Wrap(spacing: 8, runSpacing: 6, children: chips.map((c) => GestureDetector(
        onTap: () => onTap(c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3))),
          child: Text(c, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.secondary))),
      )).toList()),
    );
  }
}
