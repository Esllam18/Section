// lib/features/store/presentation/screens/checkout_screen.dart
// Adapter: bridges store/CartItemModel → checkout flow
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/features/checkout/data/repositories/paymob_repository.dart';
import 'package:section/features/checkout/presentation/screens/paymob_webview_screen.dart';
import 'package:section/features/store/data/models/cart_item_model.dart';
import 'package:section/features/store/data/repositories/cart_repository.dart' as store_cart;
import 'package:section/layout/main_layout.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _addrCtrl   = TextEditingController();
  String _payMethod = 'cash_on_delivery';
  bool _loading     = false;

  double get _subtotal =>
      widget.cartItems.fold(0.0, (s, i) => s + i.lineTotal);
  double get _total => _subtotal + 50;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    final p = await SupabaseService.client
        .from('profiles')
        .select('full_name,phone')
        .eq('id', uid)
        .maybeSingle();
    if (mounted && p != null) {
      _nameCtrl.text  = p['full_name'] ?? '';
      _phoneCtrl.text = p['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    setState(() => _loading = true);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final parts     = _nameCtrl.text.trim().split(' ');
    final firstName = parts.first;
    final lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '-';
    final totalCents = (_total * 100).round();
    final address = {
      'name':    _nameCtrl.text.trim(),
      'phone':   _phoneCtrl.text.trim(),
      'city':    _cityCtrl.text.trim(),
      'address': _addrCtrl.text.trim(),
    };

    try {
      if (_payMethod == 'cash_on_delivery') {
        await SupabaseService.client.from('orders').insert({
          'user_id': uid,
          'status': 'pending',
          'payment_method': 'cash_on_delivery',
          'payment_status': 'pending',
          'subtotal': _subtotal,
          'shipping_fee': 50.0,
          'total': _total,
          'shipping_address': address,
        });
        await store_cart.CartRepository().clearCart();
        if (!mounted) return;
        CustomSnackBar.show(
            message: isAr ? 'تم تقديم طلبك! ✓' : 'Order placed! ✓',
            type: SnackBarType.success);
        Navigation.offAll(const _SuccessScreen());
      } else {
        final repo  = PaymobRepository();
        final items = widget.cartItems
            .map((i) => PaymobItem(
                  name: i.product.nameEn,
                  description: i.product.nameEn,
                  amountCents: (i.product.effectivePrice * 100).round(),
                  quantity: i.quantity,
                ))
            .toList();
        final ref = 'SEC-${DateTime.now().millisecondsSinceEpoch}';
        final result = _payMethod == 'paymob_wallet'
            ? await repo.initiateWalletPayment(
                amountCents: totalCents,
                items: items,
                orderRef: ref,
                walletPhone: _phoneCtrl.text.trim(),
                email: SupabaseService.currentUser?.email ?? '',
                firstName: firstName,
                lastName: lastName,
                city: _cityCtrl.text.trim())
            : await repo.initiateCardPayment(
                amountCents: totalCents,
                items: items,
                orderRef: ref,
                email: SupabaseService.currentUser?.email ?? '',
                phone: _phoneCtrl.text.trim(),
                firstName: firstName,
                lastName: lastName,
                city: _cityCtrl.text.trim());

        if (!mounted) return;
        if (!result.success || result.iframeUrl == null) {
          CustomSnackBar.show(
              message: result.error ??
                  (isAr ? 'خطأ في بوابة الدفع' : 'Payment gateway error'),
              type: SnackBarType.error);
        } else {
          Navigation.to(PaymobWebViewScreen(
            iframeUrl: result.iframeUrl!,
            onResult: (s) async {
              if (s == PaymobStatus.success) {
                await store_cart.CartRepository().clearCart();
                if (mounted) Navigation.offAll(const _SuccessScreen());
              }
            },
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
            message: isAr ? 'حدث خطأ' : 'An error occurred',
            type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr  = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: Navigation.back),
        title: Text(isAr ? 'إتمام الطلب' : 'Checkout',
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sec(isAr ? 'معلومات التوصيل' : 'Delivery Info', isDark),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _nameCtrl,
                hint: isAr ? 'الاسم الكامل' : 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? (isAr ? 'مطلوب' : 'Required') : null),
            const SizedBox(height: AppSizes.sm),
            CustomTextField(
                controller: _phoneCtrl,
                hint: isAr ? 'رقم الهاتف' : 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? (isAr ? 'مطلوب' : 'Required') : null),
            const SizedBox(height: AppSizes.sm),
            CustomTextField(
                controller: _cityCtrl,
                hint: isAr ? 'المدينة' : 'City',
                prefixIcon: Icons.location_city_outlined,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? (isAr ? 'مطلوب' : 'Required') : null),
            const SizedBox(height: AppSizes.sm),
            CustomTextField(
                controller: _addrCtrl,
                hint: isAr ? 'العنوان بالتفصيل' : 'Detailed Address',
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? (isAr ? 'مطلوب' : 'Required') : null),
            const SizedBox(height: AppSizes.lg),

            _sec(isAr ? 'طريقة الدفع' : 'Payment Method', isDark),
            const SizedBox(height: 12),
            _PayTile(
                value: 'cash_on_delivery',
                group: _payMethod,
                icon: Icons.money_outlined,
                label: isAr ? 'الدفع عند الاستلام' : 'Cash on Delivery',
                onChanged: (v) => setState(() => _payMethod = v!)),
            _PayTile(
                value: 'paymob_card',
                group: _payMethod,
                icon: Icons.credit_card_outlined,
                label: isAr ? 'بطاقة بنكية' : 'Card (Paymob)',
                onChanged: (v) => setState(() => _payMethod = v!)),
            _PayTile(
                value: 'paymob_wallet',
                group: _payMethod,
                icon: Icons.account_balance_wallet_outlined,
                label: isAr ? 'محفظة إلكترونية' : 'Mobile Wallet',
                onChanged: (v) => setState(() => _payMethod = v!)),
            const SizedBox(height: AppSizes.lg),

            _sec(isAr ? 'ملخص الطلب' : 'Summary', isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                ...widget.cartItems.map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Expanded(
                            child: Text(
                                isAr ? i.product.nameAr : i.product.nameEn,
                                style: const TextStyle(
                                    fontFamily: 'Cairo', fontSize: 13))),
                        Text(
                            '${i.quantity} × ${i.product.effectivePrice.toStringAsFixed(0)} ج',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textSecondaryLight)),
                      ]),
                    )),
                const Divider(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(isAr ? 'المجموع الفرعي' : 'Subtotal',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  Text('${_subtotal.toStringAsFixed(0)} ج',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(isAr ? 'الشحن' : 'Shipping',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondaryLight)),
                  const Text('50 ج',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondaryLight)),
                ]),
                const Divider(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(isAr ? 'الإجمالي' : 'Total',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text('${_total.toStringAsFixed(0)} ج',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.primary)),
                ]),
              ]),
            ),
            const SizedBox(height: AppSizes.xl),
            CustomButton(
              label: isAr ? 'تأكيد الطلب' : 'Confirm Order',
              onTap: _confirm,
              isLoading: _loading,
              useGradient: true,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: AppSizes.xxl),
          ]),
        ),
      ),
    );
  }

  Widget _sec(String t, bool dark) => Text(t,
      style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight));
}

class _PayTile extends StatelessWidget {
  final String value, group, label;
  final IconData icon;
  final void Function(String?) onChanged;
  const _PayTile(
      {required this.value,
      required this.group,
      required this.icon,
      required this.label,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final sel   = value == group;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.primary.withOpacity(0.07)
              : (isDark ? AppColors.cardDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight),
              width: sel ? 1.5 : 0.8),
        ),
        child: Row(children: [
          Icon(icon,
              size: 22,
              color: sel ? AppColors.primary : AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: sel
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)))),
          Radio<String>(
              value: value,
              groupValue: group,
              onChanged: onChanged,
              activeColor: AppColors.primary),
        ]),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen();
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 56)),
              const SizedBox(height: 28),
              Text(isAr ? 'تم تقديم طلبك! 🎉' : 'Order Placed! 🎉',
                  style: const TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w700,
                      fontSize: 26),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                  isAr
                      ? 'سيتم التواصل معك قريباً.'
                      : "We'll contact you shortly.",
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.textSecondaryLight),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              CustomButton(
                  label: isAr ? 'متابعة التسوق' : 'Continue Shopping',
                  onTap: () => Navigation.offAll(const MainLayout()),
                  useGradient: true),
            ]),
          ),
        ),
      ),
    );
  }
}
